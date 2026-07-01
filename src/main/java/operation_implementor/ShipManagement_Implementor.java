package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;

import db_config.GetConnection;
import model.ShipManagement;
import operations.ShipManagement_Operation;

public class ShipManagement_Implementor implements ShipManagement_Operation {

	private String message;

	@Override
	public int addShip(ShipManagement ship) {
		int result = 0;
		message = null;

		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call add_ship(?,?,?,?,?)}")) {

			cs.setString(1, ship.getShipName());
			cs.setString(2, normalizeDate(ship.getArrivalDate()));
			cs.setString(3, normalizeDate(ship.getDepartureDate()));
			cs.setString(4, ship.getStatus());
			cs.setInt(5, ship.getOperatorId());

			result = cs.executeUpdate();

		} catch (SQLException e) {
			message = e.getMessage();
			e.printStackTrace();
		} catch (Exception e) {
			message = "Failed to add ship.";
			e.printStackTrace();
		}

		return result;
	}

	@Override
	public int updateShip(ShipManagement ship) {
		int result = 0;
		message = null;

		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call update_ship(?,?,?,?,?)}")) {

			cs.setInt(1, ship.getShipId());
			cs.setString(2, ship.getShipName());
			cs.setString(3, normalizeDate(ship.getArrivalDate()));
			cs.setString(4, normalizeDate(ship.getDepartureDate()));
			cs.setString(5, ship.getStatus());

			result = cs.executeUpdate();

		} catch (SQLException e) {
			message = e.getMessage();
			e.printStackTrace();
		} catch (Exception e) {
			message = "Failed to update ship.";
			e.printStackTrace();
		}

		return result;
	}

	@Override
	public int deleteShip(ShipManagement ship) {
		int result = 0;
		message = null;

		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call sp_delete_ship(?)}")) {

			cs.setInt(1, ship.getShipId());

			result = cs.executeUpdate();

		} catch (SQLException e) {
			message = e.getMessage();
			e.printStackTrace();
		} catch (Exception e) {
			message = "Failed to delete ship.";
			e.printStackTrace();
		}

		return result;
	}

	@Override
	public ArrayList<HashMap<String, String>> getAllShips() {
		ArrayList<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();

		String sql = "SELECT s.ship_id, s.ship_name, s.operator_id, u.name AS operator_name, "
				+ "DATE_FORMAT(s.arrival_date, '%Y-%m-%d %H:%i') AS arrival_date, "
				+ "DATE_FORMAT(s.departure_date, '%Y-%m-%d %H:%i') AS departure_date, " + "s.status " + "FROM ship s "
				+ "LEFT JOIN user u ON s.operator_id = u.user_id " + "ORDER BY s.arrival_date DESC";

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement statement = conn.prepareStatement(sql);
				ResultSet set = statement.executeQuery()) {

			while (set.next()) {
				HashMap<String, String> row = new HashMap<String, String>();
				row.put("ship_id", set.getString("ship_id"));
				row.put("ship_name", set.getString("ship_name"));
				row.put("operator_id", set.getString("operator_id"));
				row.put("operator_name", set.getString("operator_name"));
				row.put("arrival_date", set.getString("arrival_date"));
				row.put("departure_date", set.getString("departure_date"));
				row.put("status", set.getString("status"));
				list.add(row);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> getOperators() {
		ArrayList<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();

		String sql = "SELECT user_id, name FROM user WHERE role_id = 3 ORDER BY name";

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement statement = conn.prepareStatement(sql);
				ResultSet set = statement.executeQuery()) {

			while (set.next()) {
				HashMap<String, String> row = new HashMap<String, String>();
				row.put("user_id", set.getString("user_id"));
				row.put("name", set.getString("name"));
				list.add(row);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> searchShips(String shipName, String operatorName, String status) {
		ArrayList<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();
		message = null;

		String sql = "{call sp_search_ship(?,?,?)}";

		try {
			Integer shipId = null;
			String cleanShipName = emptyToNull(shipName);
			String cleanStatus = emptyToNull(status);

			if (cleanShipName != null) {
				try {
					shipId = Integer.parseInt(cleanShipName);
					cleanShipName = null;
				} catch (NumberFormatException ignore) {
				}
			}

			try (Connection conn = GetConnection.getConnection(); CallableStatement cs = conn.prepareCall(sql)) {

				if (shipId == null) {
					cs.setNull(1, Types.INTEGER);
				} else {
					cs.setInt(1, shipId);
				}

				cs.setString(2, cleanShipName);
				cs.setString(3, cleanStatus);

				try (ResultSet set = cs.executeQuery()) {
					while (set.next()) {
						HashMap<String, String> row = new HashMap<String, String>();
						row.put("ship_id", set.getString("ship_id"));
						row.put("ship_name", set.getString("ship_name"));
						row.put("operator_id", set.getString("operator_id"));
						row.put("arrival_date", formatDate(set.getString("arrival_date")));
						row.put("departure_date", formatDate(set.getString("departure_date")));
						row.put("status", set.getString("status"));
						row.put("operator_name", getOperatorName(set.getString("operator_id")));
						list.add(row);
					}
				}
			}

		} catch (SQLException e) {
			message = e.getMessage();
			e.printStackTrace();
		} catch (Exception e) {
			message = "Failed to search ships.";
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public HashMap<String, Integer> getShipStatusCounts(ArrayList<HashMap<String, String>> shipList) {
		HashMap<String, Integer> counts = new HashMap<String, Integer>();
		int anchored = 0;
		int docked = 0;
		int departed = 0;

		for (HashMap<String, String> row : shipList) {
			String status = row.get("status");
			if ("Anchored".equalsIgnoreCase(status))
				anchored++;
			else if ("Docked".equalsIgnoreCase(status))
				docked++;
			else if ("Departed".equalsIgnoreCase(status))
				departed++;
		}

		counts.put("Anchored", anchored);
		counts.put("Docked", docked);
		counts.put("Departed", departed);
		return counts;
	}

	@Override
	public String getMessage() {
		return message;
	}

	private String normalizeDate(String dateTime) {
		return dateTime == null ? null : dateTime.replace("T", " ");
	}

	private String formatDate(String dateTime) {
		return dateTime == null ? "" : dateTime;
	}

	private String emptyToNull(String value) {
		if (value == null)
			return null;
		value = value.trim();
		return value.isEmpty() ? null : value;
	}

	private String getOperatorName(String operatorId) {
		String name = "";
		String sql = "SELECT name FROM user WHERE user_id = ?";

		try (Connection conn = GetConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, Integer.parseInt(operatorId));

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					name = rs.getString("name");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return name;
	}

	@Override
	public boolean isValidOperator(int operatorId) {
		String sql = "SELECT 1 FROM user WHERE user_id = ? LIMIT 1";
		boolean exists = false;

		try (Connection conn = GetConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, operatorId);

			try (ResultSet rs = ps.executeQuery()) {
				exists = rs.next();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return exists;
	}
}
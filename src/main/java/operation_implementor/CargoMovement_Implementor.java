package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;

import db_config.GetConnection;
import model.CargoMovement;
import operations.CargoMovement_Operation;

public class CargoMovement_Implementor implements CargoMovement_Operation {

	@Override
	public boolean log_Cargo_Movement(CargoMovement cargo) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call log_cargo_movement(?, ?, ?)}")) {

			cs.setInt(1, cargo.getCargoId());
			cs.setString(2, cargo.getMovementType());
			cs.setInt(3, cargo.getHandledBy());
			cs.executeUpdate();

			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Cargo_Movement_History() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement statement = conn
						.prepareStatement("select * from vw_cargo_movement_history order by movement_date desc");
				ResultSet set = statement.executeQuery()) {

			while (set.next()) {
				HashMap<String, String> row = new HashMap<>();

				row.put("movement_id", String.valueOf(set.getInt("movement_id")));
				row.put("cargo_description", set.getString("cargo_description"));
				row.put("movement_type", set.getString("movement_type"));
				row.put("movement_date", set.getString("movement_date"));
				row.put("handled_by", set.getString("handled_by"));

				list.add(row);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Cargo_History(int cargoId) {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call get_cargo_history(?)}")) {

			cs.setInt(1, cargoId);

			try (ResultSet set = cs.executeQuery()) {
				while (set.next()) {
					HashMap<String, String> row = new HashMap<>();

					row.put("movement_id", String.valueOf(set.getInt("movement_id")));
					row.put("cargo_description", set.getString("cargo_description"));
					row.put("movement_type", set.getString("movement_type"));
					row.put("movement_date", set.getString("movement_date"));
					row.put("cargo_handler", set.getString("cargo_handler"));

					list.add(row);
				}
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Cargo_Details() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement statement = conn
						.prepareStatement("select * from vw_cargo_details order by cargo_id desc");
				ResultSet set = statement.executeQuery()) {

			while (set.next()) {
				HashMap<String, String> row = new HashMap<>();

				row.put("cargo_id", String.valueOf(set.getInt("cargo_id")));
				row.put("description", set.getString("description"));

				list.add(row);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Users() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement statement = conn
						.prepareStatement("select user_id, name from `user` order by user_id desc");
				ResultSet set = statement.executeQuery()) {

			while (set.next()) {
				HashMap<String, String> row = new HashMap<>();

				row.put("user_id", String.valueOf(set.getInt("user_id")));
				row.put("name", set.getString("name"));

				list.add(row);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public boolean ensure_Cargo_Movement_Handler(int cargoId, String movementType, int handledBy) {
		if (cargoId <= 0 || handledBy <= 0 || movementType == null || movementType.trim().isEmpty()) {
			return false;
		}

		String cleanedType = movementType.trim();

		try (Connection conn = GetConnection.getConnection()) {
			Integer latestMovementId = null;
			String latestType = null;

			try (PreparedStatement statement = conn
					.prepareStatement("select movement_id, movement_type from cargo_movement where cargo_id = ? "
							+ "order by movement_date desc, movement_id desc limit 1")) {
				statement.setInt(1, cargoId);
				try (ResultSet set = statement.executeQuery()) {
					if (set.next()) {
						latestMovementId = set.getInt("movement_id");
						latestType = set.getString("movement_type");
					}
				}
			}

			if (latestMovementId != null && latestType != null && latestType.equalsIgnoreCase(cleanedType)) {
				try (PreparedStatement update = conn
						.prepareStatement("update cargo_movement set handled_by = ? where movement_id = ?")) {
					update.setInt(1, handledBy);
					update.setInt(2, latestMovementId);
					return update.executeUpdate() > 0;
				}
			}

			try (CallableStatement cs = conn.prepareCall("{call log_cargo_movement(?, ?, ?)}")) {
				cs.setInt(1, cargoId);
				cs.setString(2, cleanedType);
				cs.setInt(3, handledBy);
				cs.executeUpdate();
				return true;
			}

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}
}

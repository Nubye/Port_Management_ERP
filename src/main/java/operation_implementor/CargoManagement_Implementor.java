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
import model.CargoManagement;
import operations.CargoManagement_Operation;

public class CargoManagement_Implementor implements CargoManagement_Operation {

	@Override
	public boolean add_Cargo(CargoManagement cargo) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call add_cargo(?, ?, ?, ?)}")) {

			cs.setInt(1, cargo.getContainerId());
			cs.setString(2, cargo.getDescription());
			cs.setDouble(3, cargo.getWeight());
			cs.setString(4, cargo.getStatus());
			cs.executeUpdate();

			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public boolean update_Cargo(CargoManagement cargo) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call update_cargo(?, ?, ?, ?)}")) {

			cs.setInt(1, cargo.getCargoId());
			cs.setString(2, cargo.getDescription());
			cs.setDouble(3, cargo.getWeight());
			cs.setString(4, cargo.getStatus());
			cs.executeUpdate();

			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public boolean delete_Cargo(CargoManagement cargo) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call delete_cargo(?)}")) {

			cs.setInt(1, cargo.getCargoId());
			cs.executeUpdate();

			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public ArrayList<HashMap<String, String>> search_Cargo(String keyword) {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call search_cargo(?)}")) {

			if (keyword == null || keyword.trim().isEmpty()) {
				cs.setNull(1, Types.VARCHAR);
			} else {
				cs.setString(1, keyword.trim());
			}

			try (ResultSet set = cs.executeQuery()) {
				while (set.next()) {
					HashMap<String, String> row = new HashMap<>();

					row.put("cargo_id", String.valueOf(set.getInt("cargo_id")));
					row.put("description", set.getString("description"));
					row.put("weight", String.valueOf(set.getBigDecimal("weight")));
					row.put("cargo_status", set.getString("cargo_status"));
					row.put("container_id", String.valueOf(set.getInt("container_id")));
					row.put("container_type", set.getString("container_type"));
					row.put("ship_name", set.getString("ship_name"));

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
				row.put("weight", String.valueOf(set.getBigDecimal("weight")));
				row.put("cargo_status", set.getString("cargo_status"));
				row.put("container_id", String.valueOf(set.getInt("container_id")));
				row.put("container_type", set.getString("container_type"));
				row.put("ship_name", set.getString("ship_name"));

				list.add(row);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Pending_Cargo_Movements() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement statement = conn
						.prepareStatement("select * from vw_pending_cargo_movements order by cargo_id desc");
				ResultSet set = statement.executeQuery()) {

			while (set.next()) {
				HashMap<String, String> row = new HashMap<>();

				row.put("cargo_id", String.valueOf(set.getInt("cargo_id")));
				row.put("description", set.getString("description"));
				row.put("status", set.getString("status"));
				row.put("container_id", String.valueOf(set.getInt("container_id")));
				row.put("ship_name", set.getString("ship_name"));

				list.add(row);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Containers() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement statement = conn.prepareStatement(
						"select container_id, container_type from container order by container_id desc");
				ResultSet set = statement.executeQuery()) {

			while (set.next()) {
				HashMap<String, String> row = new HashMap<>();

				row.put("container_id", String.valueOf(set.getInt("container_id")));
				row.put("container_type", set.getString("container_type"));

				list.add(row);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}
}
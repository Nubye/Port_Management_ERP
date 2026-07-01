package operation_implementor;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;

import db_config.GetConnection;
import model.DockManagement;
import operations.DockManagement_Operation;

public class DockManagement_Implementor implements DockManagement_Operation {

	private String message;

	@Override
	public int addDock(DockManagement dock) {
		message = null;
		String sql = "{call add_dock(?,?)}";

		try (Connection con = GetConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

			cs.setString(1, dock.getDockName());
			cs.setString(2, dock.getStatus());

			return cs.executeUpdate();

		} catch (Exception e) {
			message = e.getMessage();
			e.printStackTrace();
			return 0;
		}
	}

	@Override
	public int updateDock(DockManagement dock) {
		message = null;
		String sql = "{call update_dock(?,?,?)}";

		try (Connection con = GetConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

			cs.setInt(1, dock.getDockId());
			cs.setString(2, dock.getDockName());
			cs.setString(3, dock.getStatus());

			return cs.executeUpdate();

		} catch (Exception e) {
			message = e.getMessage();
			e.printStackTrace();
			return 0;
		}
	}

	@Override
	public int deleteDock(int dockId) {
		message = null;

		String checkSql = "SELECT COUNT(*) " + "FROM dock_allocation " + "WHERE dock_id = ? "
				+ "AND release_time IS NULL";

		String deleteSql = "{call delete_dock(?)}";

		try (Connection con = GetConnection.getConnection(); PreparedStatement ps = con.prepareStatement(checkSql)) {

			ps.setInt(1, dockId);
			ResultSet rs = ps.executeQuery();

			if (rs.next() && rs.getInt(1) > 0) {
				message = "Cannot delete occupied dock.";
				return 0;
			}

			try (CallableStatement cs = con.prepareCall(deleteSql)) {
				cs.setInt(1, dockId);
				return cs.executeUpdate();
			}

		} catch (Exception e) {
			message = e.getMessage();
			e.printStackTrace();
			return 0;
		}
	}

	@Override
	public ArrayList<HashMap<String, String>> showDock() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		String sql = "SELECT d.dock_id,d.dock_name,d.status," + "COALESCE(s.ship_name,'No Ship Assigned') AS ship_name "
				+ "FROM dock d " + "LEFT JOIN dock_allocation da ON da.allocation_id=(" + "SELECT MAX(x.allocation_id) "
				+ "FROM dock_allocation x " + "WHERE x.dock_id=d.dock_id) "
				+ "LEFT JOIN ship s ON da.ship_id=s.ship_id";

		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("dock_id", String.valueOf(rs.getInt("dock_id")));
				row.put("dock_name", rs.getString("dock_name"));
				row.put("status", rs.getString("status"));
				row.put("ship_name", rs.getString("ship_name"));
				list.add(row);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> searchDock(String dockName, String status) {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		String sql = "SELECT d.dock_id, d.dock_name, d.status, s.ship_name " + "FROM dock d "
				+ "LEFT JOIN dock_allocation da ON d.dock_id = da.dock_id AND da.release_time IS NULL "
				+ "LEFT JOIN ship s ON da.ship_id = s.ship_id " + "WHERE (? IS NULL OR d.dock_name LIKE ?) "
				+ "AND (? IS NULL OR d.status = ?)";

		try (Connection con = GetConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			if (dockName == null || dockName.trim().isEmpty()) {
				ps.setNull(1, Types.VARCHAR);
				ps.setNull(2, Types.VARCHAR);
			} else {
				ps.setString(1, dockName);
				ps.setString(2, "%" + dockName + "%");
			}

			if (status == null || status.trim().isEmpty()) {
				ps.setNull(3, Types.VARCHAR);
				ps.setNull(4, Types.VARCHAR);
			} else {
				ps.setString(3, status);
				ps.setString(4, status);
			}

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("dock_id", String.valueOf(rs.getInt("dock_id")));
				row.put("dock_name", rs.getString("dock_name"));
				row.put("status", rs.getString("status"));
				row.put("ship_name", rs.getString("ship_name"));
				list.add(row);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public String getMessage() {
		return message;
	}
}
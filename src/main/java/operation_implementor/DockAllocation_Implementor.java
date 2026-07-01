package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;

import db_config.GetConnection;
import model.DockAllocation;
import operations.DockAllocation_Operation;

public class DockAllocation_Implementor implements DockAllocation_Operation {

	@Override
	public void allocate_Dock(DockAllocation da) {
		String sql = "{call allocate_dock(?, ?, ?, ?)}";
		try (Connection con = GetConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

			cs.setInt(1, da.getShipId());
			cs.setInt(2, da.getDockId());
			cs.setString(3, da.getAllocationTime());
			cs.setString(4, da.getReleaseTime());
			cs.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void release_Dock(DockAllocation da) {
		String sql = "{call release_dock(?)}";
		try (Connection con = GetConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

			cs.setInt(1, da.getAllocationId());
			cs.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void update_Allocation(DockAllocation da) {
		String sql = "{call update_allocation(?, ?)}";
		try (Connection con = GetConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

			cs.setInt(1, da.getAllocationId());
			cs.setInt(2, da.getDockId());
			cs.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void delete_Allocation(DockAllocation da) {
		String sql = "{call delete_allocation(?)}";
		try (Connection con = GetConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

			cs.setInt(1, da.getAllocationId());
			cs.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Available_Docks() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();
		String sql = "SELECT * FROM vw_available_docks";

		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("dock_id", String.valueOf(rs.getInt("dock_id")));
				row.put("dock_name", rs.getString("dock_name"));
				row.put("status", rs.getString("status"));
				list.add(row);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Available_Ships() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();
		String sql = "SELECT * FROM vw_available_ships";

		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("ship_id", String.valueOf(rs.getInt("ship_id")));
				row.put("ship_name", rs.getString("ship_name"));
				row.put("status", rs.getString("status"));
				list.add(row);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_All_Allocations(String statusFilter) {
		return search_All_Allocations("", statusFilter);
	}

	@Override
	public ArrayList<HashMap<String, String>> search_All_Allocations(String search, String statusFilter) {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();
		String sql = "{call search_all_allocations(?, ?)}";

		try (Connection con = GetConnection.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

			String safeSearch = (search == null) ? "" : search.trim();
			String safeStatus = (statusFilter == null || statusFilter.trim().isEmpty()) ? "All" : statusFilter.trim();

			cs.setString(1, safeSearch);
			cs.setString(2, safeStatus);

			try (ResultSet rs = cs.executeQuery()) {
				while (rs.next()) {
					HashMap<String, String> row = new HashMap<>();
					row.put("allocation_id", String.valueOf(rs.getInt("allocation_id")));
					row.put("ship_id", String.valueOf(rs.getInt("ship_id")));
					row.put("ship_name", rs.getString("ship_name"));
					row.put("dock_id", String.valueOf(rs.getInt("dock_id")));
					row.put("dock_name", rs.getString("dock_name"));
					row.put("allocation_time", rs.getString("allocation_time"));
					row.put("release_time", rs.getString("release_time"));
					row.put("status", rs.getString("status"));
					list.add(row);
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Active_Allocations() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();
		String sql = "SELECT * FROM vw_active_dock_allocations ORDER BY allocation_time DESC, allocation_id DESC";

		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("allocation_id", String.valueOf(rs.getInt("allocation_id")));
				row.put("ship_id", String.valueOf(rs.getInt("ship_id")));
				row.put("ship_name", rs.getString("ship_name"));
				row.put("dock_id", String.valueOf(rs.getInt("dock_id")));
				row.put("dock_name", rs.getString("dock_name"));
				row.put("allocation_time", rs.getString("allocation_time"));
				row.put("release_time", rs.getString("release_time"));
				row.put("status", rs.getString("status"));
				list.add(row);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}
}
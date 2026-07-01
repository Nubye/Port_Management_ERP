package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;

import db_config.GetConnection;
import model.ContainerManagement;
import operations.ContainerManagement_Operation;

public class ContainerManagement_Implementor implements ContainerManagement_Operation {

	@Override
	public boolean add_Container(ContainerManagement container) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call add_container(?,?,?)}")) {

			cs.setString(1, container.getContainerType());
			cs.setString(2, container.getStatus());
			cs.setInt(3, container.getShipId());
			cs.executeUpdate();
			return true;

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public boolean update_Container(ContainerManagement container) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call update_container(?,?,?,?)}")) {

			cs.setInt(1, container.getContainerId());
			cs.setString(2, container.getContainerType());
			cs.setString(3, container.getStatus());
			cs.setInt(4, container.getShipId());
			cs.executeUpdate();
			return true;

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public boolean delete_Container(int containerId) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call delete_container(?)}")) {

			cs.setInt(1, containerId);
			cs.executeUpdate();
			return true;

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public ArrayList<HashMap<String, String>> search_Containers(Integer containerId, String containerType,
			String status, String shipName) {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call search_container(?,?,?,?)}")) {

			if (containerId != null)
				cs.setInt(1, containerId);
			else
				cs.setNull(1, Types.INTEGER);

			if (containerType != null && !containerType.isEmpty())
				cs.setString(2, containerType);
			else
				cs.setNull(2, Types.VARCHAR);

			if (status != null && !status.isEmpty())
				cs.setString(3, status);
			else
				cs.setNull(3, Types.VARCHAR);

			if (shipName != null && !shipName.isEmpty())
				cs.setString(4, shipName);
			else
				cs.setNull(4, Types.VARCHAR);

			try (ResultSet rs = cs.executeQuery()) {
				while (rs.next()) {
					HashMap<String, String> row = new HashMap<>();

					String dbStatus = rs.getString("container_status");
					String statusClass = "empty";
					if ("Loaded".equalsIgnoreCase(dbStatus)) {
						statusClass = "loaded";
					} else if ("In Transit".equalsIgnoreCase(dbStatus)) {
						statusClass = "transit";
					}

					row.put("container_id", String.valueOf(rs.getInt("container_id")));
					row.put("container_type", rs.getString("container_type"));
					row.put("status", dbStatus);
					row.put("status_class", statusClass);
					row.put("ship_id", String.valueOf(rs.getInt("ship_id")));
					row.put("ship_name", rs.getString("ship_name") != null ? rs.getString("ship_name") : "-");
					row.put("cargo_description",
							rs.getString("cargo_description") != null ? rs.getString("cargo_description") : "-");
					row.put("weight", rs.getDouble("weight") > 0 ? String.valueOf(rs.getDouble("weight")) : "-");
					row.put("cargo_status", rs.getString("cargo_status") != null ? rs.getString("cargo_status") : "-");

					list.add(row);
				}
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_All_Ships() {
		ArrayList<HashMap<String, String>> shipList = new ArrayList<>();

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement("SELECT ship_id, ship_name FROM ship ORDER BY ship_name");
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("ship_id", String.valueOf(rs.getInt("ship_id")));
				row.put("ship_name", rs.getString("ship_name"));
				shipList.add(row);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return shipList;
	}

	@Override
	public HashMap<String, String> get_Container_By_Id(int containerId) {
		HashMap<String, String> row = null;

		String sql = "SELECT container_id, container_type, container_status, ship_id "
				+ "FROM container WHERE container_id = ?";

		try (Connection conn = GetConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, containerId);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					row = new HashMap<>();
					row.put("container_id", String.valueOf(rs.getInt("container_id")));
					row.put("container_type", rs.getString("container_type"));
					row.put("status", rs.getString("container_status"));
					row.put("ship_id", String.valueOf(rs.getInt("ship_id")));
				}
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return row;
	}

	@Override
	public ArrayList<HashMap<String, String>> sortContainersByIdDesc(ArrayList<HashMap<String, String>> list) {

		Collections.sort(list, new Comparator<HashMap<String, String>>() {
			@Override
			public int compare(HashMap<String, String> a, HashMap<String, String> b) {
				try {
					int idA = Integer.parseInt(a.get("container_id"));
					int idB = Integer.parseInt(b.get("container_id"));
					return Integer.compare(idB, idA);
				} catch (Exception e) {
					return 0;
				}
			}
		});

		return list;
	}

	@Override
	public HashMap<String, Integer> getContainerStats(ArrayList<HashMap<String, String>> allContainers) {

		HashMap<String, Integer> stats = new HashMap<>();
		int total = 0;
		int loaded = 0;
		int transit = 0;

		if (allContainers != null) {
			total = allContainers.size();

			for (HashMap<String, String> c : allContainers) {
				String s = c.get("status");
				if (s != null) {
					if ("Loaded".equalsIgnoreCase(s))
						loaded++;
					if ("In Transit".equalsIgnoreCase(s))
						transit++;
				}
			}
		}

		stats.put("total", total);
		stats.put("loaded", loaded);
		stats.put("transit", transit);

		return stats;
	}
}
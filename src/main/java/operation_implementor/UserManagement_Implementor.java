package operation_implementor;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;

import db_config.GetConnection;
import model.UserManagement;
import operations.UserManagement_Operation;

public class UserManagement_Implementor implements UserManagement_Operation {

	@Override
	public void add_User(UserManagement um) {
		try {
			CallableStatement cs = GetConnection.getConnection().prepareCall("{call sp_create_user(?, ?, ?, ?, ?)}");
			cs.setInt(1, um.getAdminId());
			cs.setString(2, um.getName());
			cs.setString(3, um.getEmail());
			cs.setString(4, um.getPassword());
			cs.setInt(5, um.getRoleId());
			cs.executeUpdate();
		} catch (SQLException e) {
			throw new RuntimeException(e.getMessage());
		}
	}

	@Override
	public void update_User(UserManagement um) {
		try {
			CallableStatement cs = GetConnection.getConnection().prepareCall("{call sp_update_user(?, ?, ?, ?)}");
			cs.setInt(1, um.getUserId());
			cs.setString(2, um.getName());
			cs.setString(3, um.getEmail());
			cs.setInt(4, um.getRoleId());
			cs.executeUpdate();
		} catch (SQLException e) {
			throw new RuntimeException(e.getMessage());
		}
	}

	@Override
	public void deactivate_User(UserManagement um) {
		try {
			CallableStatement cs = GetConnection.getConnection().prepareCall("{call sp_deactivate_user(?)}");
			cs.setInt(1, um.getUserId());
			cs.executeUpdate();
		} catch (SQLException e) {
			throw new RuntimeException(e.getMessage());
		}
	}

	@Override
	public void activate_User(UserManagement um) {
		try {
			CallableStatement cs = GetConnection.getConnection().prepareCall("{call sp_activate_user(?)}");
			cs.setInt(1, um.getUserId());
			cs.executeUpdate();
		} catch (SQLException e) {
			throw new RuntimeException(e.getMessage());
		}
	}

	@Override
	public ArrayList<HashMap<String, String>> get_All_Users() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();
		try {
			PreparedStatement ps = GetConnection.getConnection()
					.prepareStatement("select u.user_id, u.name, u.email, u.role_id, r.role_name, u.status "
							+ "from user u join role r on u.role_id = r.role_id order by u.user_id desc");
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("user_id", String.valueOf(rs.getInt("user_id")));
				row.put("name", rs.getString("name"));
				row.put("email", rs.getString("email"));
				row.put("role_id", String.valueOf(rs.getInt("role_id")));
				row.put("role_name", rs.getString("role_name"));
				row.put("status", rs.getString("status"));
				list.add(row);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> get_Roles() {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();
		try {
			PreparedStatement ps = GetConnection.getConnection()
					.prepareStatement("select role_id, role_name from role order by role_id");
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("role_id", String.valueOf(rs.getInt("role_id")));
				row.put("role_name", rs.getString("role_name"));
				list.add(row);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public ArrayList<HashMap<String, String>> search_Users(String search) {
		ArrayList<HashMap<String, String>> list = new ArrayList<>();
		try {
			PreparedStatement ps = GetConnection.getConnection()
					.prepareStatement("select u.user_id, u.name, u.email, u.role_id, r.role_name, u.status "
							+ "from user u join role r on u.role_id = r.role_id "
							+ "where cast(u.user_id as char) like ? or u.name like ? or u.email like ? or r.role_name like ? or u.status like ? "
							+ "order by u.user_id desc");
			String term = "%" + search + "%";
			ps.setString(1, term);
			ps.setString(2, term);
			ps.setString(3, term);
			ps.setString(4, term);
			ps.setString(5, term);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				HashMap<String, String> row = new HashMap<>();
				row.put("user_id", String.valueOf(rs.getInt("user_id")));
				row.put("name", rs.getString("name"));
				row.put("email", rs.getString("email"));
				row.put("role_id", String.valueOf(rs.getInt("role_id")));
				row.put("role_name", rs.getString("role_name"));
				row.put("status", rs.getString("status"));
				list.add(row);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}
}
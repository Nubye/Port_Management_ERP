package operation_implementor;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Connection;

import db_config.GetConnection;
import model.User;
import operations.User_Operation;

public class User_Implementor implements User_Operation {

	@Override
	public User login_User(User user) {
		User loggedUser = null;

		try (Connection con = GetConnection.getConnection();
				CallableStatement cs = con.prepareCall("{call sp_login(?, ?)}")) {
			cs.setString(1, user.getEmail());
			cs.setString(2, user.getPassword());
			cs.execute();

			loggedUser = get_User_By_Email(user.getEmail());

		} catch (SQLException e) {
			String message = e.getMessage();

			if (message != null && !message.trim().isEmpty()) {
				throw new RuntimeException(message);
			} else {
				throw new RuntimeException("Login failed.");
			}
		}

		return loggedUser;
	}

	@Override
	public void logout_User(User user) {
		try (Connection con = GetConnection.getConnection();
				CallableStatement cs = con.prepareCall("{call sp_logout(?)}")) {
			cs.setInt(1, user.getUserId());
			cs.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public int get_User_Count() {
		int count = 0;
		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement("select count(*) from user");
				ResultSet rs = ps.executeQuery()) {
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}

	@Override
	public int get_Role_Count() {
		int count = 0;
		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement("select count(*) from role");
				ResultSet rs = ps.executeQuery()) {
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return count;
	}

	@Override
	public User get_Profile_Details(int userId) {
		User user = null;
		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(
						"select user_id, name, email, role_id, role_name from v_profile_details where user_id = ?")) {
			ps.setInt(1, userId);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					user = new User();
					user.setUserId(rs.getInt("user_id"));
					user.setName(rs.getString("name"));
					user.setEmail(rs.getString("email"));
					user.setRoleId(rs.getInt("role_id"));
					user.setRoleName(rs.getString("role_name"));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return user;
	}

	private User get_User_By_Email(String email) {
		User user = null;
		try (Connection con = GetConnection.getConnection();
				PreparedStatement ps = con.prepareStatement(
						"select user_id, name, email, role_id, role_name from v_profile_details where email = ?")) {
			ps.setString(1, email);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					user = new User();
					user.setUserId(rs.getInt("user_id"));
					user.setName(rs.getString("name"));
					user.setEmail(rs.getString("email"));
					user.setRoleId(rs.getInt("role_id"));
					user.setRoleName(rs.getString("role_name"));
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return user;
	}
}
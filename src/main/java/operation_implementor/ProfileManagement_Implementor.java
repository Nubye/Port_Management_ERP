package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import db_config.GetConnection;
import model.ProfileManagement;
import operations.ProfileManagement_Operation;

public class ProfileManagement_Implementor implements ProfileManagement_Operation {

	private String message;

	@Override
	public ProfileManagement getProfileDetails(int userId) {
		message = null;
		ProfileManagement profile = null;
		String sql = "SELECT user_id, name, email, role_id, role_name FROM v_profile_details WHERE user_id = ?";

		try (Connection conn = GetConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setInt(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					profile = new ProfileManagement();
					profile.setUserId(rs.getInt("user_id"));
					profile.setName(rs.getString("name"));
					profile.setEmail(rs.getString("email"));
					profile.setRoleId(rs.getInt("role_id"));
					profile.setRoleName(rs.getString("role_name"));
				}
			}
		} catch (Exception e) {
			message = e.getMessage();
			e.printStackTrace();
		}

		return profile;
	}

	@Override
	public int updateProfileName(ProfileManagement profile) {
		message = null;
		String sql = "{call sp_update_profile_name(?,?)}";

		try (Connection conn = GetConnection.getConnection(); CallableStatement cs = conn.prepareCall(sql)) {

			cs.setInt(1, profile.getUserId());
			cs.setString(2, profile.getName());
			return cs.executeUpdate();

		} catch (Exception e) {
			message = e.getMessage();
			e.printStackTrace();
			return 0;
		}
	}

	@Override
	public int changeEmail(ProfileManagement profile) {
		message = null;
		String sql = "{call sp_change_email(?,?)}";

		try (Connection conn = GetConnection.getConnection(); CallableStatement cs = conn.prepareCall(sql)) {

			cs.setInt(1, profile.getUserId());
			cs.setString(2, profile.getEmail());
			return cs.executeUpdate();

		} catch (Exception e) {
			message = e.getMessage();
			e.printStackTrace();
			return 0;
		}
	}

	@Override
	public int changePassword(int userId, String currentPassword, String newPassword) {
		message = null;

		String getPasswordSql = "SELECT password FROM user WHERE user_id = ?";
		String updatePasswordSql = "{call sp_change_password(?,?)}";

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(getPasswordSql)) {

			ps.setInt(1, userId);

			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next()) {
					message = "User not found.";
					return 0;
				}

				String storedPassword = rs.getString("password");

				if (storedPassword == null || storedPassword.trim().isEmpty()) {
					message = "Stored password is invalid.";
					return 0;
				}

				if (!storedPassword.equals(currentPassword)) {
					message = "Current password is incorrect.";
					return 0;
				}
			}

			try (CallableStatement cs = conn.prepareCall(updatePasswordSql)) {
				cs.setInt(1, userId);
				cs.setString(2, newPassword);
				return cs.executeUpdate();
			}

		} catch (Exception e) {
			message = e.getMessage();
			e.printStackTrace();
			return 0;
		}
	}

	@Override
	public String getMessage() {
		return message;
	}
}
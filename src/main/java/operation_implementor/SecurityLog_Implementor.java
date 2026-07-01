package operation_implementor;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import db_config.GetConnection;
import model.SecurityLog;
import operations.SecurityLog_Operation;

public class SecurityLog_Implementor implements SecurityLog_Operation {

	@Override
	public void openSession(SecurityLog securityLog) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call sp_session_open(?,?)}")) {
			cs.setInt(1, securityLog.getUserid());
			cs.registerOutParameter(2, java.sql.Types.INTEGER);
			cs.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void closeSession(SecurityLog securityLog) {
		try (Connection conn = GetConnection.getConnection();
				CallableStatement cs = conn.prepareCall("{call sp_session_close(?)}")) {
			cs.setInt(1, securityLog.getLogid());
			cs.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	@Override
	public ArrayList<SecurityLog> getSecurityLogs(String username, String role, String fromDate, String toDate) {
		ArrayList<SecurityLog> list = new ArrayList<>();

		StringBuilder sql = new StringBuilder("SELECT * FROM v_security_log WHERE 1=1");

		if (username != null && !username.isEmpty())
			sql.append(" AND username LIKE ?");
		if (role != null && !role.equals("Select Role") && !role.isEmpty())
			sql.append(" AND role_name = ?");
		if (fromDate != null && !fromDate.isEmpty())
			sql.append(" AND DATE(entry_time) >= ?");
		if (toDate != null && !toDate.isEmpty())
			sql.append(" AND DATE(entry_time) <= ?");
		sql.append(" ORDER BY entry_time DESC, log_id DESC");

		try (Connection conn = GetConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql.toString())) {

			int i = 1;
			if (username != null && !username.isEmpty())
				ps.setString(i++, "%" + username + "%");
			if (role != null && !role.equals("Select Role") && !role.isEmpty())
				ps.setString(i++, role);
			if (fromDate != null && !fromDate.isEmpty())
				ps.setString(i++, fromDate);
			if (toDate != null && !toDate.isEmpty())
				ps.setString(i++, toDate);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					SecurityLog log = new SecurityLog();
					log.setLogid(rs.getInt("log_id"));
					log.setUsername(rs.getString("username"));
					log.setRoleName(rs.getString("role_name"));
					log.setEntryTime(rs.getTimestamp("entry_time"));
					log.setExitTime(rs.getTimestamp("exit_time"));
					log.setSessionDuration(rs.getInt("session_duration"));
					list.add(log);
				}
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return list;
	}
}
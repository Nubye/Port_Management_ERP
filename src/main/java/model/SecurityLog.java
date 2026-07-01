package model;

import java.sql.Timestamp;
import java.util.ArrayList;

import operation_implementor.SecurityLog_Implementor;

public class SecurityLog {

	private int logid;
	private int userid;
	private String username;
	private String roleName;
	private Timestamp entryTime;
	private Timestamp exitTime;
	private int sessionDuration;

	public int getLogid() {
		return logid;
	}

	public void setLogid(int logid) {
		this.logid = logid;
	}

	public int getUserid() {
		return userid;
	}

	public void setUserid(int userid) {
		this.userid = userid;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getRoleName() {
		return roleName;
	}

	public void setRoleName(String roleName) {
		this.roleName = roleName;
	}

	public Timestamp getEntryTime() {
		return entryTime;
	}

	public void setEntryTime(Timestamp entryTime) {
		this.entryTime = entryTime;
	}

	public Timestamp getExitTime() {
		return exitTime;
	}

	public void setExitTime(Timestamp exitTime) {
		this.exitTime = exitTime;
	}

	public int getSessionDuration() {
		return sessionDuration;
	}

	public void setSessionDuration(int sessionDuration) {
		this.sessionDuration = sessionDuration;
	}

	private final SecurityLog_Implementor implementor = new SecurityLog_Implementor();

	public void openSession(SecurityLog securityLog) {
		implementor.openSession(securityLog);
	}

	public void closeSession(SecurityLog securityLog) {
		implementor.closeSession(securityLog);
	}

	public ArrayList<SecurityLog> getSecurityLogs(String username, String role, String fromDate, String toDate) {
		return implementor.getSecurityLogs(username, role, fromDate, toDate);
	}
}
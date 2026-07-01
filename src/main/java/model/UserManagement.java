package model;

import java.util.ArrayList;
import java.util.HashMap;
import operation_implementor.UserManagement_Implementor;

public class UserManagement {
	private int adminId;
	private int userId;
	private String name;
	private String email;
	private String password;
	private int roleId;
	private String status;

	UserManagement_Implementor implementor = new UserManagement_Implementor();

	public int getAdminId() {
		return adminId;
	}

	public void setAdminId(int adminId) {
		this.adminId = adminId;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public int getRoleId() {
		return roleId;
	}

	public void setRoleId(int roleId) {
		this.roleId = roleId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public void add_User(UserManagement um) {
		implementor.add_User(um);
	}

	public void update_User(UserManagement um) {
		implementor.update_User(um);
	}

	public void deactivate_User(UserManagement um) {
		implementor.deactivate_User(um);
	}

	public void activate_User(UserManagement um) {
		implementor.activate_User(um);
	}

	public ArrayList<HashMap<String, String>> get_All_Users() {
		return implementor.get_All_Users();
	}

	public ArrayList<HashMap<String, String>> get_Roles() {
		return implementor.get_Roles();
	}

	public ArrayList<HashMap<String, String>> search_Users(String search) {
		return implementor.search_Users(search);
	}
}
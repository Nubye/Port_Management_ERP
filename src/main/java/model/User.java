package model;

import operation_implementor.User_Implementor;

public class User {
	private int userId;
	private String name;
	private String email;
	private String password;
	private int roleId;
	private String roleName;

	User_Implementor implementor = new User_Implementor();

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

	public String getRoleName() {
		return roleName;
	}

	public void setRoleName(String roleName) {
		this.roleName = roleName;
	}

	public User login_User(User user) {
		return implementor.login_User(user);
	}

	public void logout_User(User user) {
		implementor.logout_User(user);
	}

	public int get_User_Count() {
		return implementor.get_User_Count();
	}

	public int get_Role_Count() {
		return implementor.get_Role_Count();
	}

	public User get_Profile_Details(int userId) {
		return implementor.get_Profile_Details(userId);
	}
}
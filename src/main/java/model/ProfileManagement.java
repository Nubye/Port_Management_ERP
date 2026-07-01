package model;

import operation_implementor.ProfileManagement_Implementor;

public class ProfileManagement {

	private int userId;
	private String name;
	private String email;
	private int roleId;
	private String roleName;
	private String message;

	private ProfileManagement_Implementor impl = new ProfileManagement_Implementor();

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

	public String getMessage() {
		return message;
	}

	public ProfileManagement getProfileDetails(int userId) {
		ProfileManagement profile = impl.getProfileDetails(userId);
		this.message = impl.getMessage();
		return profile;
	}

	public int updateProfileName(ProfileManagement profile) {
		int result = impl.updateProfileName(profile);
		this.message = impl.getMessage();
		return result;
	}

	public int changeEmail(ProfileManagement profile) {
		int result = impl.changeEmail(profile);
		this.message = impl.getMessage();
		return result;
	}

	public int changePassword(int userId, String currentPassword, String newPassword) {
		int result = impl.changePassword(userId, currentPassword, newPassword);
		this.message = impl.getMessage();
		return result;
	}
}
package operations;

import model.ProfileManagement;

public interface ProfileManagement_Operation {
	ProfileManagement getProfileDetails(int userId);

	int updateProfileName(ProfileManagement profile);

	int changeEmail(ProfileManagement profile);

	int changePassword(int userId, String currentPassword, String newPassword);

	String getMessage();
}
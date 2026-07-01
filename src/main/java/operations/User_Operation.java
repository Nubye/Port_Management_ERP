package operations;

import model.User;

public interface User_Operation {
	User login_User(User user);

	void logout_User(User user);

	int get_User_Count();

	int get_Role_Count();

	User get_Profile_Details(int userId);
}
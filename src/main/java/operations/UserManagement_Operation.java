package operations;

import java.util.ArrayList;
import java.util.HashMap;
import model.UserManagement;

public interface UserManagement_Operation {
	void add_User(UserManagement um);

	void update_User(UserManagement um);

	void deactivate_User(UserManagement um);

	void activate_User(UserManagement um);

	ArrayList<HashMap<String, String>> get_All_Users();

	ArrayList<HashMap<String, String>> get_Roles();

	ArrayList<HashMap<String, String>> search_Users(String search);
}
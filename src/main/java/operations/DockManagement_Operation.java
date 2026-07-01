package operations;

import java.util.ArrayList;
import java.util.HashMap;
import model.DockManagement;

public interface DockManagement_Operation {
	int addDock(DockManagement dock);

	int updateDock(DockManagement dock);

	int deleteDock(int dockId);

	ArrayList<HashMap<String, String>> showDock();

	ArrayList<HashMap<String, String>> searchDock(String dockName, String status);

	String getMessage();
}
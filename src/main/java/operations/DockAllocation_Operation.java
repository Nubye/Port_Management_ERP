package operations;

import java.util.ArrayList;
import java.util.HashMap;
import model.DockAllocation;

public interface DockAllocation_Operation {
	void allocate_Dock(DockAllocation da);

	void release_Dock(DockAllocation da);

	void update_Allocation(DockAllocation da);

	void delete_Allocation(DockAllocation da);

	ArrayList<HashMap<String, String>> get_Available_Docks();

	ArrayList<HashMap<String, String>> get_Available_Ships();

	ArrayList<HashMap<String, String>> get_Active_Allocations();

	ArrayList<HashMap<String, String>> get_All_Allocations(String statusFilter);

	ArrayList<HashMap<String, String>> search_All_Allocations(String search, String statusFilter);
}
package operations;

import java.util.ArrayList;
import java.util.HashMap;

import model.ContainerManagement;

public interface ContainerManagement_Operation {
	boolean add_Container(ContainerManagement container);

	boolean update_Container(ContainerManagement container);

	boolean delete_Container(int containerId);

	ArrayList<HashMap<String, String>> search_Containers(Integer containerId, String containerType, String status,
			String shipName);

	ArrayList<HashMap<String, String>> get_All_Ships();

	HashMap<String, String> get_Container_By_Id(int containerId);

	ArrayList<HashMap<String, String>> sortContainersByIdDesc(ArrayList<HashMap<String, String>> list);

	HashMap<String, Integer> getContainerStats(ArrayList<HashMap<String, String>> allContainers);
}
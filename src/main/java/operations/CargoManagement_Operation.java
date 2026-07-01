package operations;

import java.util.ArrayList;
import java.util.HashMap;

import model.CargoManagement;

public interface CargoManagement_Operation {

	boolean add_Cargo(CargoManagement cargo);

	boolean update_Cargo(CargoManagement cargo);

	boolean delete_Cargo(CargoManagement cargo);

	ArrayList<HashMap<String, String>> search_Cargo(String keyword);

	ArrayList<HashMap<String, String>> get_Cargo_Details();

	ArrayList<HashMap<String, String>> get_Pending_Cargo_Movements();

	ArrayList<HashMap<String, String>> get_Containers();
}
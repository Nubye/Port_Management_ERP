package operations;

import java.util.ArrayList;
import java.util.HashMap;
import model.CargoMovement;

public interface CargoMovement_Operation {
	boolean log_Cargo_Movement(CargoMovement cargo);

	ArrayList<HashMap<String, String>> get_Cargo_Movement_History();

	ArrayList<HashMap<String, String>> get_Cargo_History(int cargoId);

	ArrayList<HashMap<String, String>> get_Cargo_Details();

	ArrayList<HashMap<String, String>> get_Users();

	boolean ensure_Cargo_Movement_Handler(int cargoId, String movementType, int handledBy);
}

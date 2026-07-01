package operations;

import java.util.ArrayList;
import java.util.HashMap;

import model.ShipManagement;

public interface ShipManagement_Operation {

	int addShip(ShipManagement ship);

	int updateShip(ShipManagement ship);

	int deleteShip(ShipManagement ship);

	ArrayList<HashMap<String, String>> getAllShips();

	ArrayList<HashMap<String, String>> getOperators();

	ArrayList<HashMap<String, String>> searchShips(String shipName, String operatorName, String status);

	HashMap<String, Integer> getShipStatusCounts(ArrayList<HashMap<String, String>> shipList);

	String getMessage();

	boolean isValidOperator(int operatorId);
}
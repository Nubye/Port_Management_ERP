package model;

import java.util.ArrayList;
import java.util.HashMap;

import operation_implementor.CargoMovement_Implementor;

public class CargoMovement {

	private int cargoId;
	private int movementId;
	private String movementType;
	private String movementDate;
	private int handledBy;

	private final CargoMovement_Implementor implementor = new CargoMovement_Implementor();

	public int getCargoId() {
		return cargoId;
	}

	public void setCargoId(int cargoId) {
		this.cargoId = cargoId;
	}

	public int getMovementId() {
		return movementId;
	}

	public void setMovementId(int movementId) {
		this.movementId = movementId;
	}

	public String getMovementType() {
		return movementType;
	}

	public void setMovementType(String movementType) {
		this.movementType = movementType;
	}

	public String getMovementDate() {
		return movementDate;
	}

	public void setMovementDate(String movementDate) {
		this.movementDate = movementDate;
	}

	public int getHandledBy() {
		return handledBy;
	}

	public void setHandledBy(int handledBy) {
		this.handledBy = handledBy;
	}

	public boolean log_Cargo_Movement(CargoMovement cargo) {
		return implementor.log_Cargo_Movement(cargo);
	}

	public ArrayList<HashMap<String, String>> get_Cargo_Movement_History() {
		return implementor.get_Cargo_Movement_History();
	}

	public ArrayList<HashMap<String, String>> get_Cargo_History(int cargoId) {
		return implementor.get_Cargo_History(cargoId);
	}

	public ArrayList<HashMap<String, String>> get_Cargo_Details() {
		return implementor.get_Cargo_Details();
	}

	public ArrayList<HashMap<String, String>> get_Users() {
		return implementor.get_Users();
	}

	public boolean ensure_Cargo_Movement_Handler(int cargoId, String movementType, int handledBy) {
		return implementor.ensure_Cargo_Movement_Handler(cargoId, movementType, handledBy);
	}
}

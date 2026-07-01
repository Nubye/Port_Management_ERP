package model;

import java.util.ArrayList;
import java.util.HashMap;

import operation_implementor.CargoManagement_Implementor;

public class CargoManagement {

	private int cargoId;
	private int containerId;
	private String description;
	private double weight;
	private String status;
	private String keyword;

	private final CargoManagement_Implementor implementor = new CargoManagement_Implementor();

	public int getCargoId() {
		return cargoId;
	}

	public void setCargoId(int cargoId) {
		this.cargoId = cargoId;
	}

	public int getContainerId() {
		return containerId;
	}

	public void setContainerId(int containerId) {
		this.containerId = containerId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public double getWeight() {
		return weight;
	}

	public void setWeight(double weight) {
		this.weight = weight;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getKeyword() {
		return keyword;
	}

	public void setKeyword(String keyword) {
		this.keyword = keyword;
	}

	public boolean add_Cargo(CargoManagement cargo) {
		return implementor.add_Cargo(cargo);
	}

	public boolean update_Cargo(CargoManagement cargo) {
		return implementor.update_Cargo(cargo);
	}

	public boolean delete_Cargo(CargoManagement cargo) {
		return implementor.delete_Cargo(cargo);
	}

	public ArrayList<HashMap<String, String>> search_Cargo(String keyword) {
		return implementor.search_Cargo(keyword);
	}

	public ArrayList<HashMap<String, String>> get_Cargo_Details() {
		return implementor.get_Cargo_Details();
	}

	public ArrayList<HashMap<String, String>> get_Pending_Cargo_Movements() {
		return implementor.get_Pending_Cargo_Movements();
	}

	public ArrayList<HashMap<String, String>> get_Containers() {
		return implementor.get_Containers();
	}
}
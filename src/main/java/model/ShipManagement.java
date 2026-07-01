package model;

import java.util.ArrayList;
import java.util.HashMap;

import operation_implementor.ShipManagement_Implementor;

public class ShipManagement {

	private int shipId;
	private String shipName;
	private int operatorId;
	private String arrivalDate;
	private String departureDate;
	private String status;
	private int roleId;
	private String message;

	public int addShip(ShipManagement ship) {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		int result = impl.addShip(ship);
		this.message = impl.getMessage();
		return result;
	}

	public int updateShip(ShipManagement ship) {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		int result = impl.updateShip(ship);
		this.message = impl.getMessage();
		return result;
	}

	public int deleteShip(ShipManagement ship) {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		int result = impl.deleteShip(ship);
		this.message = impl.getMessage();
		return result;
	}

	public ArrayList<HashMap<String, String>> getAllShips() {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		return impl.getAllShips();
	}

	public ArrayList<HashMap<String, String>> getOperators() {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		return impl.getOperators();
	}

	public ArrayList<HashMap<String, String>> searchShips(String shipName, String operatorName, String status) {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		return impl.searchShips(shipName, operatorName, status);
	}

	public HashMap<String, Integer> getShipStatusCounts(ArrayList<HashMap<String, String>> shipList) {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		return impl.getShipStatusCounts(shipList);
	}

	public int getShipId() {
		return shipId;
	}

	public void setShipId(int shipId) {
		this.shipId = shipId;
	}

	public String getShipName() {
		return shipName;
	}

	public void setShipName(String shipName) {
		this.shipName = shipName;
	}

	public int getOperatorId() {
		return operatorId;
	}

	public void setOperatorId(int operatorId) {
		this.operatorId = operatorId;
	}

	public String getArrivalDate() {
		return arrivalDate;
	}

	public void setArrivalDate(String arrivalDate) {
		this.arrivalDate = arrivalDate;
	}

	public String getDepartureDate() {
		return departureDate;
	}

	public void setDepartureDate(String departureDate) {
		this.departureDate = departureDate;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public int getRoleId() {
		return roleId;
	}

	public void setRoleId(int roleId) {
		this.roleId = roleId;
	}

	public String getMessage() {
		return message;
	}

	public boolean isValidOperator(int operatorId) {
		ShipManagement_Implementor impl = new ShipManagement_Implementor();
		return impl.isValidOperator(operatorId);
	}
}
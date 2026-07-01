package model;

import java.util.ArrayList;
import java.util.HashMap;

import operation_implementor.ContainerManagement_Implementor;
import operations.ContainerManagement_Operation;

public class ContainerManagement {
	private int containerId;
	private String containerType;
	private String status;
	private int shipId;

	private final ContainerManagement_Operation operation = new ContainerManagement_Implementor();

	public int getContainerId() {
		return containerId;
	}

	public void setContainerId(int containerId) {
		this.containerId = containerId;
	}

	public String getContainerType() {
		return containerType;
	}

	public void setContainerType(String containerType) {
		this.containerType = containerType;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public int getShipId() {
		return shipId;
	}

	public void setShipId(int shipId) {
		this.shipId = shipId;
	}

	public boolean add_Container(ContainerManagement container) {
		return operation.add_Container(container);
	}

	public boolean update_Container(ContainerManagement container) {
		return operation.update_Container(container);
	}

	public boolean delete_Container(int containerId) {
		return operation.delete_Container(containerId);
	}

	public ArrayList<HashMap<String, String>> search_Containers(Integer containerId, String containerType,
			String status, String shipName) {
		return operation.search_Containers(containerId, containerType, status, shipName);
	}

	public ArrayList<HashMap<String, String>> get_All_Ships() {
		return operation.get_All_Ships();
	}

	public HashMap<String, String> get_Container_By_Id(int containerId) {
		return operation.get_Container_By_Id(containerId);
	}

	public ArrayList<HashMap<String, String>> sortContainersByIdDesc(ArrayList<HashMap<String, String>> list) {
		return operation.sortContainersByIdDesc(list);
	}

	public HashMap<String, Integer> getContainerStats(ArrayList<HashMap<String, String>> allContainers) {
		return operation.getContainerStats(allContainers);
	}
}
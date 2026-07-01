package model;

import java.util.ArrayList;
import java.util.HashMap;
import operation_implementor.DockAllocation_Implementor;

public class DockAllocation {
	private int allocationId;
	private int shipId;
	private int dockId;
	private String allocationTime;
	private String releaseTime;

	DockAllocation_Implementor implementor = new DockAllocation_Implementor();

	public int getAllocationId() {
		return allocationId;
	}

	public void setAllocationId(int allocationId) {
		this.allocationId = allocationId;
	}

	public int getShipId() {
		return shipId;
	}

	public void setShipId(int shipId) {
		this.shipId = shipId;
	}

	public int getDockId() {
		return dockId;
	}

	public void setDockId(int dockId) {
		this.dockId = dockId;
	}

	public String getAllocationTime() {
		return allocationTime;
	}

	public void setAllocationTime(String allocationTime) {
		this.allocationTime = allocationTime;
	}

	public String getReleaseTime() {
		return releaseTime;
	}

	public void setReleaseTime(String releaseTime) {
		this.releaseTime = releaseTime;
	}

	public void allocate_Dock(DockAllocation da) {
		implementor.allocate_Dock(da);
	}

	public void release_Dock(DockAllocation da) {
		implementor.release_Dock(da);
	}

	public void update_Allocation(DockAllocation da) {
		implementor.update_Allocation(da);
	}

	public void delete_Allocation(DockAllocation da) {
		implementor.delete_Allocation(da);
	}

	public ArrayList<HashMap<String, String>> get_Available_Ships() {
		return implementor.get_Available_Ships();
	}

	public ArrayList<HashMap<String, String>> get_Available_Docks() {
		return implementor.get_Available_Docks();
	}

	public ArrayList<HashMap<String, String>> get_Active_Allocations() {
		return implementor.get_Active_Allocations();
	}

	public ArrayList<HashMap<String, String>> get_All_Allocations(String statusFilter) {
		return implementor.get_All_Allocations(statusFilter);
	}

	public ArrayList<HashMap<String, String>> search_All_Allocations(String search, String statusFilter) {
		return implementor.search_All_Allocations(search, statusFilter);
	}
}
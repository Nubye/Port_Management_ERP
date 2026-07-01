package model;

import java.util.ArrayList;
import java.util.HashMap;
import operation_implementor.DockManagement_Implementor;

public class DockManagement {
	private int dockId;
	private String dockName;
	private String status;
	private String shipName;
	private String message;

	DockManagement_Implementor impl = new DockManagement_Implementor();

	public int getDockId() {
		return dockId;
	}

	public void setDockId(int dockId) {
		this.dockId = dockId;
	}

	public String getDockName() {
		return dockName;
	}

	public void setDockName(String dockName) {
		this.dockName = dockName;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getShipName() {
		return shipName;
	}

	public void setShipName(String shipName) {
		this.shipName = shipName;
	}

	public String getMessage() {
		return message;
	}

	public int addDock(DockManagement dock) {
		int result = impl.addDock(dock);
		this.message = impl.getMessage();
		return result;
	}

	public int updateDock(DockManagement dock) {
		int result = impl.updateDock(dock);
		this.message = impl.getMessage();
		return result;
	}

	public int deleteDock(int dockId) {
		int result = impl.deleteDock(dockId);
		this.message = impl.getMessage();
		return result;
	}

	public ArrayList<HashMap<String, String>> showDock() {
		return impl.showDock();
	}

	public ArrayList<HashMap<String, String>> searchDock(String dockName, String status) {
		return impl.searchDock(dockName, status);
	}
}
package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CargoManagement;
import model.CargoMovement;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/CargoManagementController")
public class CargoManagementController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp);
		if (loggedUser == null)
			return;
		loadCargoPage(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp);
		if (loggedUser == null) {
			return;
		}

		CargoManagement cargo = new CargoManagement();

		String action = ControllerSupport.value(req.getParameter("action"));
		String add = req.getParameter("add");
		String update = req.getParameter("update");
		String delete = req.getParameter("delete");

		String successMessage = null;
		String errorMessage = null;
		String redirectUrl = "CargoManagementController";

		try {
			if ("add".equalsIgnoreCase(action) || add != null) {
				cargo.setContainerId(ControllerSupport.parseInt(ControllerSupport
						.firstNonEmpty(req.getParameter("container_id"), req.getParameter("containerId"))));
				cargo.setDescription(ControllerSupport.value(req.getParameter("description")));
				cargo.setWeight(ControllerSupport.parseDouble(req.getParameter("weight")));
				cargo.setStatus(ControllerSupport.value(req.getParameter("status")));

				boolean result = cargo.add_Cargo(cargo);
				if (result)
					successMessage = "Cargo added successfully.";
				else
					errorMessage = "Failed to add cargo.";

			} else if ("update".equalsIgnoreCase(action) || update != null) {
				int cargoId = ControllerSupport.parseInt(
						ControllerSupport.firstNonEmpty(req.getParameter("cargo_id"), req.getParameter("cargoId")));
				cargo.setCargoId(cargoId);
				cargo.setDescription(ControllerSupport.value(req.getParameter("description")));
				cargo.setWeight(ControllerSupport.parseDouble(req.getParameter("weight")));
				String newStatus = ControllerSupport.value(req.getParameter("status"));
				String previousStatus = ControllerSupport.value(req.getParameter("previous_status"));
				cargo.setStatus(newStatus);

				boolean result = cargo.update_Cargo(cargo);
				if (result) {
					boolean statusChanged = !newStatus.isEmpty() && !newStatus.equalsIgnoreCase(previousStatus);

					if (statusChanged) {
						int handlerId = loggedUser.getUserId();
						if (handlerId <= 0) {
							errorMessage = "Invalid logged-in user session.";
						} else {
							String movementType = movementTypeForStatus(newStatus);
							if (movementType.isEmpty()) {
								errorMessage = "Invalid cargo status for movement logging.";
							} else {
								CargoMovement movement = new CargoMovement();
								boolean logged = movement.ensure_Cargo_Movement_Handler(cargoId, movementType,
										handlerId);
								if (!logged) {
									errorMessage = "Cargo updated, but failed to log movement handler.";
								}
							}
						}
					}

					if (errorMessage == null) {
						successMessage = "Cargo updated successfully.";
					}
				} else {
					errorMessage = "Failed to update cargo.";
				}

				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("keyword_search")),
						ControllerSupport.value(req.getParameter("status_search")));

			} else if ("delete".equalsIgnoreCase(action) || delete != null) {
				cargo.setCargoId(ControllerSupport.parseInt(
						ControllerSupport.firstNonEmpty(req.getParameter("cargo_id"), req.getParameter("cargoId"))));

				boolean result = cargo.delete_Cargo(cargo);
				if (result)
					successMessage = "Cargo deleted successfully.";
				else
					errorMessage = "Failed to delete cargo.";

				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("keyword_search")),
						ControllerSupport.value(req.getParameter("status_search")));
			} else {
				errorMessage = "Invalid action.";
			}
		} catch (Exception e) {
			errorMessage = e.getMessage();
			e.printStackTrace();
		}

		if (successMessage != null)
			session.setAttribute("flash_message", successMessage);
		if (errorMessage != null)
			session.setAttribute("flash_error", errorMessage);

		resp.sendRedirect(redirectUrl);
	}

	private void loadCargoPage(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		CargoManagement cargo = new CargoManagement();

		String keyword = ControllerSupport.value(req.getParameter("keyword"));
		String status = ControllerSupport.value(req.getParameter("status"));

		ArrayList<HashMap<String, String>> cargoList;

		if (!keyword.isEmpty()) {
			cargoList = cargo.search_Cargo(keyword);
			req.setAttribute("searchKeyword", keyword);
		} else {
			cargoList = cargo.get_Cargo_Details();
			req.setAttribute("searchKeyword", "");
		}

		if (!status.isEmpty() && cargoList != null) {
			ArrayList<HashMap<String, String>> filteredList = new ArrayList<>();
			for (HashMap<String, String> item : cargoList) {
				String cargoStatus = item.get("cargo_status");
				if (cargoStatus != null && cargoStatus.equalsIgnoreCase(status)) {
					filteredList.add(item);
				}
			}
			cargoList = filteredList;
			req.setAttribute("selectedStatus", status);
		} else {
			req.setAttribute("selectedStatus", "");
		}

		ArrayList<HashMap<String, String>> containerList = cargo.get_Containers();
		ArrayList<HashMap<String, String>> pendingList = cargo.get_Pending_Cargo_Movements();

		req.setAttribute("cargoList", cargoList);
		req.setAttribute("containerList", containerList);
		req.setAttribute("pendingList", pendingList);

		ControllerSupport.applyFlash(req, req.getSession(false));

		req.getRequestDispatcher("/cargo-management.jsp").forward(req, resp);
	}

	private String buildRedirectUrl(String keyword, String status) throws IOException {
		StringBuilder url = new StringBuilder("CargoManagementController");

		boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
		boolean hasStatus = status != null && !status.trim().isEmpty();

		if (hasKeyword || hasStatus) {
			url.append("?");
			boolean first = true;
			if (hasKeyword) {
				url.append("keyword=").append(URLEncoder.encode(keyword.trim(), "UTF-8"));
				first = false;
			}
			if (hasStatus) {
				if (!first)
					url.append("&");
				url.append("status=").append(URLEncoder.encode(status.trim(), "UTF-8"));
			}
		}

		return url.toString();
	}

	private String movementTypeForStatus(String status) {
		if ("Loaded".equalsIgnoreCase(status))
			return "Load";
		if ("Unloaded".equalsIgnoreCase(status))
			return "Unload";
		if ("In Transit".equalsIgnoreCase(status))
			return "Transfer";
		return "";
	}
}

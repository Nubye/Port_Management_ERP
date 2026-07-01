package controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.ShipManagement;
import model.User;

@WebServlet("/ShipManagementController")
public class ShipManagementController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp, 1, 2, 3);
		if (loggedUser == null)
			return;
		loadPage(req, resp, loggedUser);
	}

	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp, 1, 2, 3);
		if (loggedUser == null) {
			return;
		}

		ShipManagement ship = new ShipManagement();
		String action = ControllerSupport.value(req.getParameter("action"));
		String success = null;
		String error = null;
		String redirectUrl = "ShipManagementController";

		try {
			if ("add".equals(action)) {
				ship.setShipName(req.getParameter("ship_name"));
				ship.setArrivalDate(req.getParameter("arrival_date"));
				ship.setDepartureDate(req.getParameter("departure_date"));
				ship.setStatus(req.getParameter("status"));

				int sessionUserId = 0;

				try {
					sessionUserId = loggedUser.getUserId();
				} catch (Exception e) {
					error = "Unable to identify logged-in user.";
				}

				System.out.println("SESSION USER ID = " + sessionUserId);
				System.out.println("SESSION ROLE ID = " + loggedUser.getRoleId());

				if (error == null) {
					if (sessionUserId <= 0) {
						error = "Invalid logged-in user session.";
					} else if (!ship.isValidOperator(sessionUserId)) {
						error = "Logged-in user does not exist in user table.";
					} else {
						ship.setOperatorId(sessionUserId);

						int result = ship.addShip(ship);
						if (result > 0)
							success = "Ship added successfully.";
						else
							error = ship.getMessage();
					}
				}

			} else if ("update".equals(action)) {
				ship.setShipId(ControllerSupport.parseInt(req.getParameter("ship_id")));
				ship.setShipName(req.getParameter("ship_name"));
				ship.setArrivalDate(req.getParameter("arrival_date"));
				ship.setDepartureDate(req.getParameter("departure_date"));
				ship.setStatus(req.getParameter("status"));

				int result = ship.updateShip(ship);
				if (result > 0)
					success = "Ship updated successfully.";
				else
					error = ship.getMessage();

				String shipNameSearch = ControllerSupport.value(req.getParameter("ship_name_search"));
				String statusSearch = ControllerSupport.value(req.getParameter("status_search"));
				redirectUrl = buildRedirectUrl(shipNameSearch, statusSearch);

			} else if ("delete".equals(action)) {
				ship.setShipId(ControllerSupport.parseInt(req.getParameter("ship_id")));
				ship.setRoleId(loggedUser.getRoleId());

				int result = ship.deleteShip(ship);
				if (result > 0)
					success = "Ship deleted successfully.";
				else
					error = ship.getMessage();

				String shipNameSearch = ControllerSupport.value(req.getParameter("ship_name_search"));
				String statusSearch = ControllerSupport.value(req.getParameter("status_search"));
				redirectUrl = buildRedirectUrl(shipNameSearch, statusSearch);
			}

		} catch (Exception e) {
			error = "Error: " + e.getMessage();
			e.printStackTrace();
		}

		ControllerSupport.setFlash(session, success, error);

		resp.sendRedirect(redirectUrl);
	}

	private void loadPage(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
			throws ServletException, IOException {

		int roleId = loggedUser.getRoleId();

		ShipManagement ship = new ShipManagement();

		String action = ControllerSupport.value(req.getParameter("action"));
		String shipNameSearch = ControllerSupport.value(req.getParameter("ship_name"));
		String statusSearch = ControllerSupport.value(req.getParameter("status"));
		String editId = ControllerSupport.value(req.getParameter("editId"));

		ArrayList<HashMap<String, String>> shipList;
		if ("search".equals(action)) {
			shipList = ship.searchShips(shipNameSearch, "", statusSearch);
		} else {
			shipList = ship.getAllShips();
		}

		HashMap<String, Integer> counts = ship.getShipStatusCounts(shipList);

		req.setAttribute("shipList", shipList);
		req.setAttribute("ship_name", shipNameSearch);
		req.setAttribute("status", statusSearch);
		req.setAttribute("editId", editId);
		req.setAttribute("anchoredCount", counts.get("Anchored"));
		req.setAttribute("dockedCount", counts.get("Docked"));
		req.setAttribute("departedCount", counts.get("Departed"));
		req.setAttribute("canDelete", roleId == 1 || roleId == 2 || roleId == 3);

		ControllerSupport.applyFlash(req, req.getSession(false));

		req.getRequestDispatcher("/ship-management.jsp").forward(req, resp);
	}

	private String buildRedirectUrl(String shipNameSearch, String statusSearch) throws IOException {
		StringBuilder url = new StringBuilder("ShipManagementController");

		boolean hasShip = shipNameSearch != null && !shipNameSearch.trim().isEmpty();
		boolean hasStatus = statusSearch != null && !statusSearch.trim().isEmpty();

		if (hasShip || hasStatus) {
			url.append("?action=search");

			if (hasShip) {
				url.append("&ship_name=").append(URLEncoder.encode(shipNameSearch, "UTF-8"));
			}

			if (hasStatus) {
				url.append("&status=").append(URLEncoder.encode(statusSearch, "UTF-8"));
			}
		}

		return url.toString();
	}
}
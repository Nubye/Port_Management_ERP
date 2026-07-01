package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ContainerManagement;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/ContainerManagementController")
public class ContainerManagementController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp, 1, 2, 3);
		if (loggedUser == null) {
			return;
		}

		int roleId = loggedUser.getRoleId();
		String editId = ControllerSupport.value(req.getParameter("editId"));
		if (!editId.isEmpty()) {
			loadPageForEdit(req, resp);
		} else {
			loadPage(req, resp);
		}
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp, 1, 2, 3);
		if (loggedUser == null) {
			return;
		}

		int roleId = loggedUser.getRoleId();
		ContainerManagement container = new ContainerManagement();

		String action = ControllerSupport.value(req.getParameter("action"));
		String message = null;
		String error = null;
		String redirectUrl = "ContainerManagementController";

		try {
			if ("add".equalsIgnoreCase(action)) {
				container.setContainerType(ControllerSupport.value(req.getParameter("containerType")));
				container.setStatus(ControllerSupport.value(req.getParameter("status")));
				container.setShipId(ControllerSupport.parseInt(req.getParameter("shipId")));

				boolean result = container.add_Container(container);
				if (result) {
					message = "Container added successfully.";
				} else {
					error = "Failed to add container.";
				}

			} else if ("update".equalsIgnoreCase(action)) {
				container.setContainerId(ControllerSupport.parseInt(req.getParameter("containerId")));
				container.setContainerType(ControllerSupport.value(req.getParameter("containerType")));
				container.setStatus(ControllerSupport.value(req.getParameter("status")));
				container.setShipId(ControllerSupport.parseInt(req.getParameter("shipId")));

				boolean result = container.update_Container(container);
				if (result) {
					message = "Container updated successfully.";
				} else {
					error = "Failed to update container.";
				}

				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("search_query")),
						ControllerSupport.value(req.getParameter("container_type_search")),
						ControllerSupport.value(req.getParameter("status_search")));

			} else if ("delete".equalsIgnoreCase(action)) {
				int containerId = ControllerSupport.parseInt(req.getParameter("containerId"));

				boolean result = container.delete_Container(containerId);
				if (result) {
					message = "Container deleted successfully.";
				} else {
					error = "Failed to delete container.";
				}

				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("search_query")),
						ControllerSupport.value(req.getParameter("container_type_search")),
						ControllerSupport.value(req.getParameter("status_search")));
			} else {
				error = "Invalid action.";
			}
		} catch (Exception e) {
			error = e.getMessage();
			e.printStackTrace();
		}

		if (message != null)
			session.setAttribute("flash_message", message);
		if (error != null)
			session.setAttribute("flash_error", error);

		resp.sendRedirect(redirectUrl);
	}

	private void loadPage(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		loadCommonPageData(req);
		req.getRequestDispatcher("/container_management.jsp").forward(req, resp);
	}

	private void loadPageForEdit(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		loadCommonPageData(req);
		req.setAttribute("editId", ControllerSupport.value(req.getParameter("editId")));
		req.getRequestDispatcher("/container_management.jsp").forward(req, resp);
	}

	private void loadCommonPageData(HttpServletRequest req) {
		ContainerManagement container = new ContainerManagement();

		String search = ControllerSupport.value(req.getParameter("search"));
		String containerType = ControllerSupport.value(req.getParameter("containerType"));
		String status = ControllerSupport.value(req.getParameter("status"));

		Integer containerId = null;
		String shipName = null;

		if (!search.isEmpty()) {
			try {
				containerId = Integer.parseInt(search);
			} catch (NumberFormatException e) {
				shipName = search;
			}
		}

		if (containerType.isEmpty())
			containerType = null;
		if (status.isEmpty())
			status = null;

		ArrayList<HashMap<String, String>> containerList = container.search_Containers(containerId, containerType,
				status, shipName);

		ArrayList<HashMap<String, String>> sortedContainerList = container.sortContainersByIdDesc(containerList);

		ArrayList<HashMap<String, String>> shipList = container.get_All_Ships();

		ArrayList<HashMap<String, String>> allContainers = container.search_Containers(null, null, null, null);

		HashMap<String, Integer> stats = container.getContainerStats(allContainers);

		ControllerSupport.applyFlash(req, req.getSession(false));

		req.setAttribute("containerList", sortedContainerList);
		req.setAttribute("shipList", shipList);
		req.setAttribute("totalContainers", stats.get("total"));
		req.setAttribute("loadedCount", stats.get("loaded"));
		req.setAttribute("transitCount", stats.get("transit"));
		req.setAttribute("filterSearch", search);
		req.setAttribute("filterContainerType", containerType != null ? containerType : "");
		req.setAttribute("filterStatus", status != null ? status : "");
		req.setAttribute("searchSuffix", buildSearchSuffix(search, containerType, status));
	}

	private String buildRedirectUrl(String search, String containerType, String status) {
		StringBuilder url = new StringBuilder("ContainerManagementController");
		String suffix = buildSearchSuffix(search, containerType, status);
		url.append(suffix);
		return url.toString();
	}

	private String buildSearchSuffix(String search, String containerType, String status) {
		StringBuilder suffix = new StringBuilder();
		boolean hasParam = false;

		try {
			if (search != null && !search.trim().isEmpty()) {
				suffix.append(hasParam ? "&" : "?").append("search=").append(URLEncoder.encode(search.trim(), "UTF-8"));
				hasParam = true;
			}

			if (containerType != null && !containerType.trim().isEmpty()) {
				suffix.append(hasParam ? "&" : "?").append("containerType=")
						.append(URLEncoder.encode(containerType.trim(), "UTF-8"));
				hasParam = true;
			}

			if (status != null && !status.trim().isEmpty()) {
				suffix.append(hasParam ? "&" : "?").append("status=").append(URLEncoder.encode(status.trim(), "UTF-8"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return suffix.toString();
	}
}
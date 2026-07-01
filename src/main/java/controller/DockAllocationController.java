package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.DockAllocation;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/DockAllocationController")
public class DockAllocationController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User loggedUser = requireLoggedUser(req, resp);
		if (loggedUser == null)
			return;

		HttpSession session = req.getSession(false);
		Integer roleId = loggedUser.getRoleId();
		String roleName = (String) session.getAttribute("roleName");
		if (roleName == null)
			roleName = "User";

		req.setAttribute("roleId", roleId);
		req.setAttribute("roleName", roleName);
		req.setAttribute("activePage", "dock-allocation");

		loadPage(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User loggedUser = requireLoggedUser(req, resp);
		if (loggedUser == null)
			return;

		DockAllocation da = new DockAllocation();

		String allocate = req.getParameter("allocate");
		String release = req.getParameter("release");
		String update = req.getParameter("update");
		String delete = req.getParameter("delete");

		String message = null;
		String error = null;
		String redirectUrl = "DockAllocationController";

		try {
			if (allocate != null) {
				da.setShipId(ControllerSupport.parseInt(req.getParameter("ship_id")));
				da.setDockId(ControllerSupport.parseInt(req.getParameter("dock_id")));
				da.setAllocationTime(normalizeDateTime(req.getParameter("allocation_time")));
				da.setReleaseTime(normalizeDateTime(req.getParameter("release_time")));
				da.allocate_Dock(da);
				message = "Dock allocated successfully.";

			} else if (release != null) {
				da.setAllocationId(ControllerSupport.parseInt(req.getParameter("allocation_id")));
				da.release_Dock(da);
				message = "Dock released successfully.";
				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("search")),
						ControllerSupport.value(req.getParameter("statusFilter")));

			} else if (update != null) {
				da.setAllocationId(ControllerSupport.parseInt(req.getParameter("allocation_id")));
				da.setDockId(ControllerSupport.parseInt(req.getParameter("dock_id")));
				da.update_Allocation(da);
				message = "Allocation updated successfully.";
				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("search")),
						ControllerSupport.value(req.getParameter("statusFilter")));

			} else if (delete != null) {
				da.setAllocationId(ControllerSupport.parseInt(req.getParameter("allocation_id")));
				da.delete_Allocation(da);
				message = "Allocation deleted successfully.";
				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("search")),
						ControllerSupport.value(req.getParameter("statusFilter")));
			}
		} catch (Exception e) {
			error = e.getMessage();
			e.printStackTrace();
		}

		HttpSession session = req.getSession();
		if (message != null)
			session.setAttribute("flash_message", message);
		if (error != null)
			session.setAttribute("flash_error", error);

		resp.sendRedirect(redirectUrl);
	}

	private User requireLoggedUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		HttpSession session = req.getSession(false);
		if (session == null) {
			resp.sendRedirect("login.jsp?error=session");
			return null;
		}

		User loggedUser = (User) session.getAttribute("loggedUser");
		if (loggedUser == null) {
			resp.sendRedirect("login.jsp?error=session");
			return null;
		}

		return loggedUser;
	}

	private void loadPage(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		DockAllocation da = new DockAllocation();

		ArrayList<HashMap<String, String>> shipList = da.get_Available_Ships();
		ArrayList<HashMap<String, String>> dockList = da.get_Available_Docks();

		String search = ControllerSupport.value(req.getParameter("search"));
		String statusFilter = ControllerSupport.value(req.getParameter("statusFilter"));
		if (statusFilter.isEmpty())
			statusFilter = "All";

		ArrayList<HashMap<String, String>> allocationList = da.search_All_Allocations(search, statusFilter);

		req.setAttribute("shipList", shipList);
		req.setAttribute("dockList", dockList);
		req.setAttribute("allocationList", allocationList);
		req.setAttribute("search", search);
		req.setAttribute("statusFilter", statusFilter);

		ControllerSupport.applyFlash(req, req.getSession(false));

		req.getRequestDispatcher("/dock-allocation.jsp").forward(req, resp);
	}

	private String normalizeDateTime(String value) {
		if (value == null)
			return null;
		String trimmed = value.trim();
		return trimmed.isEmpty() ? null : trimmed.replace("T", " ");
	}

	private String buildRedirectUrl(String search, String statusFilter) throws IOException {
		StringBuilder url = new StringBuilder("DockAllocationController");
		boolean hasQuery = false;

		if (search != null && !search.trim().isEmpty()) {
			url.append(hasQuery ? "&" : "?");
			url.append("search=").append(java.net.URLEncoder.encode(search.trim(), "UTF-8"));
			hasQuery = true;
		}

		if (statusFilter != null && !statusFilter.trim().isEmpty()) {
			url.append(hasQuery ? "&" : "?");
			url.append("statusFilter=").append(java.net.URLEncoder.encode(statusFilter.trim(), "UTF-8"));
		}

		return url.toString();
	}
}

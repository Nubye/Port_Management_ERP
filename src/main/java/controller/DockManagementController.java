package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.DockManagement;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/DockManagementController")
public class DockManagementController extends HttpServlet {
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
		req.setAttribute("activePage", "dock-management");

		loadPage(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User loggedUser = requireLoggedUser(req, resp);
		if (loggedUser == null)
			return;

		DockManagement dock = new DockManagement();

		String action = ControllerSupport.value(req.getParameter("action"));
		String add = req.getParameter("add");
		String update = req.getParameter("update");
		String delete = req.getParameter("delete");

		String message = null;
		String error = null;
		String redirectUrl = "DockManagementController";

		try {
			if ("add".equalsIgnoreCase(action) || add != null) {
				dock.setDockName(
						ControllerSupport.firstNonEmpty(req.getParameter("dock_name"), req.getParameter("dockName")));
				dock.setStatus(ControllerSupport.value(req.getParameter("status")));

				int result = dock.addDock(dock);
				if (result > 0)
					message = "Dock added successfully.";
				else
					error = dock.getMessage() == null ? "Failed to add dock." : dock.getMessage();

			} else if ("update".equalsIgnoreCase(action) || update != null) {
				dock.setDockId(ControllerSupport.parseInt(
						ControllerSupport.firstNonEmpty(req.getParameter("dock_id"), req.getParameter("dockId"))));
				dock.setDockName(
						ControllerSupport.firstNonEmpty(req.getParameter("dock_name"), req.getParameter("dockName")));
				dock.setStatus(ControllerSupport.value(req.getParameter("status")));

				int result = dock.updateDock(dock);
				if (result > 0)
					message = "Dock updated successfully.";
				else
					error = dock.getMessage() == null ? "Failed to update dock." : dock.getMessage();

				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("dock_name_search")),
						ControllerSupport.value(req.getParameter("status_search")));

			} else if ("delete".equalsIgnoreCase(action) || delete != null) {
				int dockId = ControllerSupport.parseInt(
						ControllerSupport.firstNonEmpty(req.getParameter("dock_id"), req.getParameter("dockId")));
				int result = dock.deleteDock(dockId);

				if (result > 0)
					message = "Dock deleted successfully.";
				else
					error = dock.getMessage() == null ? "Failed to delete dock." : dock.getMessage();

				redirectUrl = buildRedirectUrl(ControllerSupport.value(req.getParameter("dock_name_search")),
						ControllerSupport.value(req.getParameter("status_search")));
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
		DockManagement dock = new DockManagement();

		String action = ControllerSupport.value(req.getParameter("action"));
		String dockName = ControllerSupport.firstNonEmpty(req.getParameter("dock_name"), req.getParameter("dockName"));
		String status = ControllerSupport.value(req.getParameter("status"));
		String editId = ControllerSupport.value(req.getParameter("editId"));

		ArrayList<HashMap<String, String>> dockList;
		if ("search".equalsIgnoreCase(action) && (!dockName.isEmpty() || !status.isEmpty())) {
			dockList = dock.searchDock(dockName, status);
		} else {
			dockList = dock.showDock();
		}

		req.setAttribute("dockList", dockList);
		req.setAttribute("dock_name", dockName);
		req.setAttribute("status", status);
		req.setAttribute("editId", editId);

		ControllerSupport.applyFlash(req, req.getSession(false));

		req.getRequestDispatcher("/dock-management.jsp").forward(req, resp);
	}

	private String buildRedirectUrl(String dockNameSearch, String statusSearch) throws IOException {
		StringBuilder url = new StringBuilder("DockManagementController");

		boolean hasDockName = dockNameSearch != null && !dockNameSearch.trim().isEmpty();
		boolean hasStatus = statusSearch != null && !statusSearch.trim().isEmpty();

		if (hasDockName || hasStatus) {
			url.append("?action=search");
			if (hasDockName) {
				url.append("&dock_name=").append(java.net.URLEncoder.encode(dockNameSearch, "UTF-8"));
			}
			if (hasStatus) {
				url.append("&status=").append(java.net.URLEncoder.encode(statusSearch, "UTF-8"));
			}
		}

		return url.toString();
	}
}

package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.UserManagement;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;

@WebServlet("/UserManagementController")
public class UserManagementController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		if (!isLoggedIn(req) || !isAdmin(req)) {
			resp.sendRedirect("login.jsp?error=access");
			return;
		}
		setupSessionAttributes(req);
		loadPage(req, resp);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		if (!isLoggedIn(req) || !isAdmin(req)) {
			resp.sendRedirect("login.jsp?error=access");
			return;
		}
		setupSessionAttributes(req);

		UserManagement um = new UserManagement();
		String add = req.getParameter("add");
		String update = req.getParameter("update");
		String deactivate = req.getParameter("deactivate");
		String activate = req.getParameter("activate");

		try {
			User loggedUser = (User) req.getSession(false).getAttribute("loggedUser");

			if (add != null) {
				um.setAdminId(loggedUser.getUserId());
				um.setName(req.getParameter("name"));
				um.setEmail(req.getParameter("email"));
				um.setPassword(req.getParameter("password"));
				um.setRoleId(Integer.parseInt(req.getParameter("role_id")));
				um.add_User(um);
				req.setAttribute("message", "User added successfully.");
			} else if (update != null) {
				um.setUserId(Integer.parseInt(req.getParameter("user_id")));
				um.setName(req.getParameter("name"));
				um.setEmail(req.getParameter("email"));
				um.setRoleId(Integer.parseInt(req.getParameter("role_id")));
				um.update_User(um);
				req.setAttribute("message", "User updated successfully.");
			} else if (deactivate != null) {
				um.setUserId(Integer.parseInt(req.getParameter("user_id")));
				um.deactivate_User(um);
				req.setAttribute("message", "User deactivated successfully.");
			} else if (activate != null) {
				um.setUserId(Integer.parseInt(req.getParameter("user_id")));
				um.activate_User(um);
				req.setAttribute("message", "User activated successfully.");
			}
		} catch (Exception e) {
			req.setAttribute("error", e.getMessage());
			e.printStackTrace();
		}

		loadPage(req, resp);
	}

	private void setupSessionAttributes(HttpServletRequest req) {
		HttpSession session = req.getSession(false);
		if (session != null) {
			User loggedUser = (User) session.getAttribute("loggedUser");
			if (loggedUser != null) {
				req.setAttribute("roleId", loggedUser.getRoleId());
				String roleName = (String) session.getAttribute("roleName");
				req.setAttribute("roleName", roleName != null ? roleName : "User");
			}
		}
		req.setAttribute("activePage", "user-management");
	}

	private void loadPage(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		UserManagement um = new UserManagement();
		ArrayList<HashMap<String, String>> roleList = um.get_Roles();
		ArrayList<HashMap<String, String>> allUsers = um.get_All_Users();
		ArrayList<HashMap<String, String>> filteredUsers = new ArrayList<>();

		String search = req.getParameter("search");
		String roleId = req.getParameter("role_id");
		String status = req.getParameter("status");

		if (search == null)
			search = "";
		if (roleId == null)
			roleId = "";
		if (status == null)
			status = "";

		String searchLower = search.trim().toLowerCase(Locale.ENGLISH);
		String roleFilter = roleId.trim();
		String statusFilter = status.trim();

		for (HashMap<String, String> user : allUsers) {
			String userId = value(user.get("user_id"));
			String name = value(user.get("name"));
			String email = value(user.get("email"));
			String userRoleId = value(user.get("role_id"));
			String userStatus = value(user.get("status"));

			if (userStatus.isEmpty()) {
				userStatus = "Active";
			}

			boolean matchesSearch = true;
			if (!searchLower.isEmpty()) {
				matchesSearch = userId.toLowerCase(Locale.ENGLISH).contains(searchLower)
						|| name.toLowerCase(Locale.ENGLISH).contains(searchLower)
						|| email.toLowerCase(Locale.ENGLISH).contains(searchLower);
			}

			boolean matchesRole = true;
			if (!roleFilter.isEmpty()) {
				matchesRole = userRoleId.equals(roleFilter);
			}

			boolean matchesStatus = true;
			if (!statusFilter.isEmpty()) {
				matchesStatus = userStatus.equalsIgnoreCase(statusFilter);
			}

			if (matchesSearch && matchesRole && matchesStatus) {
				filteredUsers.add(user);
			}
		}

		req.setAttribute("roleList", roleList);
		req.setAttribute("userList", filteredUsers);
		req.setAttribute("search", search.trim());
		req.setAttribute("roleFilter", roleFilter);
		req.setAttribute("statusFilter", statusFilter);

		req.getRequestDispatcher("/user-management.jsp").forward(req, resp);
	}

	private String value(String s) {
		return s == null ? "" : s.trim();
	}

	private boolean isLoggedIn(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		return session != null && session.getAttribute("loggedUser") != null;
	}

	private boolean isAdmin(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if (session == null)
			return false;
		Object roleIdObj = session.getAttribute("roleId");
		return roleIdObj != null && Integer.parseInt(roleIdObj.toString()) == 1;
	}
}

package controller;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

public final class ControllerAuthUtil {

	private ControllerAuthUtil() {
	}

	public static User requireLoggedUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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

	public static User requireLoggedUser(HttpServletRequest req, HttpServletResponse resp, int... allowedRoles)
			throws IOException {
		User loggedUser = requireLoggedUser(req, resp);
		if (loggedUser == null) {
			return null;
		}

		if (allowedRoles == null || allowedRoles.length == 0) {
			return loggedUser;
		}

		int roleId = loggedUser.getRoleId();
		Set<Integer> allowed = new HashSet<>();
		for (int allowedRole : allowedRoles) {
			allowed.add(allowedRole);
		}

		if (!allowed.contains(roleId)) {
			resp.sendRedirect("login.jsp?error=access");
			return null;
		}

		return loggedUser;
	}
}
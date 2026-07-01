package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ProfileManagement;
import model.User;

import java.io.IOException;

@WebServlet("/ProfileManagementController")
public class ProfileManagementController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		User sessionUser = ControllerAuthUtil.requireLoggedUser(request, response);
		if (sessionUser == null)
			return;
		loadPage(request, response, sessionUser);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		User sessionUser = ControllerAuthUtil.requireLoggedUser(request, response);
		if (sessionUser == null)
			return;

		String action = ControllerSupport.value(request.getParameter("action"));
		HttpSession session = request.getSession(false);

		String message = null;
		String error = null;

		try {
			ProfileManagement profile = new ProfileManagement();

			if ("updateName".equalsIgnoreCase(action)) {
				String name = ControllerSupport.value(request.getParameter("name"));
				if (name.isEmpty()) {
					error = "Name is required.";
				} else {
					profile.setUserId(sessionUser.getUserId());
					profile.setName(name);
					int result = profile.updateProfileName(profile);
					if (result > 0)
						message = "Name updated successfully.";
					else
						error = profile.getMessage() == null ? "Failed to update name." : profile.getMessage();
				}

			} else if ("changeEmail".equalsIgnoreCase(action)) {
				String email = ControllerSupport.value(request.getParameter("email"));
				String confirmEmail = ControllerSupport.value(request.getParameter("confirm_email"));
				if (email.isEmpty()) {
					error = "Email is required.";
				} else if (!email.equals(confirmEmail)) {
					error = "Email confirmation does not match.";
				} else {
					profile.setUserId(sessionUser.getUserId());
					profile.setEmail(email);
					int result = profile.changeEmail(profile);
					if (result > 0)
						message = "Email updated successfully.";
					else
						error = profile.getMessage() == null ? "Failed to update email." : profile.getMessage();
				}

			} else if ("changePassword".equalsIgnoreCase(action)) {
				String currentPassword = ControllerSupport.value(request.getParameter("current_password"));
				String newPassword = ControllerSupport.value(request.getParameter("new_password"));
				String confirmPassword = ControllerSupport.value(request.getParameter("confirm_password"));

				if (currentPassword.isEmpty()) {
					error = "Current password is required.";
				} else if (newPassword.isEmpty()) {
					error = "New password is required.";
				} else if (!newPassword.equals(confirmPassword)) {
					error = "Password confirmation does not match.";
				} else if (currentPassword.equals(newPassword)) {
					error = "New password must be different from current password.";
				} else {
					int result = profile.changePassword(sessionUser.getUserId(), currentPassword, newPassword);
					if (result > 0) {
						message = "Password updated successfully.";
					} else {
						error = profile.getMessage() == null ? "Failed to update password." : profile.getMessage();
					}
				}
			}

			if (message != null) {
				User userModel = new User();
				User updated = userModel.get_Profile_Details(sessionUser.getUserId());
				if (updated != null) {
					session.setAttribute("loggedUser", updated);
					session.setAttribute("roleId", updated.getRoleId());
					session.setAttribute("roleName", updated.getRoleName());
					session.setAttribute("userName", updated.getName());
				}
			}

		} catch (Exception e) {
			error = e.getMessage();
			e.printStackTrace();
		}

		if (message != null)
			session.setAttribute("flash_message", message);
		if (error != null)
			session.setAttribute("flash_error", error);

		response.sendRedirect("ProfileManagementController");
	}

	private void loadPage(HttpServletRequest request, HttpServletResponse response, User sessionUser)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);

		ProfileManagement profile = new ProfileManagement();
		ProfileManagement details = profile.getProfileDetails(sessionUser.getUserId());

		if (details != null) {
			request.setAttribute("name", details.getName());
			request.setAttribute("email", details.getEmail());
			request.setAttribute("roleName", details.getRoleName());
		} else {
			request.setAttribute("name", sessionUser.getName());
			request.setAttribute("email", sessionUser.getEmail());
			request.setAttribute("roleName", sessionUser.getRoleName());
		}

		ControllerSupport.applyFlash(request, session);

		request.getRequestDispatcher("/profile-settings.jsp").forward(request, response);
	}

}
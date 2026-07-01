package controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class ControllerSupport {

	private ControllerSupport() {
	}

	public static int parseInt(String value) {
		try {
			return Integer.parseInt(value);
		} catch (Exception e) {
			return 0;
		}
	}

	public static double parseDouble(String value) {
		try {
			return Double.parseDouble(value);
		} catch (Exception e) {
			return 0;
		}
	}

	public static String value(String value) {
		return value == null ? "" : value.trim();
	}

	public static String firstNonEmpty(String... values) {
		if (values == null)
			return "";

		for (String value : values) {
			if (value != null && !value.trim().isEmpty()) {
				return value.trim();
			}
		}

		return "";
	}

	public static void setFlash(HttpSession session, String message, String error) {
		if (session == null)
			return;

		if (message != null) {
			session.setAttribute("flash_message", message);
		}

		if (error != null) {
			session.setAttribute("flash_error", error);
		}
	}

	public static void applyFlash(HttpServletRequest req, HttpSession session) {
		if (session == null)
			return;

		String flashMessage = (String) session.getAttribute("flash_message");
		String flashError = (String) session.getAttribute("flash_error");

		if (flashMessage != null) {
			req.setAttribute("message", flashMessage);
			req.setAttribute("success", flashMessage);
			session.removeAttribute("flash_message");
		}

		if (flashError != null) {
			req.setAttribute("error", flashError);
			session.removeAttribute("flash_error");
		}
	}
}
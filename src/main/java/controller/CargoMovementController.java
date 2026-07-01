package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CargoMovement;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/CargoMovementController")
public class CargoMovementController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp);
		if (loggedUser == null)
			return;

		String historyIdParam = ControllerSupport.value(
				ControllerSupport.firstNonEmpty(req.getParameter("historyCargoId"), req.getParameter("cargo_id")));

		Integer historyCargoId = null;
		if (!historyIdParam.isEmpty()) {
			historyCargoId = ControllerSupport.parseInt(historyIdParam);
		}

		loadMovementPage(req, resp, historyCargoId);
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp);
		if (loggedUser == null) {
			return;
		}

		CargoMovement cargo = new CargoMovement();

		String action = ControllerSupport.value(req.getParameter("action"));
		String movement = req.getParameter("movement");
		String history = req.getParameter("history");

		String successMessage = null;
		String errorMessage = null;
		String redirectUrl = "CargoMovementController";

		try {
			if ("movement".equalsIgnoreCase(action) || "log".equalsIgnoreCase(action) || movement != null) {
				cargo.setCargoId(ControllerSupport.parseInt(
						ControllerSupport.firstNonEmpty(req.getParameter("cargo_id"), req.getParameter("cargoId"))));
				cargo.setMovementType(ControllerSupport.value(ControllerSupport
						.firstNonEmpty(req.getParameter("movement_type"), req.getParameter("movementType"))));

				int sessionUserId = loggedUser.getUserId();
				if (sessionUserId <= 0) {
					errorMessage = "Invalid logged-in user session.";
				} else {
					cargo.setHandledBy(sessionUserId);
				}

				if (errorMessage == null) {
					boolean result = cargo.log_Cargo_Movement(cargo);
					if (result)
						successMessage = "Cargo movement logged successfully.";
					else
						errorMessage = "Failed to log cargo movement.";
				}

			} else if ("history".equalsIgnoreCase(action) || history != null) {
				int cargoId = ControllerSupport.parseInt(
						ControllerSupport.firstNonEmpty(req.getParameter("cargo_id"), req.getParameter("cargoId")));
				redirectUrl = buildHistoryRedirect(cargoId);
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

	private void loadMovementPage(HttpServletRequest req, HttpServletResponse resp, Integer historyCargoId)
			throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp);
		if (loggedUser == null) {
			return;
		}

		CargoMovement cargo = new CargoMovement();

		ArrayList<HashMap<String, String>> cargoList = cargo.get_Cargo_Details();
		ArrayList<HashMap<String, String>> movementList = cargo.get_Cargo_Movement_History();

		String handledByLabel = loggedUser.getName();
		if (loggedUser.getUserId() > 0) {
			handledByLabel += " (ID: " + loggedUser.getUserId() + ")";
		}

		req.setAttribute("cargoList", cargoList);
		req.setAttribute("movementList", movementList);
		req.setAttribute("handledByLabel", handledByLabel);

		if (historyCargoId != null && historyCargoId > 0) {
			ArrayList<HashMap<String, String>> historyList = cargo.get_Cargo_History(historyCargoId);
			req.setAttribute("historyList", historyList);
			req.setAttribute("historyCargoId", historyCargoId);
		}

		ControllerSupport.applyFlash(req, session);

		req.getRequestDispatcher("/cargo-movement.jsp").forward(req, resp);
	}

	private String buildHistoryRedirect(int cargoId) throws IOException {
		if (cargoId <= 0)
			return "CargoMovementController";
		return "CargoMovementController?historyCargoId=" + URLEncoder.encode(String.valueOf(cargoId), "UTF-8");
	}
}
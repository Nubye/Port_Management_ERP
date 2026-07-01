package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.ShipManagement;
import model.DockManagement;
import model.DockAllocation;
import model.ContainerManagement;
import model.CargoManagement;
import model.CargoMovement;
import model.SecurityLog;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/UserController")
public class UserController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String dashboard = req.getParameter("dashboard");
		String logout = req.getParameter("logout");

		if (dashboard != null) {
			User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp);
			if (loggedUser == null) {
				return;
			}
			loadPage(req, resp, loggedUser);
		} else if (logout != null) {
			User loggedUser = ControllerAuthUtil.requireLoggedUser(req, resp);
			if (loggedUser == null) {
				return;
			}

			try {
				User model = new User();
				model.setUserId(loggedUser.getUserId());
				model.logout_User(model);
			} catch (Exception e) {
				e.printStackTrace();
			}

			HttpSession session = req.getSession(false);
			if (session != null) {
				session.invalidate();
			}

			resp.sendRedirect("login.jsp?msg=logout");
		} else {
			resp.sendRedirect("login.jsp");
		}
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		User user = new User();
		String login = req.getParameter("login");

		try {
			if (login != null) {
				user.setEmail(req.getParameter("email"));
				user.setPassword(req.getParameter("password"));

				User loggedUser = user.login_User(user);

				if (loggedUser != null) {
					HttpSession session = req.getSession();
					session.setAttribute("loggedUser", loggedUser);
					session.setAttribute("roleId", loggedUser.getRoleId());
					session.setAttribute("roleName", loggedUser.getRoleName());
					session.setAttribute("userName", loggedUser.getName());

					resp.sendRedirect("UserController?dashboard=1");
					return;
				} else {
					req.setAttribute("error", "Invalid email or password.");
				}
			}
		} catch (RuntimeException e) {
			String message = e.getMessage();

			if (message != null) {
				if (message.equalsIgnoreCase("Account is inactive")) {
					req.setAttribute("error", "Your account is inactive. Please contact the administrator.");
				} else if (message.equalsIgnoreCase("Invalid credentials")) {
					req.setAttribute("error", "Invalid email or password.");
				} else {
					req.setAttribute("error", message);
				}
			} else {
				req.setAttribute("error", "Login failed. Please try again.");
			}

			e.printStackTrace();
		} catch (Exception e) {
			req.setAttribute("error", "Something went wrong. Please try again.");
			e.printStackTrace();
		}

		req.getRequestDispatcher("login.jsp").forward(req, resp);
	}

	private void loadPage(HttpServletRequest req, HttpServletResponse resp, User sessionUser)
			throws ServletException, IOException {
		User userModel = new User();
		ShipManagement shipModel = new ShipManagement();
		DockManagement dockModel = new DockManagement();
		DockAllocation dockAllocationModel = new DockAllocation();
		ContainerManagement containerModel = new ContainerManagement();
		CargoManagement cargoModel = new CargoManagement();
		CargoMovement cargoMovementModel = new CargoMovement();
		SecurityLog securityLogModel = new SecurityLog();

		req.setAttribute("userCount", userModel.get_User_Count());
		req.setAttribute("roleCount", userModel.get_Role_Count());

		if (sessionUser != null) {
			User profile = userModel.get_Profile_Details(sessionUser.getUserId());

			req.setAttribute("displayName", profile.getName());
			req.setAttribute("displayEmail", profile.getEmail());
			req.setAttribute("displayRoleName", sessionUser.getRoleName());

			int roleId = sessionUser.getRoleId();
			int userId = sessionUser.getUserId();

			ArrayList<HashMap<String, String>> shipList = shipModel.getAllShips();
			ArrayList<HashMap<String, String>> dockList = dockModel.showDock();
			ArrayList<HashMap<String, String>> activeAllocations = dockAllocationModel.get_Active_Allocations();
			ArrayList<HashMap<String, String>> containerList = containerModel.search_Containers(null, null, null, null);
			ArrayList<HashMap<String, String>> cargoList = cargoModel.get_Cargo_Details();
			ArrayList<HashMap<String, String>> pendingCargoList = cargoModel.get_Pending_Cargo_Movements();
			ArrayList<HashMap<String, String>> movementHistory = cargoMovementModel.get_Cargo_Movement_History();

			if (roleId == 1 || roleId == 2) {
				int activeDocks = 0;
				for (HashMap<String, String> dock : dockList) {
					String status = dock.get("status");
					if (status != null && status.equalsIgnoreCase("Occupied")) {
						activeDocks++;
					}
				}

				ArrayList<HashMap<String, String>> recentActivity = new ArrayList<>();
				for (int i = 0; i < movementHistory.size() && i < 5; i++) {
					recentActivity.add(movementHistory.get(i));
				}

				ArrayList<SecurityLog> securityLogs = securityLogModel.getSecurityLogs(null, null, null, null);
				ArrayList<HashMap<String, String>> securityPreview = new ArrayList<>();

				for (int i = 0; i < securityLogs.size() && i < 5; i++) {
					SecurityLog log = securityLogs.get(i);
					HashMap<String, String> row = new HashMap<>();
					row.put("username", log.getUsername());
					row.put("role_name", log.getRoleName());
					row.put("entry_time", log.getEntryTime() == null ? "" : log.getEntryTime().toString());
					row.put("exit_time", log.getExitTime() == null ? "" : log.getExitTime().toString());
					row.put("session_duration", String.valueOf(log.getSessionDuration()));
					securityPreview.add(row);
				}

				req.setAttribute("totalShips", shipList.size());
				req.setAttribute("activeDocks", activeDocks);
				req.setAttribute("totalContainers", containerList.size());
				req.setAttribute("totalCargoItems", cargoList.size());
				req.setAttribute("recentActivity", recentActivity);
				req.setAttribute("securityPreview", securityPreview);
			}

			if (roleId == 3) {
				ArrayList<HashMap<String, String>> myShips = new ArrayList<>();
				ArrayList<HashMap<String, String>> upcomingDepartures = new ArrayList<>();
				ArrayList<String> myShipIds = new ArrayList<>();
				int myContainerCount = 0;

				for (HashMap<String, String> ship : shipList) {
					String operatorId = ship.get("operator_id");
					if (operatorId != null && Integer.parseInt(operatorId) == userId) {
						myShips.add(ship);
						myShipIds.add(ship.get("ship_id"));

						String status = ship.get("status");
						String departureDate = ship.get("departure_date");
						if (departureDate != null && !departureDate.trim().isEmpty()
								&& (status == null || !status.equalsIgnoreCase("Departed"))) {
							upcomingDepartures.add(ship);
						}
					}
				}

				for (HashMap<String, String> container : containerList) {
					String shipId = container.get("ship_id");
					if (shipId != null && myShipIds.contains(shipId)) {
						myContainerCount++;
					}
				}

				req.setAttribute("myShipCount", myShips.size());
				req.setAttribute("myContainerCount", myContainerCount);
				req.setAttribute("myShips", myShips);
				req.setAttribute("upcomingDepartures", upcomingDepartures);
			}

			if (roleId == 4) {
				int availableDockCount = 0;
				int occupiedDockCount = 0;

				for (HashMap<String, String> dock : dockList) {
					String status = dock.get("status");
					if ("Available".equalsIgnoreCase(status)) {
						availableDockCount++;
					} else if ("Occupied".equalsIgnoreCase(status)) {
						occupiedDockCount++;
					}
				}

				req.setAttribute("availableDockCount", availableDockCount);
				req.setAttribute("occupiedDockCount", occupiedDockCount);
				req.setAttribute("dockBoard", dockList);
				req.setAttribute("activeAllocations", activeAllocations);
			}

			if (roleId == 5) {
				ArrayList<HashMap<String, String>> recentHandledCargo = new ArrayList<>();
				int loadedCargoCount = 0;
				int unloadedCargoCount = 0;

				for (HashMap<String, String> cargo : cargoList) {
					String status = cargo.get("cargo_status");
					if ("Loaded".equalsIgnoreCase(status)) {
						loadedCargoCount++;
					} else if ("Unloaded".equalsIgnoreCase(status)) {
						unloadedCargoCount++;
					}
				}

				for (HashMap<String, String> movement : movementHistory) {
					String handledBy = movement.get("handled_by");
					if (handledBy != null && handledBy.equalsIgnoreCase(sessionUser.getName())) {
						recentHandledCargo.add(movement);
					}
					if (recentHandledCargo.size() == 5) {
						break;
					}
				}

				req.setAttribute("totalCargoCount", cargoList.size());
				req.setAttribute("loadedCargoCount", loadedCargoCount);
				req.setAttribute("unloadedCargoCount", unloadedCargoCount);
				req.setAttribute("pendingCargoMovements", pendingCargoList);
				req.setAttribute("recentHandledCargo", recentHandledCargo);
			}
		}

		req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
	}

}
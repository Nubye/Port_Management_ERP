package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.SecurityLog;

@WebServlet("/SecurityLogController")
public class SecurityLogController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		if (ControllerAuthUtil.requireLoggedUser(request, response, 1, 2) == null) {
			return;
		}

		String action = request.getParameter("action");

		String username = request.getParameter("username");
		String role = request.getParameter("role");
		String fromDate = request.getParameter("fromDate");
		String toDate = request.getParameter("toDate");

		SecurityLog model = new SecurityLog();

		try {
			if ("export".equals(action)) {
				ArrayList<SecurityLog> logList = model.getSecurityLogs(username, role, fromDate, toDate);

				response.setContentType("text/csv");
				response.setHeader("Content-Disposition", "attachment; filename=security_logs.csv");

				StringBuilder csv = new StringBuilder();
				csv.append("LogID,Username,Role,EntryTime,ExitTime,Duration\n");

				for (SecurityLog log : logList) {
					csv.append(log.getLogid()).append(",").append(log.getUsername()).append(",")
							.append(log.getRoleName()).append(",").append(log.getEntryTime()).append(",")
							.append(log.getExitTime()).append(",").append(log.getSessionDuration()).append("\n");
				}

				response.getWriter().write(csv.toString());
				return;
			}

			ArrayList<SecurityLog> logList = model.getSecurityLogs(username, role, fromDate, toDate);
			ArrayList<Map<String, String>> logRows = new ArrayList<>();

			for (SecurityLog log : logList) {
				Map<String, String> row = new HashMap<>();
				row.put("username", log.getUsername());
				row.put("roleName", log.getRoleName());
				row.put("entryTime", String.valueOf(log.getEntryTime()));
				row.put("exitTime", String.valueOf(log.getExitTime()));
				row.put("sessionDuration", String.valueOf(log.getSessionDuration()));
				logRows.add(row);
			}

			request.setAttribute("username", username);
			request.setAttribute("role", role);
			request.setAttribute("fromDate", fromDate);
			request.setAttribute("toDate", toDate);
			request.setAttribute("logRows", logRows);

			request.getRequestDispatcher("/security-log.jsp").forward(request, response);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
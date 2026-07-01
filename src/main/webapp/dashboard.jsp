<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%
Object sessionUser = session.getAttribute("loggedUser");
if (sessionUser == null) {
	response.sendRedirect("login.jsp?error=session");
	return;
}

String roleName = (String) request.getAttribute("displayRoleName");
if (roleName == null || roleName.trim().isEmpty()) {
	roleName = (String) session.getAttribute("roleName");
}
if (roleName == null)
	roleName = "User";

Integer roleId = (Integer) session.getAttribute("roleId");
String displayName = (String) request.getAttribute("displayName");
String displayEmail = (String) request.getAttribute("displayEmail");

request.setAttribute("activePage", "dashboard");
request.setAttribute("topbarTitle", roleName + " Dashboard");

ArrayList<HashMap<String, String>> recentActivity = (ArrayList<HashMap<String, String>>) request
		.getAttribute("recentActivity");

ArrayList<HashMap<String, String>> myShips = (ArrayList<HashMap<String, String>>) request.getAttribute("myShips");

ArrayList<HashMap<String, String>> upcomingDepartures = (ArrayList<HashMap<String, String>>) request
		.getAttribute("upcomingDepartures");

ArrayList<HashMap<String, String>> dockBoard = (ArrayList<HashMap<String, String>>) request.getAttribute("dockBoard");

ArrayList<HashMap<String, String>> pendingCargoMovements = (ArrayList<HashMap<String, String>>) request
		.getAttribute("pendingCargoMovements");

ArrayList<HashMap<String, String>> recentHandledCargo = (ArrayList<HashMap<String, String>>) request
		.getAttribute("recentHandledCargo");

ArrayList<HashMap<String, String>> securityPreview = (ArrayList<HashMap<String, String>>) request
		.getAttribute("securityPreview");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard | Port Management ERP</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<style>
.main-content {
	margin-top: 68px;
	margin-left: 260px;
	padding: 30px;
}

.page-title {
	font-weight: 800;
	color: #ffffff;
	margin-bottom: 6px;
}

.page-subtitle {
	color: var(--text-soft);
	margin-bottom: 0;
}

.dash-card {
	background: var(--bg-card);
	border: 1px solid var(--border-soft);
	border-radius: 20px;
	box-shadow: var(--shadow-main);
}

.stat-card {
	padding: 22px;
	position: relative;
	overflow: hidden;
}

.stat-card::before {
	content: "";
	position: absolute;
	inset: 0 0 auto 0;
	height: 3px;
	background: linear-gradient(90deg, var(--purple-deep),
		var(--purple-bright));
}

.panel-card {
	padding: 24px;
}

.stat-label {
	color: var(--purple-light);
	font-size: 0.88rem;
	margin-bottom: 8px;
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: 0.7px;
}

.stat-value {
	font-size: 2rem;
	font-weight: 800;
	color: #ffffff;
	margin: 0;
}

.section-title {
	font-size: 1.15rem;
	font-weight: 800;
	color: #ffffff;
	margin-bottom: 18px;
}

.mini-item {
	border-bottom: 1px solid rgba(168, 85, 247, 0.12);
	padding: 12px 0;
}

.mini-item:last-child {
	border-bottom: none;
}

.mini-title {
	font-weight: 600;
	margin-bottom: 4px;
	color: #ffffff;
}

.mini-meta {
	color: var(--text-muted);
	font-size: 0.92rem;
}

.dock-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
	gap: 16px;
}

.dock-tile {
	border-radius: 16px;
	padding: 18px;
	background: #171721;
	border: 1px solid rgba(192, 132, 252, 0.16);
	box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.01);
}

.dock-available {
	border-left: 4px solid var(--success);
}

.dock-occupied {
	border-left: 4px solid var(--danger);
}

.dock-maintenance {
	border-left: 4px solid var(--warning);
}

.badge-soft {
	display: inline-block;
	font-size: 0.78rem;
	padding: 6px 12px;
	border-radius: 999px;
	font-weight: 700;
}

.badge-available {
	background: rgba(34, 197, 94, 0.14);
	color: #bbf7d0;
	border: 1px solid rgba(34, 197, 94, 0.24);
}

.badge-occupied {
	background: rgba(239, 68, 68, 0.14);
	color: #fecaca;
	border: 1px solid rgba(239, 68, 68, 0.24);
}

.badge-maintenance {
	background: rgba(245, 158, 11, 0.14);
	color: #fde68a;
	border: 1px solid rgba(245, 158, 11, 0.24);
}

.alert-success {
	background: rgba(34, 197, 94, 0.14);
	border: 1px solid rgba(34, 197, 94, 0.28);
	color: #bbf7d0;
	border-radius: 14px;
}

.alert-danger {
	background: rgba(239, 68, 68, 0.14);
	border: 1px solid rgba(239, 68, 68, 0.28);
	color: #fecaca;
	border-radius: 14px;
}

.btn-outline-light {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
	border-radius: 12px;
	font-weight: 700;
}

.btn-outline-light:hover {
	background: linear-gradient(135deg, var(--purple-deep) 0%,
		var(--purple-dark) 100%);
	border-color: rgba(192, 132, 252, 0.22);
	color: #ffffff;
}

.text-secondary {
	color: var(--text-muted) !important;
}

strong {
	color: var(--purple-light);
}

@media ( max-width : 991.98px) {
	.main-content {
		margin-left: 0;
		padding: 20px;
	}
	.stat-value {
		font-size: 1.7rem;
	}
}
</style>
</head>
<body>

	<jsp:include page="includes/topbar.jsp" />
	<jsp:include page="includes/sidebar.jsp" />

	<main class="main-content">
		<div class="mb-4">
			<h2 class="page-title">Dashboard</h2>
			<p class="page-subtitle">
				Welcome back,
				<%=displayName == null ? "User" : displayName%>. Logged in as
				<%=roleName%>.
			</p>
		</div>

		<%
		if (request.getAttribute("message") != null) {
		%>
		<div class="alert alert-success"><%=request.getAttribute("message")%></div>
		<%
		}
		%>

		<%
		if (request.getAttribute("error") != null) {
		%>
		<div class="alert alert-danger"><%=request.getAttribute("error")%></div>
		<%
		}
		%>

		<%
		if (roleId != null && (roleId == 1 || roleId == 2)) {
		%>
		<div class="row g-4 mb-4">
			<div class="col-md-3">
				<div class="dash-card stat-card">
					<div class="stat-label">Total Ships</div>
					<p class="stat-value"><%=request.getAttribute("totalShips") == null ? 0 : request.getAttribute("totalShips")%></p>
				</div>
			</div>
			<div class="col-md-3">
				<div class="dash-card stat-card">
					<div class="stat-label">Active Docks</div>
					<p class="stat-value"><%=request.getAttribute("activeDocks") == null ? 0 : request.getAttribute("activeDocks")%></p>
				</div>
			</div>
			<div class="col-md-3">
				<div class="dash-card stat-card">
					<div class="stat-label">Containers</div>
					<p class="stat-value"><%=request.getAttribute("totalContainers") == null ? 0 : request.getAttribute("totalContainers")%></p>
				</div>
			</div>
			<div class="col-md-3">
				<div class="dash-card stat-card">
					<div class="stat-label">Cargo Items</div>
					<p class="stat-value"><%=request.getAttribute("totalCargoItems") == null ? 0 : request.getAttribute("totalCargoItems")%></p>
				</div>
			</div>
		</div>

		<div class="row g-4">
			<div class="col-lg-6">
				<div class="dash-card panel-card">
					<div class="section-title">Recent Activity</div>
					<%
					if (recentActivity != null && !recentActivity.isEmpty()) {
						for (HashMap<String, String> row : recentActivity) {
					%>
					<div class="mini-item">
						<div class="mini-title"><%=row.get("cargo_description")%></div>
						<div class="mini-meta"><%=row.get("movement_type")%>
							by
							<%=row.get("handled_by")%>
							on
							<%=row.get("movement_date")%></div>
					</div>
					<%
					}
					} else {
					%>
					<p class="text-secondary mb-0">No recent activity found.</p>
					<%
					}
					%>
				</div>
			</div>

			<div class="col-lg-6">
				<div class="dash-card panel-card">
					<div class="section-title">Security Log Preview</div>
					<%
					if (securityPreview != null && !securityPreview.isEmpty()) {
						for (HashMap<String, String> log : securityPreview) {
					%>
					<div class="mini-item">
						<div class="mini-title"><%=log.get("username")%>
							(<%=log.get("role_name")%>)
						</div>
						<div class="mini-meta">
							Login:
							<%=log.get("entry_time")%>
							<%
							if (log.get("exit_time") != null && !log.get("exit_time").trim().isEmpty()) {
							%>
							| Logout:
							<%=log.get("exit_time")%>
							<%
							} else {
							%>
							| Session Active
							<%
							}
							%>
						</div>
					</div>
					<%
					}
					} else {
					%>
					<p class="text-secondary mb-0">No security logs available.</p>
					<%
					}
					%>
				</div>
			</div>
		</div>
		<%
		}
		%>

		<%
		if (roleId != null && roleId == 3) {
		%>
		<div class="row g-4 mb-4">
			<div class="col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">My Ships</div>
					<p class="stat-value"><%=request.getAttribute("myShipCount") == null ? 0 : request.getAttribute("myShipCount")%></p>
				</div>
			</div>
			<div class="col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">My Containers</div>
					<p class="stat-value"><%=request.getAttribute("myContainerCount") == null ? 0 : request.getAttribute("myContainerCount")%></p>
				</div>
			</div>
		</div>

		<div class="row g-4">
			<div class="col-lg-6">
				<div class="dash-card panel-card">
					<div class="section-title">My Ships</div>
					<%
					if (myShips != null && !myShips.isEmpty()) {
						for (HashMap<String, String> ship : myShips) {
					%>
					<div class="mini-item">
						<div class="mini-title"><%=ship.get("ship_name")%></div>
						<div class="mini-meta">
							Arrival:
							<%=ship.get("arrival_date")%>
							| Status:
							<%=ship.get("status")%></div>
					</div>
					<%
					}
					} else {
					%>
					<p class="text-secondary mb-0">No ships assigned.</p>
					<%
					}
					%>
				</div>
			</div>

			<div class="col-lg-6">
				<div class="dash-card panel-card">
					<div class="section-title">Upcoming Departures</div>
					<%
					if (upcomingDepartures != null && !upcomingDepartures.isEmpty()) {
						for (HashMap<String, String> ship : upcomingDepartures) {
					%>
					<div class="mini-item">
						<div class="mini-title"><%=ship.get("ship_name")%></div>
						<div class="mini-meta">
							Departure:
							<%=ship.get("departure_date")%>
							| Status:
							<%=ship.get("status")%></div>
					</div>
					<%
					}
					} else {
					%>
					<p class="text-secondary mb-0">No upcoming departures.</p>
					<%
					}
					%>
				</div>
			</div>
		</div>
		<%
		}
		%>

		<%
		if (roleId != null && roleId == 4) {
		%>
		<div class="row g-4 mb-4">
			<div class="col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Available Docks</div>
					<p class="stat-value"><%=request.getAttribute("availableDockCount") == null ? 0 : request.getAttribute("availableDockCount")%></p>
				</div>
			</div>
			<div class="col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Occupied Docks</div>
					<p class="stat-value"><%=request.getAttribute("occupiedDockCount") == null ? 0 : request.getAttribute("occupiedDockCount")%></p>
				</div>
			</div>
		</div>

		<div class="dash-card panel-card">
			<div class="section-title">Dock Occupancy Board</div>
			<div class="dock-grid">
				<%
				if (dockBoard != null && !dockBoard.isEmpty()) {
					for (HashMap<String, String> dock : dockBoard) {
						String status = dock.get("status");
						String dockClass = "dock-available";
						String badgeClass = "badge-available";

						if ("Occupied".equalsIgnoreCase(status)) {
					dockClass = "dock-occupied";
					badgeClass = "badge-occupied";
						} else if ("Under Maintenance".equalsIgnoreCase(status)) {
					dockClass = "dock-maintenance";
					badgeClass = "badge-maintenance";
						}
				%>
				<div class="dock-tile <%=dockClass%>">
					<h6 class="mb-2"><%=dock.get("dock_name")%></h6>
					<p class="mb-2">
						<span class="badge-soft <%=badgeClass%>"><%=status%></span>
					</p>
					<p class="mb-0">
						<strong>Ship:</strong>
						<%=dock.get("ship_name") != null && !dock.get("ship_name").trim().isEmpty() ? dock.get("ship_name")
		: ("Occupied".equalsIgnoreCase(status) ? "Check allocation" : "-")%>
					</p>
				</div>
				<%
				}
				} else {
				%>
				<p class="text-secondary">No dock data available.</p>
				<%
				}
				%>
			</div>
		</div>
		<%
		}
		%>

		<%
		if (roleId != null && roleId == 5) {
		%>
		<div class="row g-4 mb-4">
			<div class="col-md-4">
				<div class="dash-card stat-card">
					<div class="stat-label">Total Cargos</div>
					<p class="stat-value"><%=request.getAttribute("totalCargoCount") == null ? 0 : request.getAttribute("totalCargoCount")%></p>
				</div>
			</div>
			<div class="col-md-4">
				<div class="dash-card stat-card">
					<div class="stat-label">Loaded</div>
					<p class="stat-value"><%=request.getAttribute("loadedCargoCount") == null ? 0 : request.getAttribute("loadedCargoCount")%></p>
				</div>
			</div>
			<div class="col-md-4">
				<div class="dash-card stat-card">
					<div class="stat-label">Unloaded</div>
					<p class="stat-value"><%=request.getAttribute("unloadedCargoCount") == null ? 0 : request.getAttribute("unloadedCargoCount")%></p>
				</div>
			</div>
		</div>

		<div class="row g-4">
			<div class="col-lg-6">
				<div class="dash-card panel-card">
					<div class="section-title">Pending Cargo Movements</div>
					<%
					if (pendingCargoMovements != null && !pendingCargoMovements.isEmpty()) {
						for (HashMap<String, String> row : pendingCargoMovements) {
					%>
					<div class="mini-item">
						<div class="mini-title"><%=row.get("description")%></div>
						<div class="mini-meta">
							Ship:
							<%=row.get("ship_name")%>
							| Status:
							<%=row.get("status")%></div>
					</div>
					<%
					}
					} else {
					%>
					<p class="text-secondary mb-0">No pending cargo movements.</p>
					<%
					}
					%>
				</div>
			</div>

			<div class="col-lg-6">
				<div class="dash-card panel-card">
					<div class="section-title">Recently Handled Cargo</div>
					<%
					if (recentHandledCargo != null && !recentHandledCargo.isEmpty()) {
						for (HashMap<String, String> row : recentHandledCargo) {
					%>
					<div class="mini-item">
						<div class="mini-title"><%=row.get("cargo_description")%></div>
						<div class="mini-meta"><%=row.get("movement_type")%>
							on
							<%=row.get("movement_date")%></div>
					</div>
					<%
					}
					} else {
					%>
					<p class="text-secondary mb-0">No recent handled cargo found.</p>
					<%
					}
					%>
				</div>
			</div>
		</div>
		<%
		}
		%>
	</main>

</body>
</html>
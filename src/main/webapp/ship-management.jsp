<%@ page import="java.util.*"%>
<%@ page import="java.net.URLEncoder"%>
<%
List<Map<String, String>> shipList = (List<Map<String, String>>) request.getAttribute("shipList");
String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");

String shipNameSearch = (String) request.getAttribute("ship_name");
String statusSearch = (String) request.getAttribute("status");
String editId = (String) request.getAttribute("editId");

Integer anchoredCount = (Integer) request.getAttribute("anchoredCount");
Integer dockedCount = (Integer) request.getAttribute("dockedCount");
Integer departedCount = (Integer) request.getAttribute("departedCount");
Boolean canDelete = (Boolean) request.getAttribute("canDelete");

if (shipList == null)
	shipList = new ArrayList<>();
if (shipNameSearch == null)
	shipNameSearch = "";
if (statusSearch == null)
	statusSearch = "";
if (editId == null)
	editId = "";
if (anchoredCount == null)
	anchoredCount = 0;
if (dockedCount == null)
	dockedCount = 0;
if (departedCount == null)
	departedCount = 0;
if (canDelete == null)
	canDelete = false;

request.setAttribute("activePage", "ship-management");
request.setAttribute("topbarTitle", "Ship Management");

// --- Pagination ---
int pageSize = 10;
int totalShips = shipList.size();
int totalPages = (int) Math.ceil((double) totalShips / pageSize);

String pageParam = request.getParameter("page");
int currentPage = 1;
try {
	if (pageParam != null)
		currentPage = Integer.parseInt(pageParam);
} catch (Exception e) {
}
if (currentPage < 1)
	currentPage = 1;
if (currentPage > totalPages && totalPages > 0)
	currentPage = totalPages;

int startIndex = (currentPage - 1) * pageSize;
int endIndex = Math.min(startIndex + pageSize, totalShips);

// --- Filter query string for pagination links ---
String filterQuery = "action=search" + "&ship_name=" + URLEncoder.encode(shipNameSearch.trim(), "UTF-8") + "&status="
		+ URLEncoder.encode(statusSearch.trim(), "UTF-8");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ship Management | Port Management ERP</title>
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

.section-title {
	font-size: 1.15rem;
	font-weight: 800;
	color: #ffffff;
}

.section-subtitle {
	color: var(--text-muted);
	font-size: 0.92rem;
	margin-top: 4px;
}

.form-label {
	color: var(--purple-light);
	font-weight: 650;
	margin-bottom: 10px;
}

.form-control, .form-select {
	background-color: #12121a;
	border: 1px solid var(--border-soft);
	color: #ffffff;
	border-radius: 14px;
}

.form-control:focus, .form-select:focus {
	background-color: #171721;
	color: #ffffff;
	border-color: var(--purple-bright);
	box-shadow: 0 0 0 0.2rem rgba(168, 85, 247, 0.22);
}

.form-control::placeholder {
	color: #867a9c;
}

.btn-purple, .btn-outline-purple, .btn-soft-danger, .btn-search {
	min-width: 82px;
	height: 36px;
	padding: 0 12px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border-radius: 12px;
	font-weight: 700;
	line-height: 1;
	white-space: nowrap;
	text-decoration: none;
}

.btn-purple {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
	box-shadow: 0 8px 18px rgba(138, 43, 226, 0.28);
}

.btn-purple:hover {
	background: linear-gradient(135deg, #9b4df1 0%, #b86cff 100%);
	color: #ffffff;
}

.btn-outline-purple {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
}

.btn-outline-purple:hover {
	background: rgba(168, 85, 247, 0.22);
	color: #ffffff;
}

.btn-soft-danger {
	background: var(--red-bg);
	border: 1px solid var(--red-border);
	color: #fecaca;
}

.btn-soft-danger:hover {
	background: rgba(239, 68, 68, 0.20);
	color: #ffffff;
}

.btn-search {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
	min-width: 96px;
	height: 42px;
}

.btn-search:hover {
	background: rgba(168, 85, 247, 0.22);
	color: #ffffff;
}

.table-shell {
	background: var(--bg-card);
	border: 1px solid var(--border-soft);
	border-radius: 20px;
	overflow: hidden;
}

.search-form {
	display: flex;
	flex-wrap: wrap;
	gap: 12px;
	align-items: center;
	margin-top: 18px;
	margin-bottom: 22px;
}

.search-input-wrap {
	flex: 1;
	min-width: 220px;
}

.search-input {
	height: 42px;
	background-color: #12121a !important;
	border: 1px solid rgba(192, 132, 252, 0.18) !important;
	color: #f8f5ff !important;
	border-radius: 12px;
	padding: 0 14px;
}

.search-input:focus {
	background-color: #171721 !important;
	color: #ffffff !important;
	border-color: #8a2be2 !important;
	box-shadow: 0 0 0 0.18rem rgba(138, 43, 226, 0.18) !important;
	outline: none;
}

.search-input::placeholder {
	color: #867a9c;
}

.table-dark-custom {
	--bs-table-bg: transparent;
	--bs-table-color: #f3f4f6;
	--bs-table-border-color: rgba(168, 85, 247, 0.14);
	margin-bottom: 0;
	width: 100%;
}

.table-dark-custom thead th {
	color: var(--purple-light);
	font-weight: 700;
	white-space: nowrap;
	border-bottom: 1px solid rgba(168, 85, 247, 0.26);
	background: rgba(168, 85, 247, 0.05);
	padding-top: 16px;
	padding-bottom: 16px;
	text-align: center;
}

.table-dark-custom th, .table-dark-custom td {
	vertical-align: middle;
	padding: 18px 16px;
	text-align: center;
}

.table-dark-custom tbody tr:hover {
	background-color: rgba(168, 85, 247, 0.07);
}

.status-pill {
	display: inline-block;
	padding: 6px 12px;
	border-radius: 999px;
	font-size: 0.78rem;
	font-weight: 700;
}

.status-anchored {
	background: var(--green-bg);
	color: var(--green-soft);
	border: 1px solid var(--green-border);
}

.status-docked {
	background: var(--yellow-bg);
	color: var(--yellow-soft);
	border: 1px solid var(--yellow-border);
}

.status-departed {
	background: var(--red-bg);
	color: var(--red-soft);
	border: 1px solid var(--red-border);
}

.action-wrap {
	display: flex;
	flex-wrap: nowrap;
	gap: 8px;
	align-items: center;
	justify-content: center;
	white-space: nowrap;
}

.action-wrap form {
	margin: 0;
	display: inline-flex;
}

.stat-box {
	padding: 20px;
	min-height: 110px;
}

.stat-label {
	color: var(--text-muted);
	font-size: 0.88rem;
	margin-bottom: 8px;
}

.stat-value {
	font-size: 2rem;
	font-weight: 800;
	color: #ffffff;
}

.content-head {
	margin-bottom: 28px;
}

.empty-state {
	padding: 48px 20px;
	text-align: center;
	color: var(--text-muted);
}

/* Modal */
.modal-content.ship-modal {
	background: #171621;
	border: 1px solid rgba(138, 43, 226, 0.45);
	border-radius: 28px;
	color: #fff;
	box-shadow: 0 18px 48px rgba(0, 0, 0, 0.65);
	overflow: hidden;
}

.modal-header.ship-header {
	padding: 18px 22px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
	background: linear-gradient(180deg, #191827 0%, #151420 100%);
}

.modal-title.ship-title {
	font-size: 1.55rem;
	font-weight: 800;
	color: #ffffff;
	margin: 0;
}

.modal-body.ship-body {
	padding: 24px 22px 20px;
	background: #171621;
}

.modal-footer.ship-footer {
	padding: 18px 22px 22px;
	border-top: 1px solid rgba(255, 255, 255, 0.08);
	background: #171621;
	justify-content: flex-end;
	gap: 12px;
}

.modal .btn-close {
	filter: invert(1);
	opacity: 0.85;
	box-shadow: none;
}

.modal .modal-dialog {
	max-width: 640px;
}

.popup-field {
	margin-bottom: 22px;
}

.popup-label {
	display: block;
	color: #e8def8;
	font-size: 1.02rem;
	font-weight: 800;
	margin-bottom: 10px;
}

.popup-input, .popup-select {
	height: 46px;
	border-radius: 18px;
	background: #12111b !important;
	border: 1px solid rgba(138, 43, 226, 0.28) !important;
	color: #ffffff !important;
	padding: 0 16px;
}

.popup-input::placeholder {
	color: rgba(255, 255, 255, 0.12);
}

.popup-input:focus, .popup-select:focus {
	background: #12111b !important;
	color: #ffffff !important;
	border-color: #8a2be2 !important;
	box-shadow: 0 0 0 0.18rem rgba(138, 43, 226, 0.18) !important;
}

.btn-popup-cancel {
	background: transparent;
	border: 1px solid rgba(168, 85, 247, 0.7);
	color: #e8def8;
	min-width: 110px;
	height: 44px;
	border-radius: 14px;
	font-weight: 700;
}

.btn-popup-cancel:hover {
	background: rgba(168, 85, 247, 0.12);
	color: #ffffff;
}

.btn-popup-submit {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
	min-width: 130px;
	height: 44px;
	border-radius: 14px;
	font-weight: 800;
	box-shadow: 0 8px 18px rgba(138, 43, 226, 0.25);
}

.btn-popup-submit:hover {
	background: linear-gradient(135deg, #9b4df1 0%, #b86cff 100%);
	color: #ffffff;
}

/* --- Pagination --- */
.pagination-wrap {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 12px;
	padding: 18px 24px;
	border-top: 1px solid rgba(168, 85, 247, 0.14);
}

.pagination-info {
	color: var(--text-muted);
	font-size: 0.88rem;
}

.pagination-info span {
	color: var(--purple-light);
	font-weight: 700;
}

.pagination-controls {
	display: flex;
	gap: 6px;
	align-items: center;
	flex-wrap: wrap;
}

.page-btn {
	min-width: 36px;
	height: 36px;
	padding: 0 10px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border-radius: 10px;
	font-size: 0.88rem;
	font-weight: 600;
	text-decoration: none;
	border: 1px solid rgba(192, 132, 252, 0.20);
	background: transparent;
	color: var(--text-soft);
	transition: all 0.2s ease;
}

.page-btn:hover {
	background: rgba(168, 85, 247, 0.14);
	border-color: var(--border-strong);
	color: #ffffff;
}

.page-btn.active {
	background: linear-gradient(135deg, #7a22d8 0%, #a855f7 100%);
	border-color: rgba(168, 85, 247, 0.50);
	color: #ffffff;
	pointer-events: none;
}

.page-btn.disabled {
	opacity: 0.35;
	pointer-events: none;
}

@media ( max-width : 991.98px) {
	.sidebar {
		position: static;
		width: 100%;
		height: auto;
		border-right: none;
		border-bottom: 1px solid var(--border-soft);
	}
	.main-content {
		margin-left: 0;
		padding: 20px;
	}
	.search-form {
		flex-direction: column;
		align-items: stretch;
	}
	.search-input-wrap {
		min-width: 100%;
	}
	.action-wrap {
		flex-wrap: wrap;
	}
	.modal .modal-dialog {
		max-width: calc(100% - 24px);
		margin: 12px;
	}
	.pagination-wrap {
		flex-direction: column;
		align-items: flex-start;
	}
}
</style>
</head>
<body>

	<jsp:include page="includes/topbar.jsp" />
	<jsp:include page="includes/sidebar.jsp" />

	<main class="main-content">
		<div class="content-head">
			<h2 class="page-title">Ship Management</h2>
			<p class="page-subtitle">Register ships, search vessel records,
				update ship lifecycle status, and manage departures.</p>
		</div>

		<%
		if (message != null) {
		%>
		<div class="alert alert-success"><%=message%></div>
		<%
		}
		%>

		<%
		if (error != null) {
		%>
		<div class="alert alert-danger"><%=error%></div>
		<%
		}
		%>

		<div class="row g-3 mb-4">
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Anchored Ships</div>
					<div class="stat-value"><%=anchoredCount%></div>
				</div>
			</div>
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Docked Ships</div>
					<div class="stat-value"><%=dockedCount%></div>
				</div>
			</div>
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Departed Ships</div>
					<div class="stat-value"><%=departedCount%></div>
				</div>
			</div>
		</div>

		<div class="table-shell">
			<div class="p-4 pb-0">
				<div
					class="d-flex flex-wrap justify-content-between align-items-start gap-3">
					<div>
						<div class="section-title">Registered Ships</div>
						<div class="section-subtitle">Search by ship ID, ship name,
							or status, then edit or delete ship records.</div>
					</div>
					<button type="button" class="btn btn-purple" data-bs-toggle="modal"
						data-bs-target="#addShipModal">Add Ship</button>
				</div>

				<form action="ShipManagementController" method="get"
					class="search-form">
					<input type="hidden" name="action" value="search">

					<div class="search-input-wrap">
						<input type="text" name="ship_name"
							class="form-control search-input"
							placeholder="Search by ship id or ship name"
							value="<%=shipNameSearch%>">
					</div>

					<div style="min-width: 180px;">
						<select name="status" class="form-select search-input">
							<option value="">All Status</option>
							<option value="Anchored"
								<%="Anchored".equals(statusSearch) ? "selected" : ""%>>Anchored</option>
							<option value="Docked"
								<%="Docked".equals(statusSearch) ? "selected" : ""%>>Docked</option>
							<option value="Departed"
								<%="Departed".equals(statusSearch) ? "selected" : ""%>>Departed</option>
						</select>
					</div>

					<button type="submit" class="btn btn-search">Search</button>

					<%
					if (!shipNameSearch.trim().isEmpty() || !statusSearch.trim().isEmpty()) {
					%>
					<a href="ShipManagementController" class="btn btn-soft-danger">Clear</a>
					<%
					}
					%>
				</form>
			</div>

			<%
			if (shipList.isEmpty()) {
			%>
			<div class="empty-state">
				<%
				if (!shipNameSearch.trim().isEmpty() || !statusSearch.trim().isEmpty()) {
				%>
				No ships found for the selected filters.
				<%
				} else {
				%>
				No ship records found.
				<%
				}
				%>
			</div>
			<%
			} else {
			%>
			<div class="table-responsive">
				<table class="table table-dark-custom align-middle">
					<thead>
						<tr>
							<th>Ship ID</th>
							<th>Ship Name</th>
							<th>Operator</th>
							<th>Arrival</th>
							<th>Departure</th>
							<th>Status</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (int i = startIndex; i < endIndex; i++) {
							Map<String, String> ship = shipList.get(i);
							String shipId = ship.get("ship_id");
							boolean isEditing = editId.equals(shipId);
							String statusValue = ship.get("status");
							String statusClass = "status-departed";
							if ("Anchored".equalsIgnoreCase(statusValue))
								statusClass = "status-anchored";
							else if ("Docked".equalsIgnoreCase(statusValue))
								statusClass = "status-docked";
						%>

						<%
						if (isEditing) {
						%>
						<tr>
							<td><%=shipId%></td>
							<td><input type="text" form="editForm_<%=shipId%>"
								name="ship_name" class="form-control"
								value="<%=ship.get("ship_name")%>" required></td>
							<td><%=ship.get("operator_name")%></td>
							<td><input type="datetime-local" form="editForm_<%=shipId%>"
								name="arrival_date" class="form-control"
								value="<%=ship.get("arrival_date") != null ? ship.get("arrival_date").replace(" ", "T") : ""%>"
								required></td>
							<td><input type="datetime-local" form="editForm_<%=shipId%>"
								name="departure_date" class="form-control"
								value="<%=ship.get("departure_date") != null ? ship.get("departure_date").replace(" ", "T") : ""%>"
								required></td>
							<td><select form="editForm_<%=shipId%>" name="status"
								class="form-select" required>
									<option value="Anchored"
										<%="Anchored".equals(ship.get("status")) ? "selected" : ""%>>Anchored</option>
									<option value="Docked"
										<%="Docked".equals(ship.get("status")) ? "selected" : ""%>>Docked</option>
									<option value="Departed"
										<%="Departed".equals(ship.get("status")) ? "selected" : ""%>>Departed</option>
							</select></td>
							<td>
								<div class="action-wrap">
									<form id="editForm_<%=shipId%>"
										action="ShipManagementController" method="post">
										<input type="hidden" name="action" value="update"> <input
											type="hidden" name="ship_id" value="<%=shipId%>"> <input
											type="hidden" name="ship_name_search"
											value="<%=shipNameSearch%>"> <input type="hidden"
											name="status_search" value="<%=statusSearch%>"> <input
											type="hidden" name="page" value="<%=currentPage%>">
										<button type="submit" class="btn btn-sm btn-purple">Update</button>
									</form>
									<a
										href="ShipManagementController?<%=filterQuery%>&page=<%=currentPage%>"
										class="btn btn-sm btn-outline-purple">Cancel</a>
								</div>
							</td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td><%=shipId%></td>
							<td><%=ship.get("ship_name")%></td>
							<td><%=ship.get("operator_name")%></td>
							<td><%=ship.get("arrival_date")%></td>
							<td><%=ship.get("departure_date")%></td>
							<td><span class="status-pill <%=statusClass%>"><%=statusValue%></span></td>
							<td>
								<div class="action-wrap">
									<a
										href="ShipManagementController?action=edit&editId=<%=shipId%>&<%=filterQuery%>&page=<%=currentPage%>"
										class="btn btn-sm btn-outline-purple">Edit</a>

									<%
									if (canDelete) {
									%>
									<form action="ShipManagementController" method="post"
										onsubmit="return confirm('Are you sure you want to delete this ship?');">
										<input type="hidden" name="action" value="delete"> <input
											type="hidden" name="ship_id" value="<%=shipId%>"> <input
											type="hidden" name="ship_name_search"
											value="<%=shipNameSearch%>"> <input type="hidden"
											name="status_search" value="<%=statusSearch%>"> <input
											type="hidden" name="page" value="<%=currentPage%>">
										<button type="submit" class="btn btn-sm btn-soft-danger">Delete</button>
									</form>
									<%
									}
									%>
								</div>
							</td>
						</tr>
						<%
						}
						%>

						<%
						}
						%>
					</tbody>
				</table>
			</div>

			<%-- Pagination Bar --%>
			<div class="pagination-wrap">
				<div class="pagination-info">
					Showing <span><%=totalShips == 0 ? 0 : startIndex + 1%>&ndash;<%=endIndex%></span>
					of <span><%=totalShips%></span> ships
				</div>

				<div class="pagination-controls">

					<%-- Prev --%>
					<a
						href="ShipManagementController?<%=filterQuery%>&page=<%=currentPage - 1%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>

					<%
					int startPage = Math.max(1, currentPage - 2);
					int endPage = Math.min(totalPages, currentPage + 2);

					if (startPage > 1) {
					%>
					<a href="ShipManagementController?<%=filterQuery%>&page=1"
						class="page-btn">1</a>
					<%
					if (startPage > 2) {
					%>
					<span class="page-btn disabled">&hellip;</span>
					<%
					}
					%>
					<%
					}

					for (int p = startPage; p <= endPage; p++) {
					%>
					<a href="ShipManagementController?<%=filterQuery%>&page=<%=p%>"
						class="page-btn <%=p == currentPage ? "active" : ""%>"><%=p%></a>
					<%
					}

					if (endPage < totalPages) {
					if (endPage < totalPages - 1) {
					%>
					<span class="page-btn disabled">&hellip;</span>
					<%
					}
					%>
					<a
						href="ShipManagementController?<%=filterQuery%>&page=<%=totalPages%>"
						class="page-btn"><%=totalPages%></a>
					<%
					}
					%>

					<%-- Next --%>
					<a
						href="ShipManagementController?<%=filterQuery%>&page=<%=currentPage + 1%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>

				</div>
			</div>

			<%
			}
			%>
		</div>
	</main>

	<!-- Add Ship Modal -->
	<div class="modal fade" id="addShipModal" tabindex="-1"
		aria-labelledby="addShipModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content ship-modal">
				<div class="modal-header ship-header">
					<h5 class="modal-title ship-title" id="addShipModalLabel">Add
						Ship</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>

				<div class="modal-body ship-body">
					<form action="ShipManagementController" method="post"
						id="addShipForm">
						<input type="hidden" name="action" value="add">

						<div class="popup-field">
							<label class="popup-label">Ship Name</label> <input type="text"
								name="ship_name" class="form-control popup-input"
								placeholder="Enter ship name" required>
						</div>

						<div class="popup-field">
							<label class="popup-label">Arrival Date</label> <input
								type="datetime-local" name="arrival_date"
								class="form-control popup-input" required>
						</div>

						<div class="popup-field">
							<label class="popup-label">Departure Date</label> <input
								type="datetime-local" name="departure_date"
								class="form-control popup-input" required>
						</div>

						<div class="popup-field">
							<label class="popup-label">Status</label> <select name="status"
								class="form-select popup-select" required>
								<option value="Anchored">Anchored</option>
								<option value="Docked">Docked</option>
								<option value="Departed">Departed</option>
							</select>
						</div>
					</form>
				</div>

				<div class="modal-footer ship-footer">
					<button type="button" class="btn btn-popup-cancel"
						data-bs-dismiss="modal">Cancel</button>
					<button type="submit" form="addShipForm"
						class="btn btn-popup-submit">Add Ship</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
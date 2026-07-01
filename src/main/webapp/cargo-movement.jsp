<%@ page import="java.util.*, java.text.SimpleDateFormat"%>
<%
request.setAttribute("activePage", "cargo-movement");
request.setAttribute("topbarTitle", "Cargo Movement");

List<Map<String, String>> cargoList = (List<Map<String, String>>) request.getAttribute("cargoList");
List<Map<String, String>> movementList = (List<Map<String, String>>) request.getAttribute("movementList");
List<Map<String, String>> historyList = (List<Map<String, String>>) request.getAttribute("historyList");

Object historyCargoObj = request.getAttribute("historyCargoId");
String historyCargoId = (historyCargoObj != null) ? String.valueOf(historyCargoObj) : "";

String success = (String) request.getAttribute("success");
String error = (String) request.getAttribute("error");

if (cargoList == null)
	cargoList = new ArrayList<>();
if (movementList == null)
	movementList = new ArrayList<>();
if (historyList == null)
	historyList = new ArrayList<>();

SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat prettyFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

int totalMovements = movementList.size();
int loadCount = 0;
int unloadCount = 0;
int transferCount = 0;

for (Map<String, String> movement : movementList) {
	String type = movement.get("movement_type");
	if ("Load".equalsIgnoreCase(type))
		loadCount++;
	else if ("Unload".equalsIgnoreCase(type))
		unloadCount++;
	else if ("Transfer".equalsIgnoreCase(type))
		transferCount++;
}

boolean isSearchMode = historyCargoId != null && !historyCargoId.trim().isEmpty();
List<Map<String, String>> displayList = isSearchMode ? historyList : movementList;


int pageSize = 10;
int totalItems = (displayList != null) ? displayList.size() : 0;
int totalPages = (int) Math.ceil((double) totalItems / pageSize);

String pageParam = request.getParameter("page");
int currentPage = 1;
try {
	if (pageParam != null)
		currentPage = Integer.parseInt(pageParam);
} catch (Exception ignored) {
}
if (currentPage < 1)
	currentPage = 1;
if (totalPages > 0 && currentPage > totalPages)
	currentPage = totalPages;

int startIndex = (currentPage - 1) * pageSize;
int endIndex = Math.min(startIndex + pageSize, totalItems);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Cargo Movement | Port Management ERP</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">

<style>
:root {
	--bg-main: #0a0a0f;
	--bg-card: #1e1e29;
	--purple-dark: #581c9c;
	--purple-deep: #43156f;
	--purple-bright: #a855f7;
	--purple-light: #eadcff;
	--text-main: #f8f5ff;
	--text-soft: #d8c8f3;
	--text-muted: #aa9fc2;
	--border-soft: rgba(192, 132, 252, 0.20);
	--border-strong: rgba(168, 85, 247, 0.42);
	--shadow-main: 0 14px 30px rgba(0, 0, 0, 0.35);
}

body {
	background: var(--bg-main);
	color: var(--text-main);
	font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
}

.main-content {
	margin-top: 68px;
	margin-left: 260px;
	padding: 30px;
}

.content-head {
	margin-bottom: 28px;
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

.dash-card, .table-shell {
	background: var(--bg-card);
	border: 1px solid var(--border-soft);
	border-radius: 20px;
	box-shadow: var(--shadow-main);
}

.stat-card {
	padding: 22px;
	position: relative;
	overflow: hidden;
	min-height: 110px;
}

.stat-card::before {
	content: "";
	position: absolute;
	inset: 0 0 auto 0;
	height: 3px;
	background: linear-gradient(90deg, var(--purple-deep),
		var(--purple-bright));
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
	margin: 0;
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
	background: #12121a;
	border: 1px solid var(--border-soft);
	color: #ffffff;
	border-radius: 14px;
}

.form-control:focus, .form-select:focus {
	background: #171721;
	color: #ffffff;
	border-color: var(--purple-bright);
	box-shadow: 0 0 0 0.2rem rgba(168, 85, 247, 0.22);
}

.form-control::placeholder {
	color: #8d82a8;
}

.form-select option {
	background: #1b1b2b;
	color: #ffffff;
}

.btn-purple, .btn-outline-purple, .btn-search, .btn-add,
	.btn-soft-danger {
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

.btn-purple, .btn-add {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
}

.btn-outline-purple {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
}

.btn-search {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
	min-width: 96px;
	height: 42px;
}

.btn-add {
	min-width: 120px;
	height: 42px;
}

.btn-soft-danger {
	background: rgba(239, 68, 68, 0.14);
	border: 1px solid rgba(252, 165, 165, 0.28);
	color: #fecaca;
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
	min-width: 260px;
}

.search-input {
	height: 42px;
	background-color: #12121a !important;
	border: 1px solid rgba(192, 132, 252, 0.18) !important;
	color: #f8f5ff !important;
	border-radius: 12px;
	padding: 0 14px;
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
	background: rgba(168, 85, 247, 0.06);
}

.movement-pill {
	display: inline-block;
	padding: 6px 12px;
	border-radius: 999px;
	font-size: 0.78rem;
	font-weight: 700;
	border: 1px solid transparent;
}

.movement-load {
	background: rgba(34, 197, 94, 0.12);
	color: #86efac;
	border-color: rgba(34, 197, 94, 0.25);
}

.movement-unload {
	background: rgba(239, 68, 68, 0.12);
	color: #fca5a5;
	border-color: rgba(239, 68, 68, 0.25);
}

.movement-transfer {
	background: rgba(245, 158, 11, 0.12);
	color: #fcd34d;
	border-color: rgba(245, 158, 11, 0.26);
}

.empty-state {
	padding: 48px 20px;
	text-align: center;
	color: var(--text-muted);
}

.alert-success {
	background: rgba(34, 197, 94, 0.12);
	color: #bbf7d0;
	border: 1px solid rgba(34, 197, 94, 0.28);
}

.alert-danger {
	background: rgba(239, 68, 68, 0.12);
	color: #fecaca;
	border: 1px solid rgba(239, 68, 68, 0.28);
}

.history-highlight {
	border: 1px solid rgba(168, 85, 247, 0.28);
	background: rgba(168, 85, 247, 0.06);
	border-radius: 14px;
	padding: 12px 16px;
	color: #e9d5ff;
	margin-bottom: 18px;
}

.modal-content {
	background: #171722;
	border: 1px solid rgba(192, 132, 252, 0.18);
	border-radius: 22px;
	box-shadow: 0 30px 80px rgba(0, 0, 0, 0.5);
	overflow: hidden;
}

.modal-header {
	border-bottom: 1px solid rgba(192, 132, 252, 0.10);
	padding: 22px 26px;
}

.modal-title {
	font-size: 1.35rem;
	font-weight: 800;
	color: #ffffff;
}

.modal-body {
	padding: 26px;
}

.modal-footer {
	border-top: 1px solid rgba(192, 132, 252, 0.10);
	padding: 22px 26px;
	gap: 12px;
}

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
	.pagination-wrap {
		flex-direction: column;
		align-items: flex-start;
	}
}
</style>
</head>

<body>

	<jsp:include page="/includes/topbar.jsp" />
	<jsp:include page="/includes/sidebar.jsp" />

	<main class="main-content">
		<div class="content-head">
			<h2 class="page-title">Cargo Movement</h2>
			<p class="page-subtitle">Log cargo movement events and use cargo
				ID search to filter the movement history table.</p>
		</div>

		<%
		if (success != null && !success.isEmpty()) {
		%>
		<div class="alert alert-success"><%=success%></div>
		<%
		}
		%>
		<%
		if (error != null && !error.isEmpty()) {
		%>
		<div class="alert alert-danger"><%=error%></div>
		<%
		}
		%>

		<div class="row g-3 mb-4">
			<div class="col-lg-3 col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Total Movements</div>
					<div class="stat-value"><%=totalMovements%></div>
				</div>
			</div>
			<div class="col-lg-3 col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Load Events</div>
					<div class="stat-value"><%=loadCount%></div>
				</div>
			</div>
			<div class="col-lg-3 col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Unload Events</div>
					<div class="stat-value"><%=unloadCount%></div>
				</div>
			</div>
			<div class="col-lg-3 col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Transfer Events</div>
					<div class="stat-value"><%=transferCount%></div>
				</div>
			</div>
		</div>

		<div class="table-shell">
			<div class="p-4 pb-0">
				<div
					class="d-flex justify-content-between align-items-center flex-wrap gap-2">
					<div>
						<div class="section-title">
							<%=isSearchMode ? "Movement History Results" : "Latest Movement History"%>
						</div>
						<div class="section-subtitle">
							<%=isSearchMode ? "Showing movement history filtered by selected cargo ID."
		: "Recent movement records captured in the cargo movement log."%>
						</div>
					</div>

					<button type="button" class="btn-add" data-bs-toggle="modal"
						data-bs-target="#logMovementModal">Log Movement</button>
				</div>


				<form action="CargoMovementController" method="post"
					class="search-form">
					<input type="hidden" name="action" value="history"> <input
						type="hidden" name="page" value="1">

					<div class="search-input-wrap">
						<input type="number" name="cargo_id"
							class="form-control search-input"
							placeholder="Search by cargo ID" value="<%=historyCargoId%>">
					</div>

					<button type="submit" class="btn btn-search">View History</button>

					<%
					if (isSearchMode) {
					%>
					<a href="CargoMovementController" class="btn btn-soft-danger">Clear</a>
					<%
					}
					%>
				</form>

				<%
				if (isSearchMode) {
				%>
				<div class="history-highlight">
					Showing history for cargo ID <strong><%=historyCargoId%></strong>
					&mdash; <span style="color: var(--purple-light); font-weight: 700;"><%=totalItems%></span>
					record<%=totalItems != 1 ? "s" : ""%>
					found
				</div>
				<%
				}
				%>
			</div>


			<%
			if (displayList != null && !displayList.isEmpty()) {
			%>
			<div class="table-responsive">
				<table class="table table-dark-custom align-middle mb-0">
					<thead>
						<tr>
							<th>Movement ID</th>
							<th>Cargo</th>
							<th>Movement Type</th>
							<th>Date</th>
							<th>Handled By</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (int i = startIndex; i < endIndex; i++) {
							Map<String, String> row = displayList.get(i);

							String rawDate = row.get("movement_date");
							String prettyDate = rawDate;
							try {
								prettyDate = prettyFormat.format(dbFormat.parse(rawDate));
							} catch (Exception ignored) {
							}

							String movementType = row.get("movement_type");
							String movementClass = "movement-transfer";
							if ("Load".equalsIgnoreCase(movementType))
								movementClass = "movement-load";
							else if ("Unload".equalsIgnoreCase(movementType))
								movementClass = "movement-unload";

							String handledBy = row.get("handled_by");
							if (handledBy == null || handledBy.trim().isEmpty())
								handledBy = row.get("cargo_handler");
						%>
						<tr>
							<td><%=row.get("movement_id")%></td>
							<td><%=row.get("cargo_description")%></td>
							<td><span class="movement-pill <%=movementClass%>"><%=movementType%></span></td>
							<td><%=prettyDate%></td>
							<td><%=handledBy%></td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>

			<!-- Pagination Bar -->
			<div class="pagination-wrap">
				<div class="pagination-info">
					Showing <span><%=totalItems == 0 ? 0 : startIndex + 1%>&ndash;<%=endIndex%></span>
					of <span><%=totalItems%></span> movement<%=totalItems != 1 ? "s" : ""%>
				</div>

				<div class="pagination-controls">


					<%
					if (isSearchMode) {
					%>
					<a
						href="CargoMovementController?action=history&cargo_id=<%=historyCargoId%>&page=<%=currentPage - 1%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>
					<%
					} else {
					%>
					<a href="CargoMovementController?page=<%=currentPage - 1%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>
					<%
					}
					%>

					<%
					int startPage = Math.max(1, currentPage - 2);
					int endPage = Math.min(totalPages, currentPage + 2);

					if (startPage > 1) {
					%>
					<%
					if (isSearchMode) {
					%>
					<a
						href="CargoMovementController?action=history&cargo_id=<%=historyCargoId%>&page=1"
						class="page-btn">1</a>
					<%
					} else {
					%>
					<a href="CargoMovementController?page=1" class="page-btn">1</a>
					<%
					}
					%>
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
					<%
					if (isSearchMode) {
					%>
					<a
						href="CargoMovementController?action=history&cargo_id=<%=historyCargoId%>&page=<%=p%>"
						class="page-btn <%=p == currentPage ? "active" : ""%>"><%=p%></a>
					<%
					} else {
					%>
					<a href="CargoMovementController?page=<%=p%>"
						class="page-btn <%=p == currentPage ? "active" : ""%>"><%=p%></a>
					<%
					}
					%>
					<%
					}

					if (endPage < totalPages) {
					if (endPage < totalPages - 1) {
					%>
					<span class="page-btn disabled">&hellip;</span>
					<%
					}
					%>
					<%
					if (isSearchMode) {
					%>
					<a
						href="CargoMovementController?action=history&cargo_id=<%=historyCargoId%>&page=<%=totalPages%>"
						class="page-btn"><%=totalPages%></a>
					<%
					} else {
					%>
					<a href="CargoMovementController?page=<%=totalPages%>"
						class="page-btn"><%=totalPages%></a>
					<%
					}
					%>
					<%
					}
					%>

					<%-- Next arrow --%>
					<%
					if (isSearchMode) {
					%>
					<a
						href="CargoMovementController?action=history&cargo_id=<%=historyCargoId%>&page=<%=currentPage + 1%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>
					<%
					} else {
					%>
					<a href="CargoMovementController?page=<%=currentPage + 1%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>
					<%
					}
					%>

				</div>
			</div>

			<%
			} else if (isSearchMode) {
			%>
			<div class="empty-state">
				No movement history found for cargo ID <strong><%=historyCargoId%></strong>.
			</div>
			<%
			} else {
			%>
			<div class="empty-state">No movement records found.</div>
			<%
			}
			%>
		</div>
	</main>

	<!-- Log Movement Modal -->
	<div class="modal fade" id="logMovementModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<form action="CargoMovementController" method="post">
					<input type="hidden" name="action" value="movement">

					<div class="modal-header">
						<h5 class="modal-title">Log Cargo Movement</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal"></button>
					</div>

					<div class="modal-body">
						<div class="mb-3">
							<label class="form-label">Cargo</label> <select
								class="form-select" name="cargo_id" required>
								<option value="">Select cargo</option>
								<%
								for (Map<String, String> cargo : cargoList) {
								%>
								<option value="<%=cargo.get("cargo_id")%>">
									<%=cargo.get("description")%> (ID:
									<%=cargo.get("cargo_id")%>)
								</option>
								<%
								}
								%>
							</select>
						</div>

						<div class="mb-3">
							<label class="form-label">Movement Type</label> <select
								class="form-select" name="movement_type" required>
								<option value="">Select movement type</option>
								<option value="Load">Load</option>
								<option value="Unload">Unload</option>
								<option value="Transfer">Transfer</option>
							</select>
						</div>
					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-outline-purple"
							data-bs-dismiss="modal">Cancel</button>
						<button type="submit" class="btn btn-purple">Confirm
							Movement</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
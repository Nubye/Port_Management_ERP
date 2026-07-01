<%@ page import="java.util.ArrayList"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%
request.setAttribute("activePage", "security-log");
request.setAttribute("topbarTitle", "Security Log");

String username = (String) request.getAttribute("username");
String roleVal = "";
Object roleObj = request.getAttribute("role");
if (roleObj != null)
	roleVal = roleObj.toString();

String fromDate = (String) request.getAttribute("fromDate");
String toDate = (String) request.getAttribute("toDate");

if (username == null)
	username = "";
if (fromDate == null)
	fromDate = "";
if (toDate == null)
	toDate = "";
if (roleVal == null)
	roleVal = "";

ArrayList<Map<String, String>> logRows = (ArrayList<Map<String, String>>) request.getAttribute("logRows");
if (logRows == null)
	logRows = new ArrayList<>();

SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat prettyFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

boolean hasFilters = !username.trim().isEmpty() || !fromDate.trim().isEmpty() || !toDate.trim().isEmpty()
		|| (!roleVal.trim().isEmpty() && !"Select Role".equalsIgnoreCase(roleVal));

// --- Pagination ---
int pageSize = 10;
int totalLogs = logRows.size();
int totalPages = (int) Math.ceil((double) totalLogs / pageSize);

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
int endIndex = Math.min(startIndex + pageSize, totalLogs);
%>
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Security Log | Port Management ERP</title>

<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link href="assets/css/common.css" rel="stylesheet">

<style>
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

.btn-outline-purple, .btn-search, .btn-export, .btn-soft-danger {
	min-width: 82px;
	height: 42px;
	padding: 0 14px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border-radius: 12px;
	font-weight: 700;
	line-height: 1;
	white-space: nowrap;
	text-decoration: none;
	gap: 6px;
}

.btn-outline-purple, .btn-search {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
}

.btn-soft-danger {
	background: rgba(239, 68, 68, 0.14);
	border: 1px solid rgba(252, 165, 165, 0.28);
	color: #fecaca;
}

.btn-export {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
	min-width: 120px;
}

.search-form {
	display: flex;
	flex-wrap: wrap;
	gap: 12px;
	align-items: end;
	margin-top: 18px;
	margin-bottom: 22px;
}

.filter-field {
	flex: 1;
	min-width: 200px;
}

.filter-actions {
	display: flex;
	flex-wrap: wrap;
	gap: 10px;
	align-items: center;
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

.role-pill {
	display: inline-block;
	padding: 6px 12px;
	border-radius: 999px;
	font-size: 0.78rem;
	font-weight: 700;
	border: 1px solid transparent;
}

.role-admin {
	background: rgba(239, 68, 68, 0.12);
	color: #fca5a5;
	border-color: rgba(239, 68, 68, 0.25);
}

.role-port-manager {
	background: rgba(59, 130, 246, 0.12);
	color: #93c5fd;
	border-color: rgba(59, 130, 246, 0.25);
}

.role-ship-operator {
	background: rgba(34, 197, 94, 0.12);
	color: #86efac;
	border-color: rgba(34, 197, 94, 0.25);
}

.role-dock-manager {
	background: rgba(245, 158, 11, 0.12);
	color: #fcd34d;
	border-color: rgba(245, 158, 11, 0.26);
}

.role-cargo-handler {
	background: rgba(168, 85, 247, 0.14);
	color: #d8b4fe;
	border-color: rgba(168, 85, 247, 0.30);
}

.empty-state {
	padding: 48px 20px;
	text-align: center;
	color: var(--text-muted);
}

.filter-highlight {
	border: 1px solid rgba(168, 85, 247, 0.28);
	background: rgba(168, 85, 247, 0.06);
	border-radius: 14px;
	padding: 12px 16px;
	color: #e9d5ff;
	margin-bottom: 18px;
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
		width: auto;
		height: auto;
	}
	.main-content {
		margin-left: 0;
		padding: 20px;
	}
	.search-form {
		flex-direction: column;
		align-items: stretch;
	}
	.filter-field {
		min-width: 100%;
	}
	.filter-actions {
		justify-content: stretch;
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
			<h2 class="page-title">Security Log</h2>
			<p class="page-subtitle">Audit and compliance monitoring for user
				sessions, access visibility, and export-ready log review.</p>
		</div>

		<div class="table-shell">
			<div class="p-4 pb-0">
				<div
					class="d-flex justify-content-between align-items-center flex-wrap gap-2">
					<div>
						<div class="section-title">Security Log Records</div>
						<div class="section-subtitle">Filter by username, role, or
							date range, then export matching audit records.</div>
					</div>

					<form method="get" action="SecurityLogController" class="m-0">
						<input type="hidden" name="username" value="<%=username%>">
						<input type="hidden" name="fromDate" value="<%=fromDate%>">
						<input type="hidden" name="toDate" value="<%=toDate%>"> <input
							type="hidden" name="role" value="<%=roleVal%>">
						<button type="submit" name="action" value="export"
							class="btn-export">Export CSV</button>
					</form>
				</div>

				<form class="search-form" method="get"
					action="SecurityLogController">
					<div class="filter-field">
						<label class="form-label">Search User</label> <input type="text"
							name="username" class="form-control" placeholder="Enter username"
							value="<%=username%>">
					</div>

					<div class="filter-field">
						<label class="form-label">From Date</label> <input type="date"
							name="fromDate" class="form-control" value="<%=fromDate%>">
					</div>

					<div class="filter-field">
						<label class="form-label">To Date</label> <input type="date"
							name="toDate" class="form-control" value="<%=toDate%>">
					</div>

					<div class="filter-field">
						<label class="form-label">Role</label> <select name="role"
							class="form-select">
							<option value="Select Role"
								<%="Select Role".equals(roleVal) ? "selected" : ""%>>Select
								Role</option>
							<option value="Admin"
								<%="Admin".equals(roleVal) ? "selected" : ""%>>Admin</option>
							<option value="Port Manager"
								<%="Port Manager".equals(roleVal) ? "selected" : ""%>>Port
								Manager</option>
							<option value="Ship Operator"
								<%="Ship Operator".equals(roleVal) ? "selected" : ""%>>Ship
								Operator</option>
							<option value="Dock Manager"
								<%="Dock Manager".equals(roleVal) ? "selected" : ""%>>Dock
								Manager</option>
							<option value="Cargo Handler"
								<%="Cargo Handler".equals(roleVal) ? "selected" : ""%>>Cargo
								Handler</option>
						</select>
					</div>

					<div class="filter-actions">
						<button type="submit" class="btn btn-search">Search</button>
						<%
						if (hasFilters) {
						%>
						<a class="btn btn-soft-danger" href="SecurityLogController">Clear</a>
						<%
						}
						%>
					</div>
				</form>

				<%
				if (hasFilters) {
				%>
				<div class="filter-highlight">Filtered audit results are being
					shown based on the selected search criteria.</div>
				<%
				}
				%>
			</div>

			<%
			if (logRows.isEmpty()) {
			%>
			<div class="empty-state">No security log records found for the
				current filters.</div>
			<%
			} else {
			%>
			<div class="table-responsive">
				<table class="table table-dark-custom align-middle mb-0">
					<thead>
						<tr>
							<th>Username</th>
							<th>Role</th>
							<th>Entry Time</th>
							<th>Exit Time</th>
							<th>Session Duration</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (int i = startIndex; i < endIndex; i++) {
							Map<String, String> log = logRows.get(i);

							String roleName = log.get("roleName");
							String roleClass = "role-cargo-handler";

							if ("Admin".equalsIgnoreCase(roleName))
								roleClass = "role-admin";
							else if ("Port Manager".equalsIgnoreCase(roleName))
								roleClass = "role-port-manager";
							else if ("Ship Operator".equalsIgnoreCase(roleName))
								roleClass = "role-ship-operator";
							else if ("Dock Manager".equalsIgnoreCase(roleName))
								roleClass = "role-dock-manager";
							else if ("Cargo Handler".equalsIgnoreCase(roleName))
								roleClass = "role-cargo-handler";

							// --- Entry Time ---
							String entryTimeRaw = log.get("entryTime");
							String entryTimePretty = entryTimeRaw;
							try {
								entryTimePretty = prettyFormat.format(dbFormat.parse(entryTimeRaw));
							} catch (Exception e) {
							}

							// --- Exit Time ---
							String exitTimeRaw = log.get("exitTime");
							String exitTimePretty = "-";
							try {
								if (exitTimeRaw != null && !exitTimeRaw.trim().isEmpty()) {
							exitTimePretty = prettyFormat.format(dbFormat.parse(exitTimeRaw));
								}
							} catch (Exception e) {
							}

							String sessionDuration = log.get("sessionDuration");
							if (sessionDuration == null || sessionDuration.trim().isEmpty()) {
								sessionDuration = "-";
							}
						%>
						<tr>
							<td class="fw-semibold"><%=log.get("username")%></td>
							<td><span class="role-pill <%=roleClass%>"><%=roleName%></span></td>
							<td><%=entryTimePretty%></td>
							<td><%=exitTimePretty%></td>
							<td><%=sessionDuration%></td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
			</div>

			<%-- Pagination Bar --%>
			<%
			String filterQuery = "&username=" + java.net.URLEncoder.encode(username, "UTF-8") + "&fromDate="
					+ java.net.URLEncoder.encode(fromDate, "UTF-8") + "&toDate=" + java.net.URLEncoder.encode(toDate, "UTF-8")
					+ "&role=" + java.net.URLEncoder.encode(roleVal, "UTF-8");
			%>
			<div class="pagination-wrap">
				<div class="pagination-info">
					Showing <span><%=startIndex + 1%>–<%=endIndex%></span> of <span><%=totalLogs%></span>
					records
				</div>

				<div class="pagination-controls">

					<%-- Prev button --%>
					<a
						href="SecurityLogController?page=<%=currentPage - 1%><%=filterQuery%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>

					<%-- Page number buttons (show up to 5 around current) --%>
					<%
					int startPage = Math.max(1, currentPage - 2);
					int endPage = Math.min(totalPages, currentPage + 2);

					if (startPage > 1) {
					%>
					<a href="SecurityLogController?page=1<%=filterQuery%>"
						class="page-btn">1</a>
					<%
					if (startPage > 2) {
					%><span class="page-btn disabled">…</span>
					<%
					}
					%>
					<%
					}

					for (int p = startPage; p <= endPage; p++) {
					%>
					<a href="SecurityLogController?page=<%=p%><%=filterQuery%>"
						class="page-btn <%=p == currentPage ? "active" : ""%>"><%=p%></a>
					<%
					}

					if (endPage < totalPages) {
					if (endPage < totalPages - 1) {
					%><span
						class="page-btn disabled">…</span>
					<%
					}
					%>
					<a
						href="SecurityLogController?page=<%=totalPages%><%=filterQuery%>"
						class="page-btn"><%=totalPages%></a>
					<%
					}
					%>

					<%-- Next button --%>
					<a
						href="SecurityLogController?page=<%=currentPage + 1%><%=filterQuery%>"
						class="page-btn <%=currentPage == totalPages ? "disabled" : ""%>">&#8594;</a>

				</div>
			</div>
			<%
			}
			%>
		</div>
	</main>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
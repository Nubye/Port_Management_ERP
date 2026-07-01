<%@ page import="java.util.*" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder"%>
<%
Integer roleId = (Integer) request.getAttribute("roleId");
String roleName = (String) request.getAttribute("roleName");
if (roleName == null) roleName = "User";
String activePage = (String) request.getAttribute("activePage");

List<Map<String, String>> dockList = (List<Map<String, String>>) request.getAttribute("dockList");

String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");
String editId = request.getParameter("editId");
String searchDockName = (String) request.getAttribute("dock_name");
String searchStatus = (String) request.getAttribute("status");

if (dockList == null) dockList = new ArrayList<>();
if (searchDockName == null) searchDockName = "";
if (searchStatus == null) searchStatus = "";

boolean hasFilter = !searchDockName.trim().isEmpty() || !searchStatus.trim().isEmpty();

int available = 0, occupied = 0, maintenance = 0;
for (Map<String, String> d : dockList) {
    String st = d.get("status");
    if ("Available".equalsIgnoreCase(st)) available++;
    else if ("Occupied".equalsIgnoreCase(st)) occupied++;
    else maintenance++;
}

int totalDocks = dockList.size();
int pageSize = 10;
int totalPages = (int) Math.ceil((double) totalDocks / pageSize);
if (totalPages == 0) totalPages = 1;

int currentPage = 1;
try {
    String pageParam = request.getParameter("page");
    if (pageParam != null) currentPage = Integer.parseInt(pageParam);
} catch (NumberFormatException e) {
    currentPage = 1;
}
if (currentPage < 1) currentPage = 1;
if (currentPage > totalPages) currentPage = totalPages;

int startIndex = (currentPage - 1) * pageSize;
int endIndex = Math.min(startIndex + pageSize, totalDocks);
if (startIndex > endIndex) startIndex = endIndex;

String filterQuery = "dock_name=" + URLEncoder.encode(searchDockName, "UTF-8")
        + "&status=" + URLEncoder.encode(searchStatus, "UTF-8");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dock Management | Port Management ERP</title>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
<style>
:root {
	--bg-main: #0d0d14;
	--bg-card: #171722;
	--text-main: #f3f4f6;
	--text-soft: #cbd5e1;
	--text-muted: #94a3b8;
	--border-soft: rgba(168, 85, 247, 0.14);
	--border-strong: rgba(168, 85, 247, 0.35);
	--shadow-main: 0 10px 30px rgba(0, 0, 0, 0.35);
	--purple-deep: #7a22d8;
	--purple-bright: #a855f7;
	--purple-light: #d8b4fe;
	--purple-soft: #c4a6f0;
	--green-soft: #86efac;
	--green-bg: rgba(34, 197, 94, 0.14);
	--green-border: rgba(134, 239, 172, 0.28);
	--yellow-soft: #fde68a;
	--yellow-bg: rgba(245, 158, 11, 0.14);
	--yellow-border: rgba(253, 230, 138, 0.28);
	--red-soft: #fca5a5;
	--red-bg: rgba(239, 68, 68, 0.14);
	--red-border: rgba(252, 165, 165, 0.28);
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

.btn-toggle-create {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
	height: 42px;
	min-width: 120px;
	padding: 0 16px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border-radius: 12px;
	font-weight: 700;
	text-decoration: none;
	white-space: nowrap;
}

.btn-toggle-create:hover {
	background: linear-gradient(135deg, #9b4df1 0%, #b86cff 100%);
	color: #ffffff;
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

.search-input, .search-select {
	height: 42px;
	background-color: #12121a !important;
	border: 1px solid rgba(192, 132, 252, 0.18) !important;
	color: #f8f5ff !important;
	border-radius: 12px;
	padding: 0 14px;
	width: 100%;
}

.search-input:focus, .search-select:focus {
	background-color: #171721 !important;
	color: #ffffff !important;
	border-color: #8a2be2 !important;
	box-shadow: 0 0 0 0.18rem rgba(138, 43, 226, 0.18) !important;
	outline: none;
}

.search-input::placeholder {
	color: #867a9c;
}

.search-select option {
	background-color: #181821 !important;
	color: #f8f5ff !important;
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

.status-available {
	background: var(--green-bg);
	color: var(--green-soft);
	border: 1px solid var(--green-border);
}

.status-occupied {
	background: var(--yellow-bg);
	color: var(--yellow-soft);
	border: 1px solid var(--yellow-border);
}

.status-maintenance {
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

.empty-state {
	padding: 48px 20px;
	text-align: center;
	color: var(--text-muted);
}

.content-head {
	margin-bottom: 28px;
}

.modal-content.add-user-modal {
	background: #171621;
	border: 1px solid rgba(138, 43, 226, 0.45);
	border-radius: 28px;
	color: #fff;
	box-shadow: 0 18px 48px rgba(0, 0, 0, 0.65);
	overflow: hidden;
}

.modal-header.add-user-header {
	padding: 18px 22px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
	background: linear-gradient(180deg, #191827 0%, #151420 100%);
}

.modal-title {
	font-size: 1.55rem;
	font-weight: 800;
	color: #ffffff;
	margin: 0;
}

.modal-body.add-user-body {
	padding: 24px 22px 20px;
	background: #171621;
}

.modal-footer.add-user-footer {
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

	<jsp:include page="/includes/topbar.jsp" />
	<jsp:include page="/includes/sidebar.jsp" />

	<main class="main-content">
		<div class="content-head">
			<h2 class="page-title">Dock Management</h2>
			<p class="page-subtitle">Add new docks, update dock statuses, and
				monitor allocations from one place.</p>
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
					<div class="stat-label">Available Docks</div>
					<div class="stat-value"><%=available%></div>
				</div>
			</div>
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Occupied Docks</div>
					<div class="stat-value"><%=occupied%></div>
				</div>
			</div>
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Under Maintenance</div>
					<div class="stat-value"><%=maintenance%></div>
				</div>
			</div>
		</div>

		<div class="table-shell">
			<div class="p-4 pb-0">
				<div
					class="d-flex flex-wrap justify-content-between align-items-center gap-3">
					<div>
						<div class="section-title">Dock Records</div>
						<div class="section-subtitle">Search by dock name or status,
							then edit or delete dock records.</div>
					</div>
					<button type="button" class="btn-toggle-create"
						data-bs-toggle="modal" data-bs-target="#createDockModal">Create
						Dock</button>
				</div>

				<form action="DockManagementController" method="get"
					class="search-form">
					<input type="hidden" name="action" value="search">

					<div class="search-input-wrap">
						<input type="text" name="dock_name"
							class="form-control search-input"
							placeholder="Search by Dock Name" value="<%=searchDockName%>">
					</div>

					<div class="search-input-wrap">
						<select name="status" class="form-select search-select">
							<option value="">All Status</option>
							<option value="Available"
								<%="Available".equalsIgnoreCase(searchStatus) ? "selected" : ""%>>Available</option>
							<option value="Occupied"
								<%="Occupied".equalsIgnoreCase(searchStatus) ? "selected" : ""%>>Occupied</option>
							<option value="Under Maintenance"
								<%="Under Maintenance".equalsIgnoreCase(searchStatus) ? "selected" : ""%>>Under
								Maintenance</option>
						</select>
					</div>

					<button type="submit" class="btn btn-search">Search</button>

					<%
if (hasFilter) {
%>
					<a href="DockManagementController" class="btn btn-soft-danger">Clear</a>
					<%
}
%>
				</form>
			</div>

			<%
if (dockList.isEmpty()) {
%>
			<div class="empty-state">
				<%
if (hasFilter) {
%>
				No docks found for the current search.
				<%
} else {
%>
				No dock records found.
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
							<th>Dock ID</th>
							<th>Dock Name</th>
							<th>Status</th>
							<th>Ship</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
for (int i = startIndex; i < endIndex; i++) {
Map<String, String> dock = dockList.get(i);
String dockId = dock.get("dock_id");
boolean isEditing = editId != null && editId.equals(dockId);
String status = dock.get("status");
String statusClass = "status-maintenance";
if ("Available".equalsIgnoreCase(status))
    statusClass = "status-available";
else if ("Occupied".equalsIgnoreCase(status))
    statusClass = "status-occupied";

String shipName = dock.get("ship_name");
if (shipName == null || shipName.trim().isEmpty())
    shipName = "No Ship Assigned";
%>

						<%
if (isEditing) {
%>
						<tr>
							<td><%=dockId%></td>
							<td><input type="text" form="editForm_<%=dockId%>"
								name="dock_name" class="form-control"
								value="<%=dock.get("dock_name")%>" required></td>
							<td><select form="editForm_<%=dockId%>" name="status"
								class="form-select" required>
									<option value="Available"
										<%="Available".equalsIgnoreCase(status) ? "selected" : ""%>>Available</option>
									<option value="Under Maintenance"
										<%="Under Maintenance".equalsIgnoreCase(status) ? "selected" : ""%>>Under
										Maintenance</option>
							</select></td>
							<td><%=shipName%></td>
							<td>
								<div class="action-wrap">
									<form id="editForm_<%=dockId%>"
										action="DockManagementController" method="post">
										<input type="hidden" name="dock_id" value="<%=dockId%>">
										<input type="hidden" name="dock_name_search"
											value="<%=searchDockName%>"> <input type="hidden"
											name="status_search" value="<%=searchStatus%>"> <input
											type="hidden" name="page" value="<%=currentPage%>">
										<button type="submit" name="update" value="update"
											class="btn btn-sm btn-purple">Update</button>
									</form>
									<a
										href="DockManagementController?<%=filterQuery%>&page=<%=currentPage%>"
										class="btn btn-sm btn-outline-purple">Cancel</a>
								</div>
							</td>
						</tr>
						<%
} else {
%>
						<tr>
							<td><%=dockId%></td>
							<td><%=dock.get("dock_name")%></td>
							<td><span class="status-pill <%=statusClass%>"><%=status%></span></td>
							<td><%=shipName%></td>
							<td>
								<div class="action-wrap">
									<a
										href="DockManagementController?editId=<%=dockId%>&<%=filterQuery%>&page=<%=currentPage%>"
										class="btn btn-sm btn-outline-purple">Edit</a>

									<form action="DockManagementController" method="post"
										onsubmit="return confirm('Delete <%=dock.get("dock_name")%>?');">
										<input type="hidden" name="dock_id" value="<%=dockId%>">
										<input type="hidden" name="dock_name_search"
											value="<%=searchDockName%>"> <input type="hidden"
											name="status_search" value="<%=searchStatus%>"> <input
											type="hidden" name="page" value="<%=currentPage%>">
										<button type="submit" name="delete" value="delete"
											class="btn btn-sm btn-soft-danger">Delete</button>
									</form>
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
					Showing <span><%=totalDocks == 0 ? 0 : startIndex + 1%>&ndash;<%=endIndex%></span>
					of <span><%=totalDocks%></span> docks
				</div>

				<div class="pagination-controls">

					<a
						href="DockManagementController?<%=filterQuery%>&page=<%=currentPage - 1%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>

					<%
int startPage = Math.max(1, currentPage - 2);
int endPage = Math.min(totalPages, currentPage + 2);

if (startPage > 1) {
%>
					<a href="DockManagementController?<%=filterQuery%>&page=1"
						class="page-btn">1</a>
					<%
    if (startPage > 2) {
%>
					<span class="page-btn disabled">&hellip;</span>
					<%
    }
}

for (int p = startPage; p <= endPage; p++) {
%>
					<a href="DockManagementController?<%=filterQuery%>&page=<%=p%>"
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
						href="DockManagementController?<%=filterQuery%>&page=<%=totalPages%>"
						class="page-btn"><%=totalPages%></a>
					<%
}
%>

					<a
						href="DockManagementController?<%=filterQuery%>&page=<%=currentPage + 1%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>

				</div>
			</div>

			<%
}
%>
		</div>
	</main>

	<div class="modal fade" id="createDockModal" tabindex="-1"
		aria-labelledby="createDockModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content add-user-modal">
				<div class="modal-header add-user-header">
					<h5 class="modal-title" id="createDockModalLabel">Create New
						Dock</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>

				<div class="modal-body add-user-body">
					<form action="DockManagementController" method="post"
						id="createDockForm">
						<div class="popup-field">
							<label class="popup-label">Dock Name</label> <input type="text"
								class="form-control popup-input" name="dock_name"
								placeholder="Enter dock name" required>
						</div>
						<div class="popup-field">
							<label class="popup-label">Status</label> <select
								class="form-select popup-select" name="status" required>
								<option value="">Select status</option>
								<option value="Available">Available</option>
								<option value="Under Maintenance">Under Maintenance</option>
							</select>
						</div>
						<input type="hidden" name="add" value="add">
					</form>
				</div>

				<div class="modal-footer add-user-footer">
					<button type="button" class="btn btn-popup-cancel"
						data-bs-dismiss="modal">Cancel</button>
					<button type="submit" form="createDockForm"
						class="btn btn-popup-submit">Add Dock</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
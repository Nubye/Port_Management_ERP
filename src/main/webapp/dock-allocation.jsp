<%@ page import="java.util.*" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.net.URLEncoder"%>
<%
Integer roleId = (Integer) request.getAttribute("roleId");
String roleName = (String) request.getAttribute("roleName");
if (roleName == null)
	roleName = "User";
String activePage = (String) request.getAttribute("activePage");

List<Map<String, String>> shipList = (List<Map<String, String>>) request.getAttribute("shipList");
List<Map<String, String>> dockList = (List<Map<String, String>>) request.getAttribute("dockList");
List<Map<String, String>> allocationList = (List<Map<String, String>>) request.getAttribute("allocationList");

String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");
String editId = request.getParameter("editId");
String search = (String) request.getAttribute("search");
String statusFilter = (String) request.getAttribute("statusFilter");

if (shipList == null)
	shipList = new ArrayList<>();
if (dockList == null)
	dockList = new ArrayList<>();
if (allocationList == null)
	allocationList = new ArrayList<>();
if (search == null)
	search = "";
if (statusFilter == null)
	statusFilter = "All";

int totalDocks = dockList.size();
int activeAllocations = 0;
for (Map<String, String> a : allocationList) {
	if ("Active".equalsIgnoreCase(a.get("status")))
		activeAllocations++;
}

int totalAllocations = allocationList.size();
int pageSize = 10;
int totalPages = (int) Math.ceil((double) totalAllocations / pageSize);
if (totalPages == 0)
	totalPages = 1;

int currentPage = 1;
try {
	String pageParam = request.getParameter("page");
	if (pageParam != null)
		currentPage = Integer.parseInt(pageParam);
} catch (NumberFormatException e) {
	currentPage = 1;
}
if (currentPage < 1)
	currentPage = 1;
if (currentPage > totalPages)
	currentPage = totalPages;

int startIndex = (currentPage - 1) * pageSize;
int endIndex = Math.min(startIndex + pageSize, totalAllocations);
if (startIndex > endIndex)
	startIndex = endIndex;

String filterQuery = "search=" + URLEncoder.encode(search, "UTF-8") + "&statusFilter="
		+ URLEncoder.encode(statusFilter, "UTF-8");

SimpleDateFormat dbFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
SimpleDateFormat prettyFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dock Allocation | Port Management ERP</title>
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
	--purple-dark: #4a1280;
	--purple-light: #d8b4fe;
	--purple-soft: #c4a6f0;
	--green-soft: #86efac;
	--green-bg: rgba(34, 197, 94, 0.14);
	--green-border: rgba(134, 239, 172, 0.28);
	--red-soft: #fca5a5;
	--red-bg: rgba(239, 68, 68, 0.14);
	--red-border: rgba(252, 165, 165, 0.28);
	--yellow-soft: #fde68a;
	--yellow-bg: rgba(245, 158, 11, 0.14);
	--yellow-border: rgba(253, 230, 138, 0.28);
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
	min-width: 140px;
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

.btn-purple, .btn-outline-purple, .btn-soft-danger, .btn-soft-warning,
	.btn-search {
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

.btn-soft-warning {
	background: var(--yellow-bg);
	border: 1px solid var(--yellow-border);
	color: #fde68a;
}

.btn-soft-warning:hover {
	background: rgba(245, 158, 11, 0.20);
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
	flex-wrap: nowrap;
	gap: 12px;
	align-items: center;
	margin-top: 18px;
	margin-bottom: 22px;
	width: 100%;
}

.search-input-wrap {
	flex: 1 1 260px;
	min-width: 200px;
}

.search-input {
	height: 42px;
	background-color: #12121a !important;
	border: 1px solid rgba(192, 132, 252, 0.18) !important;
	color: #f8f5ff !important;
	border-radius: 12px;
	padding: 0 14px;
}

.search-select {
	height: 42px;
	background-color: #12121a !important;
	border: 1px solid rgba(192, 132, 252, 0.18) !important;
	color: #f8f5ff !important;
	border-radius: 12px;
	padding: 0 14px;
	min-width: 180px;
	width: 190px;
	flex: 0 0 190px;
}

.search-select option {
	background: #1b1b2b;
	color: #ffffff;
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
	background-color: rgba(168, 85, 247, 0.07);
}

.status-pill {
	display: inline-block;
	padding: 6px 12px;
	border-radius: 999px;
	font-size: 0.78rem;
	font-weight: 700;
	background: rgba(168, 85, 247, 0.15);
	color: var(--purple-light);
	border: 1px solid rgba(192, 132, 252, 0.30);
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
			<h2 class="page-title">Dock Allocation</h2>
			<p class="page-subtitle">Assign ships to berths, monitor active
				occupancy, and manage release or update actions directly from the
				allocation table.</p>
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
			<div class="col-lg-6 col-md-6">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Total Docks Available</div>
					<div class="stat-value"><%=totalDocks%></div>
				</div>
			</div>
			<div class="col-lg-6 col-md-6">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Active Allocations</div>
					<div class="stat-value"><%=activeAllocations%></div>
				</div>
			</div>
		</div>

		<div class="table-shell">
			<div class="p-4 pb-0">
				<div
					class="d-flex justify-content-between align-items-center flex-wrap gap-2">
					<div>
						<div class="section-title">Allocations</div>
						<div class="section-subtitle">Search allocations using Dock
							ID, then edit, release, or delete directly from the table.</div>
					</div>
					<button type="button" class="btn-toggle-create"
						data-bs-toggle="modal" data-bs-target="#dockModal">Allocate
						Dock</button>
				</div>

				<form action="DockAllocationController" method="get"
					class="search-form">
					<div class="search-input-wrap">
						<input type="text" name="search" class="form-control search-input"
							placeholder="Search by Dock ID" value="<%=search%>">
					</div>

					<select name="statusFilter" class="form-select search-select">
						<option value="All"
							<%="All".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>All</option>
						<option value="Active"
							<%="Active".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Active</option>
						<option value="Released"
							<%="Released".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Released</option>
					</select>

					<button type="submit" class="btn btn-search">Search</button>

					<%
					if (!search.trim().isEmpty() || !"All".equalsIgnoreCase(statusFilter)) {
					%>
					<a href="DockAllocationController" class="btn btn-soft-danger">Clear</a>
					<%
					}
					%>
				</form>
			</div>

			<%
			if (allocationList.isEmpty()) {
			%>
			<div class="empty-state">
				<%
				if (!search.trim().isEmpty()) {
				%>
				No allocations found for Dock ID "<%=search%>".
				<%
				} else {
				%>
				No allocations found.
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
							<th>Allocation ID</th>
							<th>Ship ID</th>
							<th>Dock ID</th>
							<th>Allocation Time</th>
							<th>Release Time</th>
							<th>Status</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (int i = startIndex; i < endIndex; i++) {
							Map<String, String> allocation = allocationList.get(i);
							String allocationId = allocation.get("allocation_id");

							String allocationTimeRaw = allocation.get("allocation_time");
							String releaseTimeRaw = allocation.get("release_time");
							String status = allocation.get("status");
							boolean isReleased = "Released".equalsIgnoreCase(status);
							boolean isEditing = editId != null && editId.equals(allocationId) && !isReleased;

							String allocationTimePretty = allocationTimeRaw;
							String releaseTimePretty = (releaseTimeRaw == null || releaseTimeRaw.trim().isEmpty()) ? "-" : releaseTimeRaw;

							try {
								allocationTimePretty = prettyFormat.format(dbFormat.parse(allocationTimeRaw));
							} catch (Exception e) {
							}
							try {
								if (releaseTimeRaw != null && !releaseTimeRaw.trim().isEmpty()) {
							releaseTimePretty = prettyFormat.format(dbFormat.parse(releaseTimeRaw));
								}
							} catch (Exception e) {
							}
						%>

						<%
						if (isEditing) {
						%>
						<tr>
							<form action="DockAllocationController" method="post">
								<input type="hidden" name="allocation_id"
									value="<%=allocationId%>"> <input type="hidden"
									name="search" value="<%=search%>"> <input type="hidden"
									name="statusFilter" value="<%=statusFilter%>">

								<td><%=allocationId%></td>
								<td><%=allocation.get("ship_id")%></td>

								<td><select name="dock_id"
									class="form-select form-select-sm" required>
										<%
										for (Map<String, String> dock : dockList) {
											String dockId = dock.get("dock_id");
											String dockName = dock.get("dock_name");
											String currentDockId = allocation.get("dock_id");
										%>
										<option value="<%=dockId%>"
											<%=dockId.equals(currentDockId) ? "selected" : ""%>>
											<%=dockName%> (ID:
											<%=dockId%>)
										</option>
										<%
										}
										%>
								</select></td>

								<td><%=allocationTimePretty%></td>
								<td><%=releaseTimePretty%></td>
								<td><span class="status-pill"><%=status%></span></td>

								<td>
									<div class="action-wrap">
										<button type="submit" name="update" value="update"
											class="btn btn-sm btn-purple">Update</button>
										<a
											href="DockAllocationController?search=<%=URLEncoder.encode(search, "UTF-8")%>&statusFilter=<%=URLEncoder.encode(statusFilter, "UTF-8")%>"
											class="btn btn-sm btn-outline-purple">Cancel</a>
									</div>
								</td>
							</form>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td><%=allocationId%></td>
							<td><%=allocation.get("ship_id")%></td>
							<td><%=allocation.get("dock_id")%></td>
							<td><%=allocationTimePretty%></td>
							<td><%=releaseTimePretty%></td>
							<td><span class="status-pill"><%=status%></span></td>
							<td>
								<div class="action-wrap">
									<%
									if (!isReleased) {
									%>
									<a
										href="DockAllocationController?editId=<%=allocationId%>&search=<%=URLEncoder.encode(search, "UTF-8")%>&statusFilter=<%=URLEncoder.encode(statusFilter, "UTF-8")%>"
										class="btn btn-sm btn-outline-purple">Edit</a>

									<form action="DockAllocationController" method="post"
										class="m-0">
										<input type="hidden" name="allocation_id"
											value="<%=allocationId%>"> <input type="hidden"
											name="search" value="<%=search%>"> <input
											type="hidden" name="statusFilter" value="<%=statusFilter%>">
										<button type="submit" name="release" value="release"
											class="btn btn-sm btn-soft-warning">Release</button>
									</form>
									<%
									}
									%>

									<form action="DockAllocationController" method="post"
										class="m-0"
										onsubmit="return confirm('Are you sure you want to delete this allocation?');">
										<input type="hidden" name="allocation_id"
											value="<%=allocationId%>"> <input type="hidden"
											name="search" value="<%=search%>"> <input
											type="hidden" name="statusFilter" value="<%=statusFilter%>">
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
					Showing <span><%=startIndex + 1%>&ndash;<%=endIndex%></span> of <span><%=totalAllocations%></span>
					records
				</div>

				<div class="pagination-controls">
					<a
						href="DockAllocationController?page=<%=currentPage - 1%>&<%=filterQuery%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>

					<%
					int startPage = Math.max(1, currentPage - 2);
					int endPage = Math.min(totalPages, currentPage + 2);

					if (startPage > 1) {
					%>
					<a href="DockAllocationController?page=1&<%=filterQuery%>"
						class="page-btn">1</a>
					<%
					if (startPage > 2) {
					%><span class="page-btn disabled">&hellip;</span>
					<%
					}
					}

					for (int p = startPage; p <= endPage; p++) {
					%>
					<a href="DockAllocationController?page=<%=p%>&<%=filterQuery%>"
						class="page-btn <%=p == currentPage ? "active" : ""%>"><%=p%></a>
					<%
					}

					if (endPage < totalPages) {
					if (endPage < totalPages - 1) {
					%><span class="page-btn disabled">&hellip;</span>
					<%
					}
					%>
					<a
						href="DockAllocationController?page=<%=totalPages%>&<%=filterQuery%>"
						class="page-btn"><%=totalPages%></a>
					<%
					}
					%>

					<a
						href="DockAllocationController?page=<%=currentPage + 1%>&<%=filterQuery%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>
				</div>
			</div>
			<%
			}
			%>
		</div>
	</main>

	<div class="modal fade" id="dockModal" tabindex="-1"
		aria-labelledby="dockModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content add-user-modal">
				<div class="modal-header add-user-header">
					<h5 class="modal-title" id="dockModalLabel">Create New
						Allocation</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>

				<div class="modal-body add-user-body">
					<form action="DockAllocationController" method="post"
						id="allocateForm">
						<div class="popup-field">
							<label class="popup-label">Ship</label> <select
								class="form-select popup-select" name="ship_id" required>
								<option value="">Select ship</option>
								<%
								for (Map<String, String> ship : shipList) {
								%>
								<option value="<%=ship.get("ship_id")%>">
									<%=ship.get("ship_name")%> (ID:
									<%=ship.get("ship_id")%>)
								</option>
								<%
								}
								%>
							</select>
						</div>

						<div class="popup-field">
							<label class="popup-label">Dock</label> <select
								class="form-select popup-select" name="dock_id" required>
								<option value="">Select dock</option>
								<%
								for (Map<String, String> dock : dockList) {
								%>
								<option value="<%=dock.get("dock_id")%>">
									<%=dock.get("dock_name")%> (ID:
									<%=dock.get("dock_id")%>)
								</option>
								<%
								}
								%>
							</select>
						</div>

						<div class="popup-field">
							<label class="popup-label">Allocation Time</label> <input
								type="datetime-local" class="form-control popup-input"
								name="allocation_time" required>
						</div>

						<div class="popup-field">
							<label class="popup-label">Release Time</label> <input
								type="datetime-local" class="form-control popup-input"
								name="release_time" required>
						</div>
					</form>
				</div>

				<div class="modal-footer add-user-footer">
					<button type="button" class="btn btn-popup-cancel"
						data-bs-dismiss="modal">Cancel</button>
					<button type="submit" form="allocateForm" name="allocate"
						value="allocate" class="btn btn-popup-submit">Confirm
						Allocation</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
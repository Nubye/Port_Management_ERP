<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.net.URLEncoder"%>
<%
request.setAttribute("activePage", "container-management");
request.setAttribute("topbarTitle", "Container Management");

String successMsg = (String) request.getAttribute("success");
if (successMsg == null)
	successMsg = (String) request.getAttribute("message");
String errorMsg = (String) request.getAttribute("error");

ArrayList<HashMap<String, String>> containerList = (ArrayList<HashMap<String, String>>) request
		.getAttribute("containerList");
ArrayList<HashMap<String, String>> shipList = (ArrayList<HashMap<String, String>>) request.getAttribute("shipList");

Object totalObj = request.getAttribute("totalContainers");
Object loadedObj = request.getAttribute("loadedCount");
Object transitObj = request.getAttribute("transitCount");

int totalContainers = totalObj != null ? (Integer) totalObj : 0;
int loadedCount = loadedObj != null ? (Integer) loadedObj : 0;
int transitCount = transitObj != null ? (Integer) transitObj : 0;

String filterSearch = (String) request.getAttribute("filterSearch");
String filterContainerType = (String) request.getAttribute("filterContainerType");
String filterStatus = (String) request.getAttribute("filterStatus");
String editId = (String) request.getAttribute("editId");

if (containerList == null)
	containerList = new ArrayList<>();
if (shipList == null)
	shipList = new ArrayList<>();
if (filterSearch == null)
	filterSearch = "";
if (filterContainerType == null)
	filterContainerType = "";
if (filterStatus == null)
	filterStatus = "";
if (editId == null)
	editId = "";

// --- Pagination ---
int pageSize = 10;
int totalItems = containerList.size();
int totalPages = (int) Math.ceil((double) totalItems / pageSize);

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
int endIndex = Math.min(startIndex + pageSize, totalItems);

// --- Filter query string for pagination & edit/cancel links ---
String filterQuery = "search=" + URLEncoder.encode(filterSearch.trim(), "UTF-8") + "&containerType="
		+ URLEncoder.encode(filterContainerType.trim(), "UTF-8") + "&status="
		+ URLEncoder.encode(filterStatus.trim(), "UTF-8");

// searchSuffix used by Edit and Cancel links
String searchSuffix = filterQuery.replaceAll("(?<=[?&])(search|containerType|status)=(?=&|$)", "").trim();
// Rebuild cleanly
StringBuilder sfBuilder = new StringBuilder();
if (!filterSearch.trim().isEmpty())
	sfBuilder.append("search=").append(URLEncoder.encode(filterSearch.trim(), "UTF-8"));
if (!filterContainerType.trim().isEmpty()) {
	if (sfBuilder.length() > 0)
		sfBuilder.append("&");
	sfBuilder.append("containerType=").append(URLEncoder.encode(filterContainerType.trim(), "UTF-8"));
}
if (!filterStatus.trim().isEmpty()) {
	if (sfBuilder.length() > 0)
		sfBuilder.append("&");
	sfBuilder.append("status=").append(URLEncoder.encode(filterStatus.trim(), "UTF-8"));
}
String searchSuffixClean = sfBuilder.length() > 0 ? "?" + sfBuilder.toString() : "";

boolean hasFilter = !filterSearch.trim().isEmpty() || !filterContainerType.trim().isEmpty()
		|| !filterStatus.trim().isEmpty();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Container Management | Port Management ERP</title>
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

.btn-purple, .btn-outline-purple, .btn-soft-danger, .btn-soft-warning,
	.btn-search, .btn-add {
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

.btn-outline-purple {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
}

.btn-soft-danger {
	background: rgba(239, 68, 68, 0.14);
	border: 1px solid rgba(252, 165, 165, 0.28);
	color: #fecaca;
}

.btn-soft-warning {
	background: rgba(245, 158, 11, 0.14);
	border: 1px solid rgba(253, 230, 138, 0.28);
	color: #fde68a;
}

.btn-search {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
	min-width: 96px;
	height: 42px;
}

.btn-add {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
	min-width: 110px;
	height: 42px;
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

.loaded {
	background: rgba(34, 197, 94, 0.12);
	color: #86efac;
	border-color: rgba(34, 197, 94, 0.25);
}

.empty {
	background: rgba(156, 163, 175, 0.12);
	color: #d1d5db;
	border-color: rgba(156, 163, 175, 0.24);
}

.transit {
	background: rgba(245, 158, 11, 0.12);
	color: #fcd34d;
	border-color: rgba(245, 158, 11, 0.26);
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

/* Modal */
.modal-overlay {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.72);
	z-index: 1050;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.modal-overlay.show {
	display: flex;
}

.dock-modal {
	width: 100%;
	max-width: 920px;
	background: #171722;
	border: 1px solid rgba(192, 132, 252, 0.18);
	border-radius: 22px;
	box-shadow: 0 30px 80px rgba(0, 0, 0, 0.5);
	overflow: hidden;
}

.dock-modal-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 22px 26px;
	border-bottom: 1px solid rgba(192, 132, 252, 0.10);
}

.dock-modal-title {
	font-size: 1.7rem;
	font-weight: 800;
	color: #ffffff;
	margin: 0;
}

.dock-modal-close {
	background: transparent;
	border: none;
	color: #ffffff;
	font-size: 2rem;
	line-height: 1;
	padding: 0;
}

.dock-modal-body {
	padding: 26px;
}

.dock-modal-footer {
	padding: 22px 26px;
	border-top: 1px solid rgba(192, 132, 252, 0.10);
	display: flex;
	justify-content: flex-end;
	gap: 14px;
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
			<h2 class="page-title">Container Management</h2>
			<p class="page-subtitle">Create, update, search, and remove
				container records from a single page.</p>
		</div>

		<%
		if (successMsg != null && !successMsg.isEmpty()) {
		%>
		<div class="alert alert-success"><%=successMsg%></div>
		<%
		}
		%>
		<%
		if (errorMsg != null && !errorMsg.isEmpty()) {
		%>
		<div class="alert alert-danger"><%=errorMsg%></div>
		<%
		}
		%>

		<div class="row g-3 mb-4">
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Total Containers</div>
					<div class="stat-value"><%=totalContainers%></div>
				</div>
			</div>
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">Loaded Containers</div>
					<div class="stat-value"><%=loadedCount%></div>
				</div>
			</div>
			<div class="col-lg-4 col-md-4">
				<div class="dash-card stat-card stat-box">
					<div class="stat-label">In Transit</div>
					<div class="stat-value"><%=transitCount%></div>
				</div>
			</div>
		</div>

		<div class="table-shell">
			<div class="p-4 pb-0">
				<div
					class="d-flex justify-content-between align-items-center flex-wrap gap-2">
					<div>
						<div class="section-title">Container Records</div>
						<div class="section-subtitle">Search by Container ID or Ship
							Name, type, or status, then edit one row inline.</div>
					</div>
					<button type="button" class="btn-add"
						onclick="openContainerModal()">Add</button>
				</div>

				<form action="ContainerManagementController" method="get"
					class="search-form">
					<div class="search-input-wrap">
						<input type="text" name="search" class="form-control search-input"
							placeholder="Search by Container ID or Ship Name"
							value="<%=filterSearch%>">
					</div>

					<div class="search-input-wrap">
						<select name="containerType" class="form-select search-input">
							<option value="">All Types</option>
							<option value="Dry Storage"
								<%="Dry Storage".equalsIgnoreCase(filterContainerType) ? "selected" : ""%>>Dry
								Storage</option>
							<option value="Open Top"
								<%="Open Top".equalsIgnoreCase(filterContainerType) ? "selected" : ""%>>Open
								Top</option>
							<option value="Flat Rack"
								<%="Flat Rack".equalsIgnoreCase(filterContainerType) ? "selected" : ""%>>Flat
								Rack</option>
							<option value="Refrigerated"
								<%="Refrigerated".equalsIgnoreCase(filterContainerType) ? "selected" : ""%>>Refrigerated</option>
						</select>
					</div>

					<div class="search-input-wrap">
						<select name="status" class="form-select search-input">
							<option value="">All Status</option>
							<option value="Loaded"
								<%="Loaded".equalsIgnoreCase(filterStatus) ? "selected" : ""%>>Loaded</option>
							<option value="Empty"
								<%="Empty".equalsIgnoreCase(filterStatus) ? "selected" : ""%>>Empty</option>
							<option value="In Transit"
								<%="In Transit".equalsIgnoreCase(filterStatus) ? "selected" : ""%>>In
								Transit</option>
						</select>
					</div>

					<button type="submit" class="btn btn-search">Search</button>

					<%
					if (hasFilter) {
					%>
					<a href="ContainerManagementController" class="btn btn-soft-danger">Clear</a>
					<%
					}
					%>
				</form>
			</div>

			<%
			if (containerList.isEmpty()) {
			%>
			<div class="empty-state">
				<%
				if (hasFilter) {
				%>
				No containers found for the selected filters.
				<%
				} else {
				%>
				No containers found.
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
							<th>ID</th>
							<th>Type</th>
							<th>Status</th>
							<th>Ship</th>
							<th>Cargo Description</th>
							<th>Weight</th>
							<th>Cargo Status</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (int i = startIndex; i < endIndex; i++) {
							HashMap<String, String> c = containerList.get(i);
							String containerId = c.get("container_id") != null ? c.get("container_id") : "";
							String currentType = c.get("container_type") != null ? c.get("container_type") : "";
							String currentStatus = c.get("status") != null ? c.get("status") : "";
							String currentShipId = c.get("ship_id") != null ? c.get("ship_id") : "";
							String currentShipName = c.get("ship_name") != null ? c.get("ship_name") : "-";
							String currentCargoDesc = c.get("cargo_description") != null ? c.get("cargo_description") : "-";
							String currentWeight = c.get("weight") != null ? c.get("weight") : "-";
							String currentCargoStatus = c.get("cargo_status") != null ? c.get("cargo_status") : "-";
							String statusClass = c.get("status_class") != null ? c.get("status_class") : "empty";
							boolean isEditing = containerId.equals(editId);
						%>

						<%
						if (!isEditing) {
						%>
						<tr>
							<td><%=containerId%></td>
							<td><%=currentType%></td>
							<td><span class="status-pill <%=statusClass%>"><%=currentStatus%></span></td>
							<td><%=currentShipName%></td>
							<td><%=currentCargoDesc%></td>
							<td><%=currentWeight%></td>
							<td><%=currentCargoStatus%></td>
							<td>
								<div class="action-wrap">
									<a
										href="ContainerManagementController?<%=filterQuery%>&page=<%=currentPage%>&editId=<%=containerId%>"
										class="btn btn-outline-purple">Edit</a>

									<form action="ContainerManagementController" method="post">
										<input type="hidden" name="action" value="delete"> <input
											type="hidden" name="containerId" value="<%=containerId%>">
										<input type="hidden" name="search_query"
											value="<%=filterSearch%>"> <input type="hidden"
											name="container_type_search" value="<%=filterContainerType%>">
										<input type="hidden" name="status_search"
											value="<%=filterStatus%>"> <input type="hidden"
											name="page" value="<%=currentPage%>">
										<button type="submit" class="btn btn-soft-danger"
											onclick="return confirm('Delete Container #<%=containerId%>?');">Delete</button>
									</form>
								</div>
							</td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<form action="ContainerManagementController" method="post">
								<input type="hidden" name="action" value="update"> <input
									type="hidden" name="containerId" value="<%=containerId%>">
								<input type="hidden" name="search_query"
									value="<%=filterSearch%>"> <input type="hidden"
									name="container_type_search" value="<%=filterContainerType%>">
								<input type="hidden" name="status_search"
									value="<%=filterStatus%>"> <input type="hidden"
									name="page" value="<%=currentPage%>">

								<td><%=containerId%></td>

								<td><select name="containerType"
									class="form-select form-select-sm" required>
										<option value="Dry Storage"
											<%="Dry Storage".equalsIgnoreCase(currentType) ? "selected" : ""%>>Dry
											Storage</option>
										<option value="Open Top"
											<%="Open Top".equalsIgnoreCase(currentType) ? "selected" : ""%>>Open
											Top</option>
										<option value="Flat Rack"
											<%="Flat Rack".equalsIgnoreCase(currentType) ? "selected" : ""%>>Flat
											Rack</option>
										<option value="Refrigerated"
											<%="Refrigerated".equalsIgnoreCase(currentType) ? "selected" : ""%>>Refrigerated</option>
								</select></td>

								<td><select name="status"
									class="form-select form-select-sm" required>
										<option value="Loaded"
											<%="Loaded".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>Loaded</option>
										<option value="Empty"
											<%="Empty".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>Empty</option>
										<option value="In Transit"
											<%="In Transit".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>In
											Transit</option>
								</select></td>

								<td><select name="shipId"
									class="form-select form-select-sm" required>
										<%
										for (HashMap<String, String> ship : shipList) {
											String shipId = ship.get("ship_id") != null ? ship.get("ship_id") : "";
											String shipName = ship.get("ship_name") != null ? ship.get("ship_name") : "";
										%>
										<option value="<%=shipId%>"
											<%=shipId.equals(currentShipId) ? "selected" : ""%>>
											<%=shipName%>
										</option>
										<%
										}
										%>
								</select></td>

								<td><%=currentCargoDesc%></td>
								<td><%=currentWeight%></td>
								<td><%=currentCargoStatus%></td>

								<td>
									<div class="action-wrap">
										<button type="submit" class="btn btn-purple">Update</button>
										<a
											href="ContainerManagementController<%=searchSuffixClean%>&page=<%=currentPage%>"
											class="btn btn-outline-purple">Cancel</a>
									</div>
								</td>
							</form>
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
					Showing <span><%=totalItems == 0 ? 0 : startIndex + 1%>&ndash;<%=endIndex%></span>
					of <span><%=totalItems%></span> containers
				</div>

				<div class="pagination-controls">

					<%-- Prev --%>
					<a
						href="ContainerManagementController?<%=filterQuery%>&page=<%=currentPage - 1%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>

					<%
					int startPage = Math.max(1, currentPage - 2);
					int endPage = Math.min(totalPages, currentPage + 2);

					if (startPage > 1) {
					%>
					<a href="ContainerManagementController?<%=filterQuery%>&page=1"
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
					<a
						href="ContainerManagementController?<%=filterQuery%>&page=<%=p%>"
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
						href="ContainerManagementController?<%=filterQuery%>&page=<%=totalPages%>"
						class="page-btn"><%=totalPages%></a>
					<%
					}
					%>

					<%-- Next --%>
					<a
						href="ContainerManagementController?<%=filterQuery%>&page=<%=currentPage + 1%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>

				</div>
			</div>

			<%
			}
			%>
		</div>
	</main>

	<!-- ADD CONTAINER MODAL -->
	<div class="modal-overlay" id="containerModal">
		<div class="dock-modal">
			<div class="dock-modal-header">
				<h3 class="dock-modal-title">Create New Container</h3>
				<button type="button" class="dock-modal-close"
					onclick="closeContainerModal()">&times;</button>
			</div>

			<div class="dock-modal-body">
				<form action="ContainerManagementController" method="post">
					<input type="hidden" name="action" value="add">

					<div class="row g-3">
						<div class="col-lg-4 col-md-6">
							<label class="form-label">Container Type</label> <select
								class="form-select" name="containerType" required>
								<option value="">Select type</option>
								<option value="Dry Storage">Dry Storage</option>
								<option value="Open Top">Open Top</option>
								<option value="Flat Rack">Flat Rack</option>
								<option value="Refrigerated">Refrigerated</option>
							</select>
						</div>

						<div class="col-lg-4 col-md-6">
							<label class="form-label">Status</label> <select
								class="form-select" name="status" required>
								<option value="">Select status</option>
								<option value="Loaded">Loaded</option>
								<option value="Empty">Empty</option>
								<option value="In Transit">In Transit</option>
							</select>
						</div>

						<div class="col-lg-4 col-md-12">
							<label class="form-label">Assign Ship</label> <select
								class="form-select" name="shipId" required>
								<option value="">Select ship</option>
								<%
								for (HashMap<String, String> ship : shipList) {
								%>
								<option value="<%=ship.get("ship_id")%>"><%=ship.get("ship_name")%></option>
								<%
								}
								%>
							</select>
						</div>
					</div>

					<div class="dock-modal-footer">
						<button type="button" class="btn btn-outline-purple"
							onclick="closeContainerModal()">Cancel</button>
						<button type="submit" class="btn btn-purple">Confirm
							Container</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script>
		function openContainerModal() {
			document.getElementById("containerModal").classList.add("show");
		}
		function closeContainerModal() {
			document.getElementById("containerModal").classList.remove("show");
		}

		document.addEventListener("keydown", function(e) {
			if (e.key === "Escape")
				closeContainerModal();
		});

		document.getElementById("containerModal").addEventListener("click",
				function(e) {
					if (e.target === this)
						closeContainerModal();
				});
	</script>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
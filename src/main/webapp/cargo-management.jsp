<%@ page import="java.util.*" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder"%>

<%
request.setAttribute("activePage", "cargo-management");
request.setAttribute("topbarTitle", "Cargo Management");

List<Map<String, String>> cargoList = (List<Map<String, String>>) request.getAttribute("cargoList");
List<Map<String, String>> containerList = (List<Map<String, String>>) request.getAttribute("containerList");

String success = (String) request.getAttribute("success");
String error = (String) request.getAttribute("error");
String searchKeyword = (String) request.getAttribute("searchKeyword");
String selectedStatus = (String) request.getAttribute("selectedStatus");
String editId = request.getParameter("editId");

if (cargoList == null)
	cargoList = new ArrayList<>();
if (containerList == null)
	containerList = new ArrayList<>();
if (searchKeyword == null)
	searchKeyword = "";
if (selectedStatus == null)
	selectedStatus = "";
if (editId == null)
	editId = "";

int totalCargo = cargoList.size();
int loadedCount = 0;
int unloadedCount = 0;
int transitCount = 0;

for (Map<String, String> cargo : cargoList) {
	String status = cargo.get("cargo_status");
	if ("Loaded".equalsIgnoreCase(status))
		loadedCount++;
	else if ("Unloaded".equalsIgnoreCase(status))
		unloadedCount++;
	else if ("In Transit".equalsIgnoreCase(status))
		transitCount++;
}

int pageSize = 10;
int totalPages = (int) Math.ceil((double) totalCargo / pageSize);

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
int endIndex = Math.min(startIndex + pageSize, totalCargo);

StringBuilder searchSuffixBuilder = new StringBuilder();
boolean hasSearch = false;

if (!searchKeyword.trim().isEmpty()) {
	searchSuffixBuilder.append(hasSearch ? "&" : "?").append("keyword=")
	.append(URLEncoder.encode(searchKeyword.trim(), "UTF-8"));
	hasSearch = true;
}
if (!selectedStatus.trim().isEmpty()) {
	searchSuffixBuilder.append(hasSearch ? "&" : "?").append("status=")
	.append(URLEncoder.encode(selectedStatus.trim(), "UTF-8"));
	hasSearch = true;
}

String searchSuffix = searchSuffixBuilder.toString();

String filterQuery = "keyword=" + URLEncoder.encode(searchKeyword.trim(), "UTF-8") + "&status="
		+ URLEncoder.encode(selectedStatus.trim(), "UTF-8");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Cargo Management | Port Management ERP</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">

<style>
:root {
	--bg-main: #0a0a0f;
	--bg-card: #1e1e29;
	--purple-main: #7a22d8;
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

.form-select option {
	background: #1b1b2b;
	color: #ffffff;
}

.btn-purple, .btn-outline-purple, .btn-soft-danger, .btn-search,
	.btn-add {
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
	box-shadow: var(--shadow-main);
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

.status-pill {
	display: inline-block;
	padding: 6px 12px;
	border-radius: 999px;
	font-size: 0.78rem;
	font-weight: 700;
	border: 1px solid transparent;
}

.status-loaded {
	background: rgba(34, 197, 94, 0.12);
	color: #86efac;
	border-color: rgba(34, 197, 94, 0.25);
}

.status-unloaded {
	background: rgba(239, 68, 68, 0.12);
	color: #fca5a5;
	border-color: rgba(239, 68, 68, 0.25);
}

.status-transit {
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

.editing-row {
	background: rgba(168, 85, 247, 0.08);
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
			<h2 class="page-title">Cargo Management</h2>
			<p class="page-subtitle">Add cargo to containers, update cargo
				details, and manage cargo operations.</p>
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
					<div class="stat-label">Total Cargo</div>
					<div class="stat-value"><%=totalCargo%></div>
				</div>
			</div>
			<div class="col-lg-3 col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Loaded Cargo</div>
					<div class="stat-value"><%=loadedCount%></div>
				</div>
			</div>
			<div class="col-lg-3 col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">In Transit</div>
					<div class="stat-value"><%=transitCount%></div>
				</div>
			</div>
			<div class="col-lg-3 col-md-6">
				<div class="dash-card stat-card">
					<div class="stat-label">Unloaded Cargo</div>
					<div class="stat-value"><%=unloadedCount%></div>
				</div>
			</div>
		</div>

		<div class="table-shell mb-4">
			<div class="p-4 pb-0">
				<div
					class="d-flex justify-content-between align-items-center flex-wrap gap-2">
					<div>
						<div class="section-title">Cargo Records</div>
						<div class="section-subtitle">Search by cargo ID or
							description, filter by status, and manage cargo entries.</div>
					</div>
					<button type="button" class="btn-add" data-bs-toggle="modal"
						data-bs-target="#addCargoModal">Add Cargo</button>
				</div>

				<form action="CargoManagementController" method="get"
					class="search-form">
					<div class="search-input-wrap">
						<input type="text" name="keyword"
							class="form-control search-input"
							placeholder="Search by Cargo ID or Description"
							value="<%=searchKeyword%>">
					</div>

					<div class="search-input-wrap">
						<select name="status" class="form-select search-input">
							<option value="">All Status</option>
							<option value="Loaded"
								<%="Loaded".equalsIgnoreCase(selectedStatus) ? "selected" : ""%>>Loaded</option>
							<option value="In Transit"
								<%="In Transit".equalsIgnoreCase(selectedStatus) ? "selected" : ""%>>In
								Transit</option>
							<option value="Unloaded"
								<%="Unloaded".equalsIgnoreCase(selectedStatus) ? "selected" : ""%>>Unloaded</option>
						</select>
					</div>

					<button type="submit" class="btn btn-search">Search</button>

					<%
					if (!searchKeyword.trim().isEmpty() || !selectedStatus.trim().isEmpty()) {
					%>
					<a href="CargoManagementController" class="btn btn-soft-danger">Clear</a>
					<%
					}
					%>
				</form>
			</div>

			<%
			if (cargoList.isEmpty()) {
			%>
			<div class="empty-state">No cargo records found.</div>
			<%
			} else {
			%>
			<div class="table-responsive">
				<table class="table table-dark-custom align-middle">
					<thead>
						<tr>
							<th>Cargo ID</th>
							<th>Description</th>
							<th>Weight</th>
							<th>Status</th>
							<th>Container</th>
							<th>Ship</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (int i = startIndex; i < endIndex; i++) {
							Map<String, String> cargo = cargoList.get(i);
							String cargoId = cargo.get("cargo_id");
							boolean isEditing = editId != null && editId.equals(cargoId);
							String currentStatus = cargo.get("cargo_status");
							String statusClass = "status-transit";
							if ("Loaded".equalsIgnoreCase(currentStatus))
								statusClass = "status-loaded";
							else if ("Unloaded".equalsIgnoreCase(currentStatus))
								statusClass = "status-unloaded";
							String weightValue = cargo.get("weight");
						%>

						<%
						if (isEditing) {
						%>
						<tr class="editing-row">
							<form action="CargoManagementController" method="post">
								<input type="hidden" name="action" value="update"> <input
									type="hidden" name="cargo_id" value="<%=cargoId%>"> <input
									type="hidden" name="keyword_search" value="<%=searchKeyword%>">
								<input type="hidden" name="status_search"
									value="<%=selectedStatus%>">

								<td><%=cargoId%></td>
								<td><input type="text" name="description"
									class="form-control form-control-sm"
									value="<%=cargo.get("description")%>" required></td>
								<td><input type="number" step="0.01" min="0.01"
									name="weight" class="form-control form-control-sm"
									value="<%=weightValue%>" required></td>
								<td><select name="status"
									class="form-select form-select-sm" required>
										<option value="Loaded"
											<%="Loaded".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>Loaded</option>
										<option value="Unloaded"
											<%="Unloaded".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>Unloaded</option>
										<option value="In Transit"
											<%="In Transit".equalsIgnoreCase(currentStatus) ? "selected" : ""%>>In
											Transit</option>
								</select></td>
								<td><%=cargo.get("container_type")%> (#<%=cargo.get("container_id")%>)</td>
								<td><%=cargo.get("ship_name")%></td>
								<td>
									<div class="action-wrap">
										<button type="submit" class="btn btn-purple">Update</button>
										<a href="CargoManagementController<%=searchSuffix%>"
											class="btn btn-outline-purple">Cancel</a>
									</div>
								</td>
							</form>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td><%=cargoId%></td>
							<td><%=cargo.get("description")%></td>
							<td><%=weightValue%></td>
							<td><span class="status-pill <%=statusClass%>"><%=currentStatus%></span></td>
							<td><%=cargo.get("container_type")%> (#<%=cargo.get("container_id")%>)</td>
							<td><%=cargo.get("ship_name")%></td>
							<td>
								<div class="action-wrap">
									<a
										href="CargoManagementController<%=searchSuffix%><%=searchSuffix.isEmpty() ? "?" : "&"%>editId=<%=cargoId%>"
										class="btn btn-outline-purple">Edit</a>

									<form action="CargoManagementController" method="post"
										class="m-0"
										onsubmit="return confirm('Are you sure you want to delete this cargo record?');">
										<input type="hidden" name="action" value="delete"> <input
											type="hidden" name="cargo_id" value="<%=cargoId%>"> <input
											type="hidden" name="keyword_search"
											value="<%=searchKeyword%>"> <input type="hidden"
											name="status_search" value="<%=selectedStatus%>">
										<button type="submit" class="btn btn-soft-danger">Delete</button>
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

			<div class="pagination-wrap">
				<div class="pagination-info">
					Showing <span><%=startIndex + 1%>&ndash;<%=endIndex%></span> of <span><%=totalCargo%></span>
					records
				</div>

				<div class="pagination-controls">

					<a
						href="CargoManagementController?page=<%=currentPage - 1%>&<%=filterQuery%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>

					<%
					int startPage = Math.max(1, currentPage - 2);
					int endPage = Math.min(totalPages, currentPage + 2);

					if (startPage > 1) {
					%>
					<a href="CargoManagementController?page=1&<%=filterQuery%>"
						class="page-btn">1</a>
					<%
					if (startPage > 2) {
					%><span class="page-btn disabled">&hellip;</span>
					<%
					}
					%>
					<%
					}

					for (int p = startPage; p <= endPage; p++) {
					%>
					<a href="CargoManagementController?page=<%=p%>&<%=filterQuery%>"
						class="page-btn <%=p == currentPage ? "active" : ""%>"><%=p%></a>
					<%
					}

					if (endPage < totalPages) {
					if (endPage < totalPages - 1) {
					%><span
						class="page-btn disabled">&hellip;</span>
					<%
					}
					%>
					<a
						href="CargoManagementController?page=<%=totalPages%>&<%=filterQuery%>"
						class="page-btn"><%=totalPages%></a>
					<%
					}
					%>

					<a
						href="CargoManagementController?page=<%=currentPage + 1%>&<%=filterQuery%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>

				</div>
			</div>
			<%
			}
			%>
		</div>
	</main>

	<div class="modal fade" id="addCargoModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<form action="CargoManagementController" method="post">
					<input type="hidden" name="action" value="add">

					<div class="modal-header">
						<h5 class="modal-title">Create New Cargo</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal"></button>
					</div>

					<div class="modal-body">
						<div class="mb-3">
							<label class="form-label">Container</label> <select
								class="form-select" name="container_id" required>
								<option value="">Select container</option>
								<%
								for (Map<String, String> container : containerList) {
								%>
								<option value="<%=container.get("container_id")%>">
									<%=container.get("container_type")%> (ID:
									<%=container.get("container_id")%>)
								</option>
								<%
								}
								%>
							</select>
						</div>

						<div class="mb-3">
							<label class="form-label">Description</label> <input type="text"
								name="description" class="form-control" maxlength="200" required
								placeholder="Cargo description">
						</div>

						<div class="mb-3">
							<label class="form-label">Weight (tons)</label> <input
								type="number" step="0.01" min="0.01" name="weight"
								class="form-control" required placeholder="0.00">
						</div>

						<div class="mb-0">
							<label class="form-label">Status</label> <select
								class="form-select" name="status" required>
								<option value="">Select status</option>
								<option value="Loaded">Loaded</option>
								<option value="Unloaded">Unloaded</option>
								<option value="In Transit">In Transit</option>
							</select>
						</div>
					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-outline-purple"
							data-bs-dismiss="modal">Cancel</button>
						<button type="submit" class="btn btn-purple">Confirm
							Cargo</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
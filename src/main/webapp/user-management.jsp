<%@ page import="java.util.*" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder"%>

<%
Integer roleId = (Integer) request.getAttribute("roleId");
String roleName = (String) request.getAttribute("roleName");
if (roleName == null)
	roleName = "User";
String activePage = (String) request.getAttribute("activePage");

List<Map<String, String>> userList = (List<Map<String, String>>) request.getAttribute("userList");
List<Map<String, String>> roleList = (List<Map<String, String>>) request.getAttribute("roleList");

String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");
String editId = request.getParameter("editId");

String search = (String) request.getAttribute("search");
if (search == null)
	search = request.getParameter("search");
if (search == null)
	search = "";

String roleFilter = (String) request.getAttribute("roleFilter");
if (roleFilter == null)
	roleFilter = request.getParameter("role_id");
if (roleFilter == null)
	roleFilter = "";

String statusFilter = (String) request.getAttribute("statusFilter");
if (statusFilter == null)
	statusFilter = request.getParameter("status");
if (statusFilter == null)
	statusFilter = "";

if (userList == null)
	userList = new ArrayList<>();
if (roleList == null)
	roleList = new ArrayList<>();

int totalUsers = userList.size();
int activeUsers = 0;
int deactivatedUsers = 0;

for (Map<String, String> user : userList) {
	String status = user.get("status");
	if (status == null || status.trim().isEmpty())
		status = "Active";
	if ("Active".equalsIgnoreCase(status))
		activeUsers++;
	else
		deactivatedUsers++;
}

// --- Pagination ---
int pageSize = 10;
int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

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
int endIndex = Math.min(startIndex + pageSize, totalUsers);

// --- Preserved query string for edit/cancel links ---
StringBuilder preservedQuery = new StringBuilder();
try {
	if (!search.trim().isEmpty()) {
		preservedQuery.append("search=").append(URLEncoder.encode(search.trim(), "UTF-8"));
	}
	if (!roleFilter.trim().isEmpty()) {
		if (preservedQuery.length() > 0)
	preservedQuery.append("&");
		preservedQuery.append("role_id=").append(URLEncoder.encode(roleFilter.trim(), "UTF-8"));
	}
	if (!statusFilter.trim().isEmpty()) {
		if (preservedQuery.length() > 0)
	preservedQuery.append("&");
		preservedQuery.append("status=").append(URLEncoder.encode(statusFilter.trim(), "UTF-8"));
	}
} catch (Exception e) {
}
String preservedQueryString = preservedQuery.toString();

// --- Filter query string for pagination links ---
String filterQuery = "search=" + URLEncoder.encode(search.trim(), "UTF-8") + "&role_id="
		+ URLEncoder.encode(roleFilter.trim(), "UTF-8") + "&status=" + URLEncoder.encode(statusFilter.trim(), "UTF-8");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>User Management | Port Management ERP</title>
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

.form-control::placeholder, .form-select option {
	color: #867a9c;
}

.btn-dark-purple {
	height: 52px;
	width: 100%;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	background: linear-gradient(135deg, var(--purple-deep) 0%,
		var(--purple-dark) 100%);
	border: 1px solid rgba(192, 132, 252, 0.18);
	color: #ffffff;
	font-weight: 700;
	border-radius: 14px;
	box-shadow: 0 8px 18px rgba(74, 18, 128, 0.18);
	padding: 0 16px;
}

.btn-dark-purple:hover {
	background: linear-gradient(135deg, #3b125f 0%, #4d177f 100%);
	color: #ffffff;
}

.btn-purple, .btn-outline-purple, .btn-soft-danger, .btn-soft-success,
	.btn-search, .btn-toggle-create {
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

.btn-soft-success {
	background: var(--green-bg);
	border: 1px solid var(--green-border);
	color: var(--green-soft);
}

.btn-soft-success:hover {
	background: rgba(34, 197, 94, 0.20);
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

.btn-toggle-create {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
	height: 42px;
	min-width: 120px;
}

.btn-toggle-create:hover {
	background: linear-gradient(135deg, #9b4df1 0%, #b86cff 100%);
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
	min-width: 260px;
}

.filter-wrap {
	min-width: 180px;
}

.search-input, .search-select {
	height: 42px;
	background-color: #12121a !important;
	border: 1px solid rgba(192, 132, 252, 0.18) !important;
	color: #f8f5ff !important;
	border-radius: 12px;
	padding: 0 14px;
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

.status-active {
	background: var(--green-bg);
	color: var(--green-soft);
	border: 1px solid var(--green-border);
}

.status-inactive {
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
	margin-bottom: 24px;
}

.stats-grid {
	display: grid;
	grid-template-columns: repeat(3, minmax(0, 1fr));
	gap: 18px;
	margin-bottom: 24px;
}

.stat-label {
	color: var(--text-muted);
	font-size: 0.92rem;
	font-weight: 600;
	margin-bottom: 10px;
}

.stat-value {
	font-size: 2rem;
	font-weight: 800;
	color: #ffffff;
	line-height: 1;
}

.stat-foot {
	margin-top: 10px;
	font-size: 0.85rem;
	color: var(--purple-soft);
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

.stat-card {
	position: relative;
	overflow: hidden;
	height: 100%;
	background: linear-gradient(180deg, rgba(30, 30, 41, 0.98) 0%,
		rgba(20, 20, 30, 0.98) 100%);
	border: 1px solid var(--border-soft);
	border-radius: 20px;
	box-shadow: var(--shadow-main);
	padding: 22px;
}

.stat-card::before {
	content: "";
	position: absolute;
	inset: 0 0 auto 0;
	height: 3px;
	background: linear-gradient(90deg, var(--purple-deep),
		var(--purple-bright));
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
	.search-input-wrap, .filter-wrap {
		min-width: 100%;
	}
	.action-wrap {
		flex-wrap: wrap;
	}
	.stats-grid {
		grid-template-columns: 1fr;
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

@media ( min-width : 992px) and (max-width: 1199.98px) {
	.stats-grid {
		grid-template-columns: repeat(3, 1fr);
	}
}
</style>
</head>
<body>

	<jsp:include page="includes/topbar.jsp" />
	<jsp:include page="includes/sidebar.jsp" />

	<main class="main-content">
		<div class="content-head">
			<h2 class="page-title">User Management</h2>
			<p class="page-subtitle">Add new users, assign roles, search
				accounts, and manage account activation status.</p>
		</div>

		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-label">Total Users</div>
				<div class="stat-value"><%=totalUsers%></div>
			</div>
			<div class="stat-card">
				<div class="stat-label">Activated Users</div>
				<div class="stat-value"><%=activeUsers%></div>
			</div>
			<div class="stat-card">
				<div class="stat-label">Deactivated Users</div>
				<div class="stat-value"><%=deactivatedUsers%></div>
			</div>
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

		<div class="table-shell">
			<div class="p-4">
				<div
					class="d-flex flex-wrap justify-content-between align-items-start gap-3">
					<div>
						<div class="section-title">Registered Users</div>
						<div class="section-subtitle">Search only by user id, name,
							or email. Use filters for role and status.</div>
					</div>
					<button type="button" class="btn btn-toggle-create"
						data-bs-toggle="modal" data-bs-target="#addUserModal">Add
						User</button>
				</div>

				<form action="UserManagementController" method="get"
					class="search-form">
					<div class="search-input-wrap">
						<input type="text" name="search" class="form-control search-input"
							placeholder="Search by User ID, Name, or Email"
							value="<%=search%>">
					</div>

					<div class="filter-wrap">
						<select name="role_id" class="form-select search-select">
							<option value=""
								<%=roleFilter.trim().isEmpty() ? "selected" : ""%>>All
								Roles</option>
							<%
							for (Map<String, String> role : roleList) {
								String rId = role.get("role_id");
								String rName = role.get("role_name");
							%>
							<option value="<%=rId%>"
								<%=rId != null && rId.equals(roleFilter) ? "selected" : ""%>>
								<%=rName%>
							</option>
							<%
							}
							%>
						</select>
					</div>

					<div class="filter-wrap">
						<select name="status" class="form-select search-select">
							<option value=""
								<%=statusFilter.trim().isEmpty() ? "selected" : ""%>>All
								Statuses</option>
							<option value="Active"
								<%="Active".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Active</option>
							<option value="Inactive"
								<%="Inactive".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Inactive</option>
						</select>
					</div>

					<button type="submit" class="btn btn-search">Search</button>

					<%
					if (!search.trim().isEmpty() || !roleFilter.trim().isEmpty() || !statusFilter.trim().isEmpty()) {
					%>
					<a href="UserManagementController" class="btn btn-soft-danger">Clear</a>
					<%
					}
					%>
				</form>
			</div>

			<%
			if (userList.isEmpty()) {
			%>
			<div class="empty-state">
				<%
				if (!search.trim().isEmpty() || !roleFilter.trim().isEmpty() || !statusFilter.trim().isEmpty()) {
				%>
				No users found for the selected filters.
				<%
				} else {
				%>
				No registered users found.
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
							<th>User ID</th>
							<th>Name</th>
							<th>Email</th>
							<th>Role</th>
							<th>Status</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
						for (int i = startIndex; i < endIndex; i++) {
							Map<String, String> user = userList.get(i);
							String userId = user.get("user_id");
							boolean isEditing = editId != null && editId.equals(userId);
							String status = user.get("status");
							if (status == null || status.trim().isEmpty())
								status = "Active";
							boolean isActive = "Active".equalsIgnoreCase(status);
						%>

						<%
						if (isEditing) {
						%>
						<tr>
							<td><%=userId%></td>
							<td><input type="text" form="editForm_<%=userId%>"
								name="name" class="form-control" value="<%=user.get("name")%>"
								required></td>
							<td><input type="email" form="editForm_<%=userId%>"
								name="email" class="form-control" value="<%=user.get("email")%>"
								required></td>
							<td><select form="editForm_<%=userId%>" name="role_id"
								class="form-select" required>
									<%
									for (Map<String, String> role : roleList) {
										String rId = role.get("role_id");
									%>
									<option value="<%=rId%>"
										<%=rId != null && rId.equals(user.get("role_id")) ? "selected" : ""%>>
										<%=role.get("role_name")%>
									</option>
									<%
									}
									%>
							</select></td>
							<td><span
								class="status-pill <%=isActive ? "status-active" : "status-inactive"%>">
									<%=status%>
							</span></td>
							<td>
								<div class="action-wrap">
									<form id="editForm_<%=userId%>"
										action="UserManagementController" method="post">
										<input type="hidden" name="user_id" value="<%=userId%>">
										<button type="submit" name="update" value="update"
											class="btn btn-sm btn-purple">Update</button>
									</form>
									<a
										href="UserManagementController<%=preservedQueryString.isEmpty() ? "" : "?" + preservedQueryString%>"
										class="btn btn-sm btn-outline-purple">Cancel</a>
								</div>
							</td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td><%=userId%></td>
							<td><%=user.get("name")%></td>
							<td><%=user.get("email")%></td>
							<td><%=user.get("role_name")%></td>
							<td><span
								class="status-pill <%=isActive ? "status-active" : "status-inactive"%>">
									<%=status%>
							</span></td>
							<td>
								<div class="action-wrap">
									<a
										href="UserManagementController?editId=<%=userId%><%=preservedQueryString.isEmpty() ? "" : "&" + preservedQueryString%>"
										class="btn btn-sm btn-outline-purple">Edit</a>

									<form action="UserManagementController" method="post"
										onsubmit="return confirm('Are you sure you want to <%=isActive ? "deactivate" : "activate"%> this user?');">
										<input type="hidden" name="user_id" value="<%=userId%>">
										<%
										if (isActive) {
										%>
										<button type="submit" name="deactivate" value="deactivate"
											class="btn btn-sm btn-soft-danger">Deactivate</button>
										<%
										} else {
										%>
										<button type="submit" name="activate" value="activate"
											class="btn btn-sm btn-soft-success">Activate</button>
										<%
										}
										%>
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
					Showing <span><%=startIndex + 1%>&ndash;<%=endIndex%></span> of <span><%=totalUsers%></span>
					users
				</div>

				<div class="pagination-controls">

					<%-- Prev --%>
					<a
						href="UserManagementController?page=<%=currentPage - 1%>&<%=filterQuery%>"
						class="page-btn <%=currentPage == 1 ? "disabled" : ""%>">&#8592;</a>

					<%
					int startPage = Math.max(1, currentPage - 2);
					int endPage = Math.min(totalPages, currentPage + 2);

					if (startPage > 1) {
					%>
					<a href="UserManagementController?page=1&<%=filterQuery%>"
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
					<a href="UserManagementController?page=<%=p%>&<%=filterQuery%>"
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
						href="UserManagementController?page=<%=totalPages%>&<%=filterQuery%>"
						class="page-btn"><%=totalPages%></a>
					<%
					}
					%>

					<%-- Next --%>
					<a
						href="UserManagementController?page=<%=currentPage + 1%>&<%=filterQuery%>"
						class="page-btn <%=currentPage == totalPages || totalPages == 0 ? "disabled" : ""%>">&#8594;</a>

				</div>
			</div>
			<%
			}
			%>
		</div>
	</main>

	<div class="modal fade" id="addUserModal" tabindex="-1"
		aria-labelledby="addUserModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content add-user-modal">
				<div class="modal-header add-user-header">
					<h5 class="modal-title" id="addUserModalLabel">Add User</h5>
					<button type="button" class="btn-close" data-bs-dismiss="modal"
						aria-label="Close"></button>
				</div>

				<div class="modal-body add-user-body">
					<form action="UserManagementController" method="post"
						id="addUserForm">
						<div class="popup-field">
							<label class="popup-label">Full Name</label> <input type="text"
								class="form-control popup-input" name="name"
								placeholder="Enter full name" required>
						</div>
						<div class="popup-field">
							<label class="popup-label">Email</label> <input type="email"
								class="form-control popup-input" name="email"
								placeholder="Enter email address" required>
						</div>
						<div class="popup-field">
							<label class="popup-label">Password</label> <input
								type="password" class="form-control popup-input" name="password"
								placeholder="Enter password" required>
						</div>
						<div class="popup-field">
							<label class="popup-label">Role</label> <select
								class="form-select popup-select" name="role_id" required>
								<option value="">Select role</option>
								<%
								for (Map<String, String> role : roleList) {
								%>
								<option value="<%=role.get("role_id")%>"><%=role.get("role_name")%></option>
								<%
								}
								%>
							</select>
						</div>
					</form>
				</div>

				<div class="modal-footer add-user-footer">
					<button type="button" class="btn btn-popup-cancel"
						data-bs-dismiss="modal">Cancel</button>
					<button type="submit" form="addUserForm" name="add" value="add"
						class="btn btn-popup-submit">Add User</button>
				</div>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

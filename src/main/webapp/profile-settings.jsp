
<%
request.setAttribute("activePage", "profile-settings");
request.setAttribute("topbarTitle", "Profile Settings");

String name = (String) request.getAttribute("name");
String email = (String) request.getAttribute("email");
String roleName = (String) request.getAttribute("roleName");
String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");

if (name == null)
	name = "";
if (email == null)
	email = "";
if (roleName == null)
	roleName = "";

String maskedEmail = email;
if (email.contains("@")) {
	int atIndex = email.indexOf("@");
	String prefix = email.substring(0, atIndex);
	String domain = email.substring(atIndex);
	if (prefix.length() > 2) {
		maskedEmail = prefix.substring(0, 2) + "******" + domain;
	} else {
		maskedEmail = "******" + domain;
	}
}
%>
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Profile Settings | Port Management ERP</title>

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

.dash-card {
	background: var(--bg-card);
	border: 1px solid var(--border-soft);
	border-radius: 20px;
	box-shadow: var(--shadow-main);
}

.account-card {
	padding: 24px;
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
	margin-bottom: 0;
}

.account-row {
	padding: 18px 0;
	border-bottom: 1px solid rgba(192, 132, 252, 0.12);
}

.account-row:last-child {
	border-bottom: none;
}

.account-label {
	font-size: 1rem;
	font-weight: 700;
	color: #ffffff;
}

.account-value {
	color: var(--text-soft);
	font-weight: 600;
	word-break: break-word;
}

.role-badge {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	padding: 8px 14px;
	border-radius: 999px;
	background: rgba(168, 85, 247, 0.15);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
	font-weight: 700;
}

.btn-edit, .btn-purple, .btn-outline-purple {
	min-width: 110px;
	height: 42px;
	padding: 0 16px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	border-radius: 12px;
	font-weight: 700;
	line-height: 1;
	white-space: nowrap;
	text-decoration: none;
}

.btn-edit, .btn-outline-purple {
	background: rgba(168, 85, 247, 0.10);
	border: 1px solid var(--border-strong);
	color: var(--purple-light);
}

.btn-purple {
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
}

.form-label {
	color: var(--purple-light);
	font-weight: 650;
	margin-bottom: 10px;
}

.form-control {
	background: #12121a;
	border: 1px solid var(--border-soft);
	color: #ffffff;
	border-radius: 14px;
	min-height: 48px;
}

.form-control:focus {
	background: #171721;
	color: #ffffff;
	border-color: var(--purple-bright);
	box-shadow: 0 0 0 0.2rem rgba(168, 85, 247, 0.22);
}

.form-control::placeholder {
	color: #8d82a8;
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
	font-size: 1.25rem;
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
}
</style>
</head>

<body>

	<jsp:include page="/includes/topbar.jsp" />
	<jsp:include page="/includes/sidebar.jsp" />

	<main class="main-content">
		<div class="content-head">
			<h2 class="page-title">Profile Settings</h2>
			<p class="page-subtitle">Manage your account information and
				security settings.</p>
		</div>

		<%
		if (message != null && !message.trim().isEmpty()) {
		%>
		<div class="alert alert-success"><%=message%></div>
		<%
		}
		%>

		<%
		if (error != null && !error.trim().isEmpty()) {
		%>
		<div class="alert alert-danger"><%=error%></div>
		<%
		}
		%>

		<div class="dash-card account-card">
			<div class="mb-4">
				<div class="section-title">Account Info</div>
				<div class="section-subtitle">Edit your personal details using
					focused popup forms.</div>
			</div>

			<div class="account-row">
				<div class="row align-items-center g-3">
					<div class="col-md-3">
						<div class="account-label">Full Name</div>
					</div>
					<div class="col-md-6">
						<div class="account-value"><%=name%></div>
					</div>
					<div class="col-md-3 text-md-end">
						<button type="button" class="btn btn-edit" data-bs-toggle="modal"
							data-bs-target="#editNameModal">Edit</button>
					</div>
				</div>
			</div>

			<div class="account-row">
				<div class="row align-items-center g-3">
					<div class="col-md-3">
						<div class="account-label">Email Address</div>
					</div>
					<div class="col-md-6">
						<div class="account-value"><%=maskedEmail%></div>
					</div>
					<div class="col-md-3 text-md-end">
						<button type="button" class="btn btn-edit" data-bs-toggle="modal"
							data-bs-target="#editEmailModal">Edit</button>
					</div>
				</div>
			</div>

			<div class="account-row">
				<div class="row align-items-center g-3">
					<div class="col-md-3">
						<div class="account-label">Password</div>
					</div>
					<div class="col-md-6">
						<div class="account-value">************</div>
					</div>
					<div class="col-md-3 text-md-end">
						<button type="button" class="btn btn-edit" data-bs-toggle="modal"
							data-bs-target="#editPasswordModal">Edit</button>
					</div>
				</div>
			</div>

			<div class="account-row">
				<div class="row align-items-center g-3">
					<div class="col-md-3">
						<div class="account-label">Assigned Role</div>
					</div>
					<div class="col-md-6">
						<div class="role-badge"><%=roleName%></div>
					</div>
					<div class="col-md-3 text-md-end"></div>
				</div>
			</div>
		</div>
	</main>

	<div class="modal fade" id="editNameModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<form action="ProfileManagementController" method="post">
					<input type="hidden" name="action" value="updateName">

					<div class="modal-header">
						<h5 class="modal-title">Edit Full Name</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal"></button>
					</div>

					<div class="modal-body">
						<label class="form-label">Full Name</label> <input type="text"
							class="form-control" name="name" value="<%=name%>" required>
					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-outline-purple"
							data-bs-dismiss="modal">Cancel</button>
						<button type="submit" class="btn btn-purple">Save Changes</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="editEmailModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<form action="ProfileManagementController" method="post">
					<input type="hidden" name="action" value="changeEmail">

					<div class="modal-header">
						<h5 class="modal-title">Edit Email Address</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal"></button>
					</div>

					<div class="modal-body">
						<div class="mb-3">
							<label class="form-label">New Email</label> <input type="email"
								class="form-control" name="email" placeholder="Enter new email"
								required>
						</div>

						<div class="mb-0">
							<label class="form-label">Confirm Email</label> <input
								type="email" class="form-control" name="confirm_email"
								placeholder="Re-enter new email" required>
						</div>
					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-outline-purple"
							data-bs-dismiss="modal">Cancel</button>
						<button type="submit" class="btn btn-purple">Save Changes</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<div class="modal fade" id="editPasswordModal" tabindex="-1"
		aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
				<form action="ProfileManagementController" method="post">
					<input type="hidden" name="action" value="changePassword">

					<div class="modal-header">
						<h5 class="modal-title">Change Password</h5>
						<button type="button" class="btn-close btn-close-white"
							data-bs-dismiss="modal"></button>
					</div>

					<div class="modal-body">
						<div class="mb-3">
							<label class="form-label">Current Password</label> <input
								type="password" class="form-control" name="current_password"
								placeholder="Enter current password" required>
						</div>

						<div class="mb-3">
							<label class="form-label">New Password</label> <input
								type="password" class="form-control" name="new_password"
								placeholder="Enter new password" required>
						</div>

						<div class="mb-0">
							<label class="form-label">Confirm New Password</label> <input
								type="password" class="form-control" name="confirm_password"
								placeholder="Re-enter new password" required>
						</div>
					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-outline-purple"
							data-bs-dismiss="modal">Cancel</button>
						<button type="submit" class="btn btn-purple">Save Changes</button>
					</div>
				</form>
			</div>
		</div>
	</div>

	<script
		src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
if (session.getAttribute("loggedUser") != null) {
	response.sendRedirect("UserController?dashboard=1");
	return;
}

String error = (String) request.getAttribute("error");
String msg = request.getParameter("msg");
String queryError = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login | Port Management ERP</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link href="assets/css/common.css" rel="stylesheet">
<style>
body {
	margin: 0;
	min-height: 100vh;
	background: radial-gradient(circle at top left, rgba(122, 34, 216, 0.22),
		transparent 30%),
		radial-gradient(circle at bottom right, rgba(168, 85, 247, 0.18),
		transparent 28%), var(--bg-main);
	color: var(--text-main);
	font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 24px;
}

.login-shell {
	width: 100%;
	max-width: 460px;
}

.login-card {
	background: var(--bg-card);
	border: 1px solid var(--border-soft);
	border-radius: 24px;
	box-shadow: var(--shadow-main), var(--glow-soft);
	padding: 34px;
}

.brand-wrap {
	text-align: center;
	margin-bottom: 28px;
}

.brand-title {
	color: #ffffff;
	font-weight: 800;
	font-size: 1.8rem;
	margin-bottom: 6px;
	letter-spacing: 0.4px;
}

.brand-accent {
	color: var(--purple-light);
}

.brand-subtitle {
	color: var(--text-soft);
	margin-bottom: 0;
	font-size: 0.98rem;
}

.form-label {
	color: var(--purple-light);
	font-weight: 650;
	margin-bottom: 10px;
}

.form-control {
	background-color: #12121a;
	border: 1px solid var(--border-soft);
	color: #ffffff;
	border-radius: 14px;
	min-height: 50px;
}

.form-control:focus {
	background-color: #171721;
	color: #ffffff;
	border-color: var(--purple-bright);
	box-shadow: 0 0 0 0.2rem rgba(168, 85, 247, 0.22);
}

.form-control::placeholder {
	color: #867a9c;
}

.btn-purple {
	width: 100%;
	min-height: 52px;
	border-radius: 14px;
	font-weight: 700;
	border: 1px solid rgba(216, 180, 254, 0.28);
	color: #ffffff;
	background: linear-gradient(135deg, #8a2be2 0%, #a855f7 100%);
	box-shadow: 0 8px 18px rgba(138, 43, 226, 0.28);
}

.btn-purple:hover {
	background: linear-gradient(135deg, #9b4df1 0%, #b86cff 100%);
	color: #ffffff;
}

.footer-note {
	text-align: center;
	color: var(--text-muted);
	font-size: 0.9rem;
	margin-top: 18px;
}
</style>
</head>
<body>

	<div class="login-shell">
		<div class="login-card">
			<div class="brand-wrap">
				<div class="brand-title">Port Management ERP</div>
				<p class="brand-subtitle">Login to access your port management
					workspace.</p>
			</div>

			<%
			if (error != null) {
			%>
			<div class="alert alert-danger"><%=error%></div>
			<%
			}
			%>

			<%
			if ("logout".equals(msg)) {
			%>
			<div class="alert alert-success">Logged out successfully.</div>
			<%
			}
			%>

			<%
			if ("session".equals(queryError)) {
			%>
			<div class="alert alert-warning">Please login first.</div>
			<%
			}
			%>

			<%
			if ("access".equals(queryError)) {
			%>
			<div class="alert alert-warning">You are not authorized to
				access that page.</div>
			<%
			}
			%>

			<form action="UserController" method="post">
				<div class="mb-3">
					<label class="form-label">Email Address</label> <input type="email"
						name="email" class="form-control"
						placeholder="Enter email address" required>
				</div>

				<div class="mb-4">
					<label class="form-label">Password</label> <input type="password"
						name="password" class="form-control" placeholder="Enter password"
						required>
				</div>

				<button type="submit" name="login" value="login"
					class="btn btn-purple">Login</button>
			</form>

			<div class="footer-note">Secure role-based access for Port
				Management ERP.</div>
		</div>
	</div>

</body>
</html>
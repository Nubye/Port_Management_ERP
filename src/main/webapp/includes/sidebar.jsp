<%@ page import="model.User"%>
<%@ page import="java.util.Collections"%>
<%@ page import="java.util.Set"%>
<%
User sidebarUser = (User) session.getAttribute("loggedUser");
String activePage = (String) request.getAttribute("activePage");
Set<String> allowedPages = (Set<String>) session.getAttribute("allowedPages");

if (sidebarUser == null) {
	response.sendRedirect("login.jsp?error=session");
	return;
}

if (activePage == null)
	activePage = "";
if (allowedPages == null)
	allowedPages = Collections.emptySet();
%>

<aside class="sidebar">
	<div class="module-label">Operations</div>
	<nav class="nav flex-column">
		<a href="UserController?dashboard=1"
			class="nav-link <%="dashboard".equals(activePage) ? "active" : ""%>">
			Dashboard </a>

		<%
		if (allowedPages.contains("user-management")) {
		%>
		<a href="UserManagementController"
			class="nav-link <%="user-management".equals(activePage) ? "active" : ""%>">
			User Management </a>
		<%
		}
		%>

		<%
		if (allowedPages.contains("ship-management")) {
		%>
		<a href="ShipManagementController"
			class="nav-link <%="ship-management".equals(activePage) ? "active" : ""%>">
			Ship Management </a>
		<%
		}
		%>

		<%
		if (allowedPages.contains("dock-management")) {
		%>
		<a href="DockManagementController"
			class="nav-link <%="dock-management".equals(activePage) ? "active" : ""%>">
			Dock Management </a>
		<%
		}
		%>

		<%
		if (allowedPages.contains("dock-allocation")) {
		%>
		<a href="DockAllocationController"
			class="nav-link <%="dock-allocation".equals(activePage) ? "active" : ""%>">
			Dock Allocation </a>
		<%
		}
		%>

		<%
		if (allowedPages.contains("container-management")) {
		%>
		<a href="ContainerManagementController"
			class="nav-link <%="container-management".equals(activePage) ? "active" : ""%>">
			Container Management </a>
		<%
		}
		%>

		<%
		if (allowedPages.contains("cargo-management")) {
		%>
		<a href="CargoManagementController"
			class="nav-link <%="cargo-management".equals(activePage) ? "active" : ""%>">
			Cargo Management </a>
		<%
		}
		%>

		<%
		if (allowedPages.contains("cargo-movement")) {
		%>
		<a href="CargoMovementController"
			class="nav-link <%="cargo-movement".equals(activePage) ? "active" : ""%>">
			Cargo Movement </a>
		<%
		}
		%>

		<%
		if (allowedPages.contains("security-log")) {
		%>
		<a href="SecurityLogController"
			class="nav-link <%="security-log".equals(activePage) ? "active" : ""%>">
			Security Log </a>
		<%
		}
		%>

		<a href="ProfileManagementController"
			class="nav-link <%="profile-settings".equals(activePage) ? "active" : ""%>">
			Profile Settings </a> <a href="UserController?logout=1" class="nav-link">
			Logout </a>
	</nav>
</aside>
<%@ page import="model.User"%>
<%
User topbarUser = (User) session.getAttribute("loggedUser");
String topbarRoleName = (String) session.getAttribute("roleName");
String topbarTitle = (String) request.getAttribute("topbarTitle");

if (topbarRoleName == null)
	topbarRoleName = "User";
if (topbarTitle == null || topbarTitle.trim().isEmpty())
	topbarTitle = topbarRoleName;
%>
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/assets/css/common.css">
<nav
	class="topbar d-flex align-items-center justify-content-between px-4">
	<div class="brand-title">Port Management ERP</div>
	<div class="topbar-badge"><%=topbarTitle%></div>
</nav>
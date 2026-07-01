package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class AuthFilter implements Filter {

	private static final String MOD_DASHBOARD = "DASHBOARD";
	private static final String MOD_USER_MANAGEMENT = "USER_MANAGEMENT";
	private static final String MOD_SHIP_MANAGEMENT = "SHIP_MANAGEMENT";
	private static final String MOD_DOCK_MANAGEMENT = "DOCK_MANAGEMENT";
	private static final String MOD_DOCK_ALLOCATION = "DOCK_ALLOCATION";
	private static final String MOD_CONTAINER_MANAGEMENT = "CONTAINER_MANAGEMENT";
	private static final String MOD_CARGO_MANAGEMENT = "CARGO_MANAGEMENT";
	private static final String MOD_CARGO_MOVEMENT = "CARGO_MOVEMENT";
	private static final String MOD_SECURITY_LOG = "SECURITY_LOG";
	private static final String MOD_PROFILE_SETTINGS = "PROFILE_SETTINGS";

	private static final Set<String> PORT_MANAGER_ACCESS = new HashSet<>(Arrays.asList(MOD_DASHBOARD,
			MOD_SHIP_MANAGEMENT, MOD_DOCK_MANAGEMENT, MOD_DOCK_ALLOCATION, MOD_CONTAINER_MANAGEMENT,
			MOD_CARGO_MANAGEMENT, MOD_CARGO_MOVEMENT, MOD_SECURITY_LOG, MOD_PROFILE_SETTINGS));

	private static final Set<String> SHIP_OPERATOR_ACCESS = new HashSet<>(
			Arrays.asList(MOD_DASHBOARD, MOD_SHIP_MANAGEMENT, MOD_CONTAINER_MANAGEMENT, MOD_PROFILE_SETTINGS));

	private static final Set<String> DOCK_MANAGER_ACCESS = new HashSet<>(
			Arrays.asList(MOD_DASHBOARD, MOD_DOCK_MANAGEMENT, MOD_DOCK_ALLOCATION, MOD_PROFILE_SETTINGS));

	private static final Set<String> CARGO_HANDLER_ACCESS = new HashSet<>(
			Arrays.asList(MOD_DASHBOARD, MOD_CARGO_MANAGEMENT, MOD_CARGO_MOVEMENT, MOD_PROFILE_SETTINGS));

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse resp = (HttpServletResponse) response;

		String path = getPath(req);

		if (isPublicRequest(req, path)) {
			chain.doFilter(request, response);
			return;
		}

		HttpSession session = req.getSession(false);

		if (session == null) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp?error=session");
			return;
		}

		User loggedUser = (User) session.getAttribute("loggedUser");

		if (loggedUser == null) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp?error=session");
			return;
		}

		Integer roleId = getRoleId(session, loggedUser);
		String roleName = getRoleName(session, loggedUser);

		if (roleId == null && (roleName == null || roleName.trim().isEmpty())) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp?error=session");
			return;
		}

		String module = resolveModule(req, path);
		session.setAttribute("allowedPages", resolveAllowedPages(roleId, roleName));

		if (module == null) {
			chain.doFilter(request, response);
			return;
		}

		if (!isAllowed(roleId, roleName, module)) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp?error=access");
			return;
		}

		chain.doFilter(request, response);
	}

	@Override
	public void destroy() {
	}

	private String getPath(HttpServletRequest req) {
		String path = req.getRequestURI();
		String context = req.getContextPath();
		if (path.startsWith(context))
			path = path.substring(context.length());
		return path.isEmpty() ? "/" : path;
	}

	private boolean isPublicRequest(HttpServletRequest req, String path) {
		if ("/login.jsp".equals(path))
			return true;

		if (path.startsWith("/UserController")) {
			return req.getParameter("login") != null;
		}

		return path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/")
				|| path.startsWith("/webjars/") || path.startsWith("/assets/");
	}

	private String resolveModule(HttpServletRequest req, String path) {
		if (path.startsWith("/UserController") && req.getParameter("dashboard") != null)
			return MOD_DASHBOARD;
		if ("/dashboard.jsp".equals(path))
			return MOD_DASHBOARD;

		if (path.startsWith("/UserManagementController") || "/user-management.jsp".equals(path))
			return MOD_USER_MANAGEMENT;
		if (path.startsWith("/ShipManagementController") || "/ship-management.jsp".equals(path))
			return MOD_SHIP_MANAGEMENT;
		if (path.startsWith("/DockManagementController") || "/dock-management.jsp".equals(path))
			return MOD_DOCK_MANAGEMENT;
		if (path.startsWith("/DockAllocationController") || "/dock-allocation.jsp".equals(path))
			return MOD_DOCK_ALLOCATION;
		if (path.startsWith("/ContainerManagementController") || "/container-management.jsp".equals(path))
			return MOD_CONTAINER_MANAGEMENT;
		if (path.startsWith("/CargoManagementController") || "/cargo-management.jsp".equals(path))
			return MOD_CARGO_MANAGEMENT;
		if (path.startsWith("/CargoMovementController") || "/cargo-movement.jsp".equals(path))
			return MOD_CARGO_MOVEMENT;
		if (path.startsWith("/SecurityLogController") || "/security-log.jsp".equals(path))
			return MOD_SECURITY_LOG;
		if (path.startsWith("/ProfileManagementController") || "/profile-management.jsp".equals(path)
				|| "/profile-settings.jsp".equals(path))
			return MOD_PROFILE_SETTINGS;

		return null;
	}

	private boolean isAllowed(Integer roleId, String roleName, String module) {
		return resolveAllowedModules(roleId, roleName).contains(module);
	}

	private Set<String> resolveAllowedModules(Integer roleId, String roleName) {
		if (roleId != null && roleId == 1)
			return allModules();

		String role = normalize(roleName);

		if ("admin".equals(role))
			return allModules();
		if ("port manager".equals(role))
			return PORT_MANAGER_ACCESS;
		if ("ship operator".equals(role))
			return SHIP_OPERATOR_ACCESS;
		if ("dock manager".equals(role))
			return DOCK_MANAGER_ACCESS;
		if ("cargo handler".equals(role))
			return CARGO_HANDLER_ACCESS;

		return new HashSet<>();
	}

	private Set<String> resolveAllowedPages(Integer roleId, String roleName) {
		if (roleId != null && roleId == 1)
			return allPages();

		String role = normalize(roleName);

		if ("admin".equals(role))
			return allPages();

		if ("port manager".equals(role)) {
			return new HashSet<>(Arrays.asList("dashboard", "ship-management", "dock-management", "dock-allocation",
					"container-management", "cargo-management", "cargo-movement", "security-log", "profile-settings"));
		}

		if ("ship operator".equals(role)) {
			return new HashSet<>(
					Arrays.asList("dashboard", "ship-management", "container-management", "profile-settings"));
		}

		if ("dock manager".equals(role)) {
			return new HashSet<>(Arrays.asList("dashboard", "dock-management", "dock-allocation", "profile-settings"));
		}

		if ("cargo handler".equals(role)) {
			return new HashSet<>(Arrays.asList("dashboard", "cargo-management", "cargo-movement", "profile-settings"));
		}

		return new HashSet<>();
	}

	private Set<String> allModules() {
		return new HashSet<>(Arrays.asList(MOD_DASHBOARD, MOD_USER_MANAGEMENT, MOD_SHIP_MANAGEMENT, MOD_DOCK_MANAGEMENT,
				MOD_DOCK_ALLOCATION, MOD_CONTAINER_MANAGEMENT, MOD_CARGO_MANAGEMENT, MOD_CARGO_MOVEMENT,
				MOD_SECURITY_LOG, MOD_PROFILE_SETTINGS));
	}

	private Set<String> allPages() {
		return new HashSet<>(Arrays.asList("dashboard", "user-management", "ship-management", "dock-management",
				"dock-allocation", "container-management", "cargo-management", "cargo-movement", "security-log",
				"profile-settings"));
	}

	private Integer getRoleId(HttpSession session, User user) {
		if (session != null) {
			Object roleIdObj = session.getAttribute("roleId");
			if (roleIdObj != null) {
				try {
					return Integer.parseInt(roleIdObj.toString());
				} catch (Exception ignored) {
				}
			}
		}
		return (user != null && user.getRoleId() > 0) ? user.getRoleId() : null;
	}

	private String getRoleName(HttpSession session, User user) {
		if (session != null) {
			Object roleNameObj = session.getAttribute("roleName");
			if (roleNameObj != null) {
				String role = roleNameObj.toString().trim();
				if (!role.isEmpty())
					return role;
			}
		}
		return (user != null && user.getRoleName() != null) ? user.getRoleName().trim() : null;
	}

	private String normalize(String value) {
		return value == null ? "" : value.trim().toLowerCase();
	}
}
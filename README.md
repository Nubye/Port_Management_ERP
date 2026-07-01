# Port Management ERP

A comprehensive Java web application for managing port operations including ships, docks, containers, cargo, and user access control. Built as a Jakarta EE servlet-based application with MySQL backend.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Project Structure](#project-structure)
- [Roles & Permissions](#roles--permissions)
- [Modules](#modules)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

Port Management ERP is a full-featured enterprise application designed to streamline port operations. It provides a centralized platform for managing ships, docks, containers, and cargo while maintaining comprehensive security logs and user management. The application implements role-based access control to ensure users only access features appropriate to their responsibilities.

![Login Page](<Screenshot 2026-07-01 224333.png>)

## Features

- **Role-Based Access Control** — Five distinct user roles with granular permission levels
- **Ship Management** — Track and manage ships with arrival/departure dates and status
- **Dock Management** — Manage dock status (Available, Occupied, Under Maintenance)
- **Dock Allocation** — Allocate and release docks to ships with conflict prevention
- **Container Management** — Track containers by type and status across ships
- **Cargo Management** — Manage cargo items with weight validation and status tracking
- **Cargo Movement Tracking** — Auto-log cargo movements on status changes
- **User Management** — Admin panel for complete user lifecycle management
- **Security Logging** — Session tracking with entry/exit timestamps and CSV export
- **Profile Management** — User profile editing with email and password changes

![Dashboard](<Screenshot 2026-07-01 224218.png>)

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Java Servlets (Jakarta EE 10) |
| **Frontend** | JSP, HTML5, CSS3, JavaScript |
| **Database** | MySQL 8.0 |
| **JDBC Driver** | MySQL Connector/J |
| **Application Server** | Apache Tomcat 10.1+ |
| **Build Tool** | Eclipse JDT |

### Design Patterns Used

- **Front Controller** — `AuthFilter` intercepts all requests for centralized authentication
- **Model 2 MVC** — Separation of concerns between controllers, models, and JSP views
- **DAO Pattern** — Operation interfaces with implementor classes for database abstraction
- **Flash Message Pattern** — Session-based success/error notifications auto-cleared after display

## Project Structure

```
port_management/
├── src/
│   └── main/
│       ├── java/
│       │   ├── controller/              # Servlet controllers (request handling)
│       │   │   ├── UserController.java
│       │   │   ├── UserManagementController.java
│       │   │   ├── ShipManagementController.java
│       │   │   ├── DockManagementController.java
│       │   │   ├── DockAllocationController.java
│       │   │   ├── ContainerManagementController.java
│       │   │   ├── CargoManagementController.java
│       │   │   ├── CargoMovementController.java
│       │   │   ├── SecurityLogController.java
│       │   │   ├── ProfileManagementController.java
│       │   │   ├── ControllerAuthUtil.java      # Shared authentication helper
│       │   │   └── ControllerSupport.java       # Shared utility methods
│       │   ├── model/                   # Model classes (business logic)
│       │   │   ├── User.java
│       │   │   ├── UserManagement.java
│       │   │   ├── ShipManagement.java
│       │   │   ├── DockManagement.java
│       │   │   ├── DockAllocation.java
│       │   │   ├── ContainerManagement.java
│       │   │   ├── CargoManagement.java
│       │   │   ├── CargoMovement.java
│       │   │   ├── SecurityLog.java
│       │   │   └── ProfileManagement.java
│       │   ├── operations/              # Operation interfaces (DAO contracts)
│       │   │   ├── User_Operation.java
│       │   │   ├── UserManagement_Operation.java
│       │   │   ├── ShipManagement_Operation.java
│       │   │   ├── DockManagement_Operation.java
│       │   │   ├── DockAllocation_Operation.java
│       │   │   ├── ContainerManagement_Operation.java
│       │   │   ├── CargoManagement_Operation.java
│       │   │   ├── CargoMovement_Operation.java
│       │   │   ├── SecurityLog_Operation.java
│       │   │   └── ProfileManagement_Operation.java
│       │   ├── operation_implementor/   # DAO implementations (database layer)
│       │   │   ├── User_Implementor.java
│       │   │   ├── UserManagement_Implementor.java
│       │   │   ├── ShipManagement_Implementor.java
│       │   │   ├── DockManagement_Implementor.java
│       │   │   ├── DockAllocation_Implementor.java
│       │   │   ├── ContainerManagement_Implementor.java
│       │   │   ├── CargoManagement_Implementor.java
│       │   │   ├── CargoMovement_Implementor.java
│       │   │   ├── SecurityLog_Implementor.java
│       │   │   └── ProfileManagement_Implementor.java
│       │   ├── db_config/               # Database configuration
│       │   │   └── GetConnection.java
│       │   └── filter/                  # Servlet filters
│       │       └── AuthFilter.java
│       └── webapp/                      # JSP views
│           ├── login.jsp
│           ├── dashboard.jsp
│           ├── user-management.jsp
│           ├── ship-management.jsp
│           ├── dock-management.jsp
│           ├── dock-allocation.jsp
│           ├── container-management.jsp
│           ├── cargo-management.jsp
│           ├── cargo-movement.jsp
│           ├── profile-settings.jsp
│           ├── security-log.jsp
│           └── includes/ 
│               ├── sidebar.jsp
│               └── topbar.jsp
├── port_management_erp.sql              # Database schema & procedures
├── .gitignore
├── .classpath
└── .project
```

## Roles & Permissions

The application implements five distinct user roles, each with specific access boundaries:

| Role | Role ID | Accessible Modules |
|------|---------|--------------------|
| **Admin** | 1 | All modules — full system access |
| **Port Manager** | 2 | Dashboard, Ships, Docks, Dock Allocation, Containers, Cargo, Cargo Movement, Security Log, Profile |
| **Ship Operator** | 3 | Dashboard, Ships, Containers, Profile |
| **Dock Manager** | 4 | Dashboard, Docks, Dock Allocation, Profile |
| **Cargo Handler** | 5 | Dashboard, Cargo, Cargo Movement, Profile |


## Modules

### 1. User Management
- **Access**: Admin only (Role ID: 1)
- **Features**: Create, read, update, deactivate/activate users; search and filter by name, email, role, and status
- **Database**: Uses `sp_create_user`, `sp_update_user`, `sp_delete_user`, `sp_deactivate_user`, `sp_activate_user` stored procedures
- **Validation**: Duplicate email prevention via trigger `trg_check_duplicate_email`

### 2. Ship Management
- **Access**: Admin, Port Manager, Ship Operator (Role IDs: 1, 2, 3)
- **Features**: Add, update, delete ships; search by name and status; status counts (Anchored, Docked, Departed)
- **Database**: Uses `add_ship`, `update_ship`, `sp_delete_ship` stored procedures
- **Validation**: Departure date must be after arrival date; cannot delete ships with active dock allocations or assigned containers

### 3. Dock Management
- **Access**: Admin, Port Manager, Dock Manager (Role IDs: 1, 2, 4)
- **Features**: Add, update, delete docks; search by name and status; track dock occupancy
- **Database**: Uses `add_dock`, `update_dock`, `delete_dock`, `show_dock` stored procedures
- **Status Values**: Available, Occupied, Under Maintenance

### 4. Dock Allocation
- **Access**: Admin, Port Manager, Dock Manager (Role IDs: 1, 2, 4)
- **Features**: Allocate, release, update, and delete dock-to-ship allocations; search with status filter
- **Database**: Uses `allocate_dock`, `release_dock`, `update_allocation`, `delete_allocation` stored procedures
- **Validation**: Prevents allocating occupied or maintenance docks; auto-updates dock status on allocation/release

### 5. Container Management
- **Access**: Admin, Port Manager, Ship Operator (Role IDs: 1, 2, 3)
- **Features**: Add, update, delete containers; search/filter by ID, type, status, and ship; statistics dashboard
- **Database**: Uses `add_container`, `update_container`, `delete_container`, `search_container` stored procedures
- **Status Values**: Loaded, Empty, In Transit

### 6. Cargo Management
- **Access**: Admin, Port Manager, Cargo Handler (Role IDs: 1, 2, 5)
- **Features**: Add, update, delete cargo; search by keyword and status; automatic movement logging on status changes
- **Database**: Uses `add_cargo`, `update_cargo`, `delete_cargo`, `search_cargo` stored procedures
- **Validation**: Weight must be greater than zero; auto-triggers cargo movement on status changes

### 7. Cargo Movement
- **Access**: Admin, Port Manager, Cargo Handler (Role IDs: 1, 2, 5)
- **Features**: Log cargo movements (Load, Unload, Transfer); view cargo history; track handler information
- **Database**: Uses `log_cargo_movement`, `get_cargo_history` stored procedures; `vw_cargo_movement_history` view

### 8. Security Log
- **Access**: Admin, Port Manager (Role IDs: 1, 2)
- **Features**: View session logs; filter by username, role, and date range; CSV export functionality
- **Database**: Uses `v_security_log` view; `sp_session_open`, `sp_session_close` procedures
- **Protection**: Security logs are read-only — cannot be deleted or modified (triggers enforce this)

### 9. Profile Settings
- **Access**: All authenticated users
- **Features**: View and update profile name; change email; change password
- **Database**: Uses `sp_update_profile_name`, `sp_change_email`, `sp_change_password` stored procedures
- **Validation**: Duplicate email prevention on email changes

## Prerequisites

Before setting up this project, ensure you have the following installed:

- **Java JDK** — Version 17 or higher (LTS recommended)
- **Apache Tomcat** — Version 10.1+ (Jakarta EE 10 compatible)
- **MySQL** — Version 8.0+
- **Eclipse IDE** — For Java EE (recommended for development)
- **Git** — For version control

## Installation

### Step 1: Clone the Repository

```bash
git clone <your-repository-url>
cd port_management
```

### Step 2: Import into Eclipse

1. Open Eclipse IDE
2. Go to **File → Import → General → Existing Projects into Workspace**
3. Select the project directory
4. Click **Finish**

### Step 3: Configure Build Path

1. Right-click project → **Build Path → Configure Build Path**
2. Under **Libraries**, add:
   - **Servlet API** (from Tomcat installation: `lib/jakarta.servlet-api.jar`)
   - **MySQL Connector/J** JDBC driver JAR

## Database Setup

The complete database schema, including tables, stored procedures, views, and triggers, is provided in the `port_management_erp.sql` file located in the project root directory.

### Quick Setup

1. Open MySQL Workbench or the MySQL command line
2. Run the SQL file:

```bash
mysql -u root -p < port_management_erp.sql
```

Or in MySQL:

```sql
source /path/to/port_management_erp.sql;
```

This will:
- Create the `port_management_erp` database
- Create all required tables (`role`, `user`, `ship`, `dock`, `dock_allocation`, `container`, `cargo`, `cargo_movement`, `security_log`)
- Create stored procedures for all module operations
- Create database views for reporting
- Create triggers for data integrity validation

### Database Schema Overview

The database includes the following core tables:

| Table | Description |
|-------|-------------|
| `role` | User roles (Admin, Port Manager, Ship Operator, Dock Manager, Cargo Handler) |
| `user` | User accounts with authentication and status |
| `ship` | Ship records with arrival/departure tracking |
| `dock` | Dock facilities with status management |
| `dock_allocation` | Ship-to-dock allocation records |
| `container` | Shipping containers linked to ships |
| `cargo` | Cargo items linked to containers |
| `cargo_movement` | Movement history for cargo items |
| `security_log` | User session tracking |

The database also includes **views** for reporting (`v_profile_details`, `v_ship_details`, `v_container_details`, `vw_active_dock_allocations`, `vw_cargo_details`, `v_security_log`) and **triggers** for enforcing business rules (duplicate email prevention, date validation, dock status updates, security log protection).

## Configuration

### Database Connection

Update the database credentials in `src/main/java/db_config/GetConnection.java`:

```java
connection = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/port_management_erp",
    "your_database_username",
    "your_database_password"
);
```

### Servlet URL Mappings

All controllers use `@WebServlet` annotations for URL mapping:

| Controller | URL Pattern |
|------------|-------------|
| `UserController` | `/UserController` |
| `UserManagementController` | `/UserManagementController` |
| `ShipManagementController` | `/ShipManagementController` |
| `DockManagementController` | `/DockManagementController` |
| `DockAllocationController` | `/DockAllocationController` |
| `ContainerManagementController` | `/ContainerManagementController` |
| `CargoManagementController` | `/CargoManagementController` |
| `CargoMovementController` | `/CargoMovementController` |
| `SecurityLogController` | `/SecurityLogController` |
| `ProfileManagementController` | `/ProfileManagementController` |

## Running the Application

### Using Eclipse + Tomcat

1. **Configure Server**:
   - Window → Preferences → Server → Runtime Environments
   - Add Apache Tomcat v10.1
   - Set the Tomcat installation directory

2. **Add Project to Server**:
   - Right-click project → **Run As → Run on Server**
   - Select your Tomcat server
   - Click Finish

3. **Access the Application**:
   - Open browser and navigate to: `http://localhost:8080/port_management/login.jsp`

### Manual Deployment

1. Build the project in Eclipse (**Project → Build All**)
2. Export as WAR file (**Right-click → Export → WAR file**)
3. Deploy WAR to Tomcat's `webapps/` directory
4. Start Tomcat server

## Security

### Authentication Flow

1. User accesses any protected page
2. `AuthFilter` checks for a valid session
3. If no session exists, redirect to `login.jsp?error=session`
4. If session exists, validate user and check role-based permissions
5. If access is denied for the role, redirect to `login.jsp?error=access`
6. On successful login, session attributes are set: `loggedUser`, `roleId`, `roleName`, `userName`

### Session Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `loggedUser` | `User` | Logged-in user object |
| `roleId` | `Integer` | User's role ID |
| `roleName` | `String` | User's role name |
| `userName` | `String` | User's display name |
| `allowedPages` | `Set<String>` | Pages accessible to the role |

### Flash Messages

The application uses session-based flash messages for success and error notifications:
- `flash_message` — Success messages
- `flash_error` — Error messages

These are automatically cleared after being displayed once using the `ControllerSupport.applyFlash()` method.

### Database-Level Security

- **Duplicate email prevention** — Trigger on `user` table insert
- **Cargo weight validation** — Trigger ensures weight > 0
- **Security log immutability** — Triggers prevent deletion and unauthorized updates
- **Ship deletion protection** — Cannot delete ships with active allocations or containers
- **Dock allocation conflicts** — Cannot allocate occupied or maintenance docks

## Troubleshooting

### Common Issues

**ClassNotFoundException: com.mysql.jdbc.Driver**
- Ensure MySQL Connector/J JAR is added to the build path
- For MySQL 8.x+, consider using `com.mysql.cj.jdbc.Driver` instead

**SQL Connection Failed**
- Verify MySQL is running on `localhost:3306`
- Check database `port_management_erp` exists
- Update credentials in `GetConnection.java`

**404 Errors on Controllers**
- Ensure Tomcat is configured for Jakarta EE (Servlet 6.0+)
- Verify `@WebServlet` annotations are being processed
- Check server logs for deployment errors

**Auth Filter Redirect Loop**
- Verify session attributes are set during login
- Check `AuthFilter.java` path resolution logic

**Role-Based Access Denied**
- Confirm user has correct `role_id` in session
- Check `AuthFilter.resolveAllowedModules()` logic

### Debug Tips

1. Check Tomcat logs: `<tomcat>/logs/catalina.out`
2. Enable JDBC debug logging
3. Add print statements in `AuthFilter.doFilter()` for session debugging
4. Verify database table schemas match model expectations

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

- **This project**: [MIT License](LICENSE) - Free for any use  


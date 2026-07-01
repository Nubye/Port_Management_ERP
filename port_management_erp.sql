drop database if exists port_management_erp ;

create database port_management_erp;

use port_management_erp;

-- Creating Tables
CREATE TABLE role (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL
);

CREATE TABLE user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id INT,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    FOREIGN KEY (role_id) REFERENCES ROLE(role_id)
);

CREATE TABLE ship (
    ship_id INT AUTO_INCREMENT PRIMARY KEY,
    ship_name VARCHAR(100) NOT NULL,
    operator_id INT NOT NULL,
    arrival_date DATETIME,
    departure_date DATETIME,
    status ENUM('Anchored','Docked','Departed'),
    FOREIGN KEY (operator_id) REFERENCES user(user_id)
    ON 	DELETE CASCADE
);

CREATE TABLE dock (
    dock_id INT PRIMARY KEY AUTO_INCREMENT,
    dock_name VARCHAR(100) NOT NULL,
    status ENUM('Available','Occupied','Under Maintenance')
);

CREATE TABLE dock_allocation(
 allocation_id INT AUTO_INCREMENT PRIMARY KEY,
 ship_id INT,
 dock_id INT,
 allocation_time DATETIME,
 release_time DATETIME,
 FOREIGN KEY(ship_id) 
	REFERENCES ship(ship_id),
 FOREIGN KEY(dock_id) 
	REFERENCES dock(dock_id)
);

CREATE TABLE container (
    container_id INT AUTO_INCREMENT PRIMARY KEY,
    container_type VARCHAR(50) NOT NULL,
    status ENUM('Loaded','Empty','In Transit'),
    ship_id INT,
    FOREIGN KEY (ship_id)
    REFERENCES ship(ship_id)
    ON DELETE CASCADE
);

CREATE TABLE cargo (
    cargo_id INT AUTO_INCREMENT PRIMARY KEY,
    container_id INT NOT NULL,
    description VARCHAR(200) NOT NULL,
    weight DECIMAL(10,2) NOT NULL,
    status ENUM('Loaded','Unloaded','In Transit') ,
    FOREIGN KEY (container_id) REFERENCES container(container_id)
    ON DELETE CASCADE
);

CREATE TABLE cargo_movement (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    cargo_id INT NOT NULL,
    movement_type ENUM('Load','Unload','Transfer'),
    movement_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    handled_by INT NOT NULL,
    FOREIGN KEY (cargo_id)
		REFERENCES cargo(cargo_id),
    FOREIGN KEY (handled_by) 
		REFERENCES user(user_id)
);

Create table security_log (
	log_id int auto_increment primary key,
    user_id int not null,
    entry_time datetime not null,
    exit_time datetime null,
    constraint fk_securitylog_user
    foreign key (user_id)
    references user(user_id)
    on delete restrict
    on update cascade
);

-- 2. User Management Module
DELIMITER &&
CREATE PROCEDURE sp_create_user(
    IN p_admin_id INT,
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_role_id INT
)
BEGIN
    INSERT INTO user(name, email, password, role_id, status)
    VALUES(p_name, p_email, p_password, p_role_id, 'Active');
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE sp_update_user(
    IN p_user_id INT,
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_role_id INT
)
BEGIN
    IF p_email IS NOT NULL AND EXISTS (
        SELECT 1
        FROM user
        WHERE email = p_email
        AND user_id != p_user_id
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;
    UPDATE user
    SET
        name = COALESCE(p_name, name),
        email = COALESCE(p_email, email),
        role_id = COALESCE(p_role_id, role_id)
    WHERE user_id = p_user_id;

END &&
DELIMITER ;


DELIMITER &&
CREATE PROCEDURE sp_delete_user(IN p_user_id INT)
BEGIN
    DELETE FROM USER
    WHERE user_id = p_user_id;
END &&
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_check_duplicate_email
BEFORE INSERT ON user
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM user
        WHERE email = NEW.email
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;
END$$
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE sp_deactivate_user(
    IN p_user_id INT
)
BEGIN
    UPDATE user
    SET status = 'Inactive'
    WHERE user_id = p_user_id;
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE sp_activate_user(
    IN p_user_id INT
)
BEGIN
    UPDATE user
    SET status = 'Active'
    WHERE user_id = p_user_id;
END &&
DELIMITER ;

-- 3. Profile Management Module
DELIMITER &&
CREATE PROCEDURE sp_update_profile_name(
IN p_user_id INT, 
IN p_name VARCHAR(100)
)
	BEGIN
		UPDATE USER SET name = p_name
		WHERE user_id = p_user_id;
	END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE sp_change_password(
IN p_user_id INT, 
IN p_new_password VARCHAR(255)
)
	BEGIN
		UPDATE USER
		SET password = p_new_password
		WHERE user_id = p_user_id;
	END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE sp_change_email(
    IN p_user_id INT,
    IN p_new_email VARCHAR(100)
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM user
        WHERE email = p_new_email
        AND user_id != p_user_id
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;
    UPDATE user
    SET email = p_new_email
    WHERE user_id = p_user_id;

END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE sp_login(
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE v_user_id INT DEFAULT NULL;
    DECLARE v_status VARCHAR(20) DEFAULT NULL;
    SELECT user_id, status
    INTO v_user_id, v_status
    FROM user
    WHERE email = p_email
      AND password = p_password
    LIMIT 1;
    IF v_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid credentials';
    ELSEIF v_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Account is inactive';
    ELSE
        INSERT INTO security_log(user_id, entry_time)
        VALUES (v_user_id, NOW());
    END IF;
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE sp_logout(
    IN p_user_id INT
)
BEGIN
    IF NOT EXISTS(
        SELECT 1
        FROM security_log
        WHERE user_id = p_user_id
        AND exit_time IS NULL
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No active session found';
    END IF;
    UPDATE security_log
    SET exit_time = NOW()
    WHERE user_id = p_user_id
    AND exit_time IS NULL;
    SELECT 'Logout Successful' AS message;
END &&
DELIMITER ;

CREATE VIEW v_profile_details AS
SELECT
    u.user_id,
    u.name,
    u.email,
    u.role_id,
    r.role_name,
    u.status
FROM user u
JOIN role r ON u.role_id = r.role_id;

-- 4. Ship Management Module
DELIMITER &&
CREATE PROCEDURE add_ship(
    IN p_ship_name VARCHAR(100),
    IN p_arrival_date DATETIME,
    IN p_departure_date DATETIME,
    IN p_status VARCHAR(50),
    IN p_operator_id INT
)
BEGIN
	INSERT INTO ship(
		ship_name,
		arrival_date,
		departure_date,
		status,
		operator_id
	)
	VALUES(
		p_ship_name,
		p_arrival_date,
		p_departure_date,
		 p_status,
		p_operator_id
	);
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE update_ship(
    IN p_ship_id INT,
    IN p_ship_name VARCHAR(100),
    IN p_arrival_date DATETIME,
    IN p_departure_date DATETIME,
    IN p_status VARCHAR(50)
)
BEGIN
		UPDATE ship
		SET
		ship_name =
			COALESCE(
			p_ship_name,
			ship_name
			),
		arrival_date =
			COALESCE(
			p_arrival_date,
			arrival_date
			),
		departure_date =
			COALESCE(
			p_departure_date,
			departure_date
			),
		status =
			COALESCE(
			p_status,
			status
			)
		WHERE ship_id = p_ship_id;
	END &&
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_delete_ship(
IN p_ship_id INT
)
BEGIN
	IF EXISTS(
		SELECT 1
		FROM dock_allocation
		WHERE ship_id = p_ship_id
		AND release_time IS NULL
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT =
		'Cannot delete ship with active dock allocation';
	END IF;
	IF EXISTS(
		SELECT 1
		FROM container
		WHERE ship_id = p_ship_id
	)
	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT =
		'Cannot delete ship with assigned containers';
	END IF;
	DELETE FROM ship
	WHERE ship_id = p_ship_id;

END$$
DELIMITER ;

DELIMITER &&
CREATE TRIGGER trg_ship_before_insert
BEFORE INSERT ON ship
FOR EACH ROW
BEGIN
    IF NEW.departure_date IS NOT NULL
    AND NEW.arrival_date IS NOT NULL
    AND NEW.departure_date <= NEW.arrival_date
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='Departure date must be after arrival date';
    END IF;
END &&
DELIMITER ;

DELIMITER &&
CREATE TRIGGER trg_ship_before_update
BEFORE UPDATE ON ship
FOR EACH ROW
BEGIN
    IF NEW.status = 'Departed' AND OLD.status != 'Departed'
    THEN
        IF EXISTS(
            SELECT 1 FROM dock_allocation
            WHERE ship_id = NEW.ship_id
            AND release_time IS NULL)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot mark ship as Departed until dock is released';
        END IF;
    END IF;
    IF NEW.departure_date IS NOT NULL
    AND NEW.arrival_date IS NOT NULL
    AND NEW.departure_date <= NEW.arrival_date
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='Departure date must be after arrival date';
    END IF;
END &&
DELIMITER ;

CREATE VIEW v_ship_details AS
SELECT
    s.ship_id,
    s.ship_name,
    s.arrival_date,
    s.departure_date,
    s.status,
    c.container_id,
    c.container_type,
    c.status AS container_status
FROM ship s
LEFT JOIN container c
ON s.ship_id = c.ship_id;

DELIMITER $$

CREATE PROCEDURE sp_search_ship(
IN p_ship_id INT,
IN p_ship_name VARCHAR(100),
IN p_status VARCHAR(50)
)
BEGIN
	SELECT
		ship_id,
		ship_name,
		operator_id,
		arrival_date,
		departure_date,
		status
	FROM ship
	WHERE(
		p_ship_id IS NULL
		OR ship_id = p_ship_id
	)
	AND
	(
		p_ship_name IS NULL
		OR ship_name LIKE CONCAT('%',p_ship_name,'%')
	)
	AND
	(
		p_status IS NULL
		OR status = p_status
	)
	ORDER BY arrival_date;
END$$
DELIMITER ;

-- 5. Dock Management Module 
DELIMITER &&
CREATE PROCEDURE add_dock(
    IN p_dock_name VARCHAR(100),
    IN p_status VARCHAR(50)
)
BEGIN
    INSERT INTO dock(
			dock_name,
			status
        )
    VALUES(
			p_dock_name, 
            p_status);
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE show_dock()
BEGIN
    SELECT * FROM dock;
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE update_dock(
    IN p_dock_id INT,
    IN p_dock_name VARCHAR(100),
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE dock
    SET
        dock_name = COALESCE(
						p_dock_name, 
                        dock_name),
        status = COALESCE(
						p_status, 
						status)
    WHERE dock_id = p_dock_id;

END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE delete_dock(
    IN p_dock_id INT
)
BEGIN
    IF NOT EXISTS(
        SELECT 1
        FROM dock
        WHERE dock_id = p_dock_id
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dock not found';
    END IF;
    DELETE FROM dock
    WHERE dock_id = p_dock_id;

END &&
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_search_dock(
    IN p_dock_name VARCHAR(100),
    IN p_status VARCHAR(50)
)
BEGIN
    SELECT
        dock_id,
        dock_name,
        status
    FROM dock
    WHERE
    (
        p_dock_name IS NULL
        OR dock_name LIKE CONCAT('%', p_dock_name, '%')
    )
    AND
    (
        p_status IS NULL
        OR status = p_status
    )
    ORDER BY dock_name;
END$$
DELIMITER ;

-- 6. Dock Allocation Module
DELIMITER $$
CREATE TRIGGER trg_check_dock_before_allocate
BEFORE INSERT ON dock_allocation
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(50);
    SELECT status INTO v_status
    FROM dock
    WHERE dock_id = NEW.dock_id;
    IF v_status = 'Occupied' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dock is already occupied.';
    END IF;
    IF v_status = 'Under Maintenance' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dock is under maintenance.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_mark_dock_occupied
AFTER INSERT ON dock_allocation
FOR EACH ROW
BEGIN
    UPDATE dock
    SET status = 'Occupied'
    WHERE dock_id = NEW.dock_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE allocate_dock(
IN p_ship_id INT,
IN p_dock_id INT,
IN p_allocation_time DATETIME,
IN p_release_time DATETIME
)
BEGIN
INSERT INTO dock_allocation (
ship_id,
dock_id,
allocation_time,
release_time
)
VALUES (
p_ship_id,
p_dock_id,
p_allocation_time,
p_release_time
);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE release_dock(
IN p_allocation_id INT
)
BEGIN
DECLARE v_dock_id INT;
SELECT dock_id INTO v_dock_id
FROM dock_allocation
WHERE allocation_id = p_allocation_id;
UPDATE dock_allocation
SET release_time = NOW()
WHERE allocation_id = p_allocation_id;
UPDATE dock
SET status = 'Available'
WHERE dock_id = v_dock_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_allocation(
    IN p_allocation_id INT,
    IN p_new_dock_id INT
)
BEGIN
    DECLARE v_old_dock_id INT;
    DECLARE v_new_dock_status VARCHAR(50);
    SELECT dock_id INTO v_old_dock_id
    FROM dock_allocation
    WHERE allocation_id = p_allocation_id;
    SELECT status INTO v_new_dock_status
    FROM dock
    WHERE dock_id = p_new_dock_id;
    IF v_new_dock_status = 'Occupied' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'New dock is already occupied.';
    END IF;
    IF v_new_dock_status = 'Under Maintenance' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'New dock is under maintenance.';
    END IF;
    UPDATE dock_allocation
    SET dock_id = p_new_dock_id
    WHERE allocation_id = p_allocation_id;
    UPDATE dock
    SET status = 'Available'
    WHERE dock_id = v_old_dock_id;
    UPDATE dock
    SET status = 'Occupied'
    WHERE dock_id = p_new_dock_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_allocation(
    IN p_allocation_id INT
)
BEGIN
    DECLARE v_dock_id INT;
    DECLARE v_is_active INT DEFAULT 0;
    SELECT da.dock_id,
           CASE
               WHEN da.allocation_id = (
                   SELECT MAX(da2.allocation_id)
                   FROM dock_allocation da2
                   WHERE da2.dock_id = da.dock_id
               )
               THEN 1
               ELSE 0
           END
    INTO v_dock_id, v_is_active
    FROM dock_allocation da
    WHERE da.allocation_id = p_allocation_id;
    DELETE FROM dock_allocation
    WHERE allocation_id = p_allocation_id;
    IF v_is_active = 1 THEN
        UPDATE dock
        SET status = 'Available'
        WHERE dock_id = v_dock_id;
    END IF;
END$$
DELIMITER ;

CREATE OR REPLACE VIEW vw_available_ships AS
SELECT 
    ship_id,
    ship_name,
    operator_id,
    arrival_date,
    departure_date,
    status
FROM ship
WHERE status = 'Anchored';

CREATE OR REPLACE VIEW vw_available_docks AS
SELECT
    dock_id,
    dock_name,
    status
FROM dock
WHERE status = 'Available';

CREATE OR REPLACE VIEW vw_active_dock_allocations AS
SELECT
    da.allocation_id,
    da.ship_id,
    s.ship_name,
    da.dock_id,
    d.dock_name,
    da.allocation_time,
    da.release_time,
    d.status
FROM dock_allocation da
JOIN dock d ON da.dock_id = d.dock_id
JOIN ship s ON da.ship_id = s.ship_id
WHERE d.status = 'Occupied'
  AND da.allocation_id = (
      SELECT MAX(da2.allocation_id)
      FROM dock_allocation da2
      WHERE da2.dock_id = da.dock_id
  );
  
CREATE OR REPLACE VIEW vw_all_dock_allocations AS
SELECT
    da.allocation_id,
    da.ship_id,
    s.ship_name,
    da.dock_id,
    d.dock_name,
    da.allocation_time,
    da.release_time,
    CASE
        WHEN d.status = 'Occupied'
         AND da.allocation_id = (
             SELECT MAX(da2.allocation_id)
             FROM dock_allocation da2
             WHERE da2.dock_id = da.dock_id
         )
        THEN 'Active'
        ELSE 'Released'
    END AS status
FROM dock_allocation da
JOIN ship s ON da.ship_id = s.ship_id
JOIN dock d ON da.dock_id = d.dock_id;

DELIMITER $$
CREATE PROCEDURE search_all_allocations(
    IN p_search VARCHAR(100),
    IN p_statusFilter VARCHAR(20)
)
BEGIN
    SELECT
        allocation_id,
        ship_id,
        ship_name,
        dock_id,
        dock_name,
        allocation_time,
        release_time,
        status
    FROM vw_all_dock_allocations
    WHERE
        (
            IFNULL(TRIM(p_search), '') = ''
            OR CAST(dock_id AS CHAR) = TRIM(p_search)
            OR dock_name LIKE CONCAT('%', TRIM(p_search), '%')
            OR ship_name LIKE CONCAT('%', TRIM(p_search), '%')
        )
        AND
        (
            IFNULL(TRIM(p_statusFilter), '') = ''
            OR p_statusFilter = 'All'
            OR status = p_statusFilter
        )
    ORDER BY allocation_time DESC, allocation_id DESC;
END$$
DELIMITER ;

-- 7. Container Management Module
DELIMITER &&
CREATE PROCEDURE add_container(
    IN p_container_type VARCHAR(50),
    IN p_status VARCHAR(50),
    IN p_ship_id INT
)
BEGIN
	INSERT INTO container(
		container_type,
		status,
		ship_id
	)
	VALUES(
		p_container_type,
		p_status,
		p_ship_id
	);
END &&
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_container(IN p_container_id INT, IN p_container_type VARCHAR(50), IN p_status VARCHAR(50), IN p_ship_id INT)
BEGIN
    UPDATE container
    SET container_type = COALESCE(p_container_type, container_type),
        status         = COALESCE(p_status,         status),
        ship_id        = COALESCE(p_ship_id,        ship_id)
    WHERE container_id = p_container_id;
END$$
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE delete_container(
    IN p_container_id INT
)
BEGIN
	DELETE FROM container
	WHERE container_id = p_container_id;
END &&
DELIMITER ;

DROP VIEW IF EXISTS v_container_details;

CREATE VIEW v_container_details AS
SELECT
    c.container_id,
    c.container_type,
    c.status AS container_status,
    c.ship_id,
    s.ship_name,
    cg.cargo_id,
    cg.description AS cargo_description,
    cg.weight,
    cg.status AS cargo_status
FROM container c
JOIN ship s
    ON c.ship_id = s.ship_id
LEFT JOIN cargo cg
    ON c.container_id = cg.container_id;

DELIMITER &&
CREATE PROCEDURE show_containers()
BEGIN
    SELECT * FROM v_container_details;
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE search_container(
    IN p_container_id   INT,
    IN p_container_type VARCHAR(50),
    IN p_status         VARCHAR(50),
    IN p_ship_name VARCHAR(100)
)
BEGIN
    SELECT *
    FROM v_container_details
    WHERE
        (p_container_id   IS NULL 
			OR container_id   = p_container_id)
    AND (p_container_type IS NULL 
		OR container_type = p_container_type)
    AND (p_status         IS NULL 
		OR container_status = p_status)
    AND (p_ship_name      IS NULL 
		OR ship_name = p_ship_name);
END &&
DELIMITER ;

-- 8. Cargo Handling (Cargo and Cargo Movement)
CREATE INDEX idx_cargo_description
ON cargo(description);

CREATE INDEX idx_cargo_status
ON cargo(status);

CREATE INDEX idx_ship_name
ON ship(ship_name);

DELIMITER &&
CREATE PROCEDURE add_cargo(
    IN p_container_id INT,
    IN p_description VARCHAR(200),
    IN p_weight DECIMAL(10,2),
    IN p_status VARCHAR(50)
)
BEGIN
    INSERT INTO cargo(
		container_id, 
		description, 
		weight, 
		status
    )
    VALUES(
		p_container_id, 
		p_description, 
		p_weight, 
		p_status
    );
    
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE log_cargo_movement(
    IN p_cargo_id INT,
    IN p_movement_type VARCHAR(50),
    IN p_handled_by INT
)
BEGIN
    INSERT INTO cargo_movement(
        cargo_id,
        movement_type,
        movement_date,
        handled_by
    )
    VALUES(
        p_cargo_id,
        p_movement_type,
        NOW(),
        p_handled_by
    );
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE update_cargo(
    IN p_cargo_id INT,
    IN p_description VARCHAR(200),
    IN p_weight DECIMAL(10,2),
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE cargo
    SET
        description =
            COALESCE(
                p_description,
                description
            ),
        weight =
            COALESCE(
                p_weight,
                weight
            ),
        status =
            COALESCE(
                p_status,
                status
            )
    WHERE cargo_id = p_cargo_id;
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE delete_cargo(
    IN p_cargo_id INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM cargo
        WHERE cargo_id = p_cargo_id
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cargo ID does not exist';
    END IF;
    DELETE FROM cargo_movement
    WHERE cargo_id = p_cargo_id;
    DELETE FROM cargo
    WHERE cargo_id = p_cargo_id;
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE search_cargo(
    IN p_keyword VARCHAR(200)
)
BEGIN
    SELECT
        c.cargo_id,
        c.description,
        c.weight,
        c.status AS cargo_status,
        ct.container_id,
        ct.container_type,
        s.ship_name
    FROM cargo c
    JOIN container ct
        ON c.container_id = ct.container_id
    JOIN ship s
        ON ct.ship_id = s.ship_id
    WHERE
        CAST(c.cargo_id AS CHAR) LIKE CONCAT('%', p_keyword, '%')
        OR c.description LIKE CONCAT('%', p_keyword, '%');
END &&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE get_cargo_history(
    IN p_cargo_id INT
)
BEGIN
    SELECT
        cm.movement_id,
        c.description AS cargo_description,
        cm.movement_type,
        cm.movement_date,
        u.name AS cargo_handler
    FROM cargo_movement cm
    JOIN cargo c
        ON cm.cargo_id = c.cargo_id
    JOIN user u
        ON cm.handled_by = u.user_id
    WHERE cm.cargo_id = p_cargo_id
    ORDER BY cm.movement_date DESC;
END &&
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_update_movement_after_cargo_status
AFTER UPDATE ON cargo
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO cargo_movement(
            cargo_id,
            movement_type,
            movement_date,
            handled_by
        )
        VALUES(
            NEW.cargo_id,
            CASE
                WHEN NEW.status = 'Loaded' THEN 'Load'
                WHEN NEW.status = 'Unloaded' THEN 'Unload'
                WHEN NEW.status = 'In Transit' THEN 'Transfer'
            END,
            NOW(),
            5
        );
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_validate_cargo_weight
BEFORE INSERT ON cargo
FOR EACH ROW
BEGIN
    IF NEW.weight <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cargo weight must be greater than zero';
    END IF;
END $$
DELIMITER ;

CREATE VIEW vw_cargo_details AS
SELECT
    c.cargo_id,
    c.description,
    c.weight,
    c.status AS cargo_status,
    ct.container_id,
    ct.container_type,
    s.ship_name
FROM cargo c
JOIN container ct
    ON c.container_id = ct.container_id
JOIN ship s
    ON ct.ship_id = s.ship_id;

CREATE VIEW vw_cargo_movement_history AS
SELECT
    cm.movement_id,
    c.description AS cargo_description,
    cm.movement_type,
    cm.movement_date,
    u.name AS handled_by
FROM cargo_movement cm
JOIN cargo c
    ON cm.cargo_id = c.cargo_id
JOIN user u
    ON cm.handled_by = u.user_id;

CREATE VIEW vw_container_cargo_summary AS
SELECT
    ct.container_id,
    ct.container_type,
    COUNT(c.cargo_id) AS total_cargo_items
FROM container ct
LEFT JOIN cargo c
    ON ct.container_id = c.container_id
GROUP BY ct.container_id, ct.container_type;

CREATE VIEW vw_pending_cargo_movements AS
SELECT
    c.cargo_id,
    c.description,
    c.status,
    ct.container_id,
    s.ship_name
FROM cargo c
JOIN container ct
    ON c.container_id = ct.container_id
JOIN ship s
    ON ct.ship_id = s.ship_id
WHERE c.status != 'Unloaded';

-- 9. Security Log Module 
delimiter &&
create trigger trg_seclog_no_delete
Before delete
on security_log
For each row
begin
	signal sqlstate '45000'
    set message_text = 'Security logs cannot be deleted';
end &&
delimiter ;

delimiter &&
create trigger trg_seclog_protect_update
before update
on security_log
for each row
begin
	if not(
		OLD.exit_time IS NULL
        AND NEW.exit_time IS NOT NULL
        AND OLD.user_id = NEW.user_id
        AND OLD.entry_time = NEW.entry_time
    )
    then
		signal sqlstate '45000'
        set message_text = 'Security logs are read-only';
	end if;
end &&
delimiter ;

CREATE VIEW v_security_log AS
	SELECT
		sl.log_id,
		u.name AS username,
		sl.user_id,
		r.role_name,
		sl.entry_time,
		sl.exit_time,
		TIMESTAMPDIFF(
			MINUTE,
			sl.entry_time,
			sl.exit_time
		) AS session_duration
	FROM security_log sl
	JOIN user u
	ON sl.user_id = u.user_id
	JOIN role r
	ON u.role_id = r.role_id;

delimiter &&
create procedure sp_session_open(
	IN p_user_id int,
    OUT p_log_id int
)
begin
	insert into security_log (user_id,entry_time) values (p_user_id,now());		
    set p_log_id = last_insert_id();
end &&
delimiter ;

delimiter &&
create procedure sp_session_close(
	IN p_log_id int
)
begin
	if not exists(
    select 1
    from security_log
    where log_id = p_log_id
    and exit_time is null
)
then
	signal sqlstate '45000'
    set message_text = 'Session not found or already closed';
    end if;
    update security_log
    set exit_time = now()
    where log_id = p_log_id;
end &&
delimiter ;

delimiter &&
create procedure sp_get_security_log(
	IN p_user_id int,
    IN p_date_from date,
    In p_date_to date
)
begin
	select * from v_security_log 
	where 
		(p_user_id is null OR user_id = p_user_id)
	AND
		(p_date_from is null OR date(entry_time) >= p_date_from)
	 AND
		(p_date_to is null OR date(entry_time) <= p_date_to)
	 order by entry_time desc;
 end &&
 delimiter ;

 INSERT INTO roles (role_id, role_name) VALUES
(1, 'Admin'),
(2, 'Port Manager'),
(3, 'Ship Operator'),
(4, 'Dock Manager'),
(5, 'Cargo Handler');
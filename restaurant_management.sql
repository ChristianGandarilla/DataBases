-- ============================================================
--  DATABASE SCHEMA - Restaurant Management System
--  Includes: Tables, Triggers (Audit Log), Sample Queries
-- ============================================================

-- ============================================================
--  ROLES
-- ============================================================
CREATE TABLE roles (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  BRANCHES
-- ============================================================
CREATE TABLE branches (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    address    VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    email      VARCHAR(100),
    active     BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  AREAS
-- ============================================================
CREATE TABLE areas (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    branch_id   INT NOT NULL,
    capacity    INT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- ============================================================
--  TABLES
-- ============================================================
CREATE TABLE tables (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    number     INT NOT NULL,
    capacity   INT NOT NULL,
    area_id    INT NOT NULL,
    status     ENUM('available', 'occupied', 'reserved', 'maintenance') DEFAULT 'available',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_id) REFERENCES areas(id),
    UNIQUE (number, area_id)
);

-- ============================================================
--  SUPPLIERS
-- ============================================================
CREATE TABLE suppliers (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(150) NOT NULL,
    contact    VARCHAR(100),
    phone      VARCHAR(20),
    email      VARCHAR(100),
    address    VARCHAR(255),
    tax_id     VARCHAR(20),
    active     BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  EMPLOYEES
-- ============================================================
CREATE TABLE employees (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) UNIQUE,
    phone        VARCHAR(20),
    position     VARCHAR(100),
    branch_id    INT NOT NULL,
    role_id      INT NOT NULL,
    hire_date    DATE,
    active       BOOLEAN DEFAULT TRUE,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(id),
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- ============================================================
--  ADMINISTRATORS
-- ============================================================
CREATE TABLE administrators (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    role_id      INT NOT NULL,
    branch_id    INT,                           -- NULL = global access
    active       BOOLEAN DEFAULT TRUE,
    last_login   DATETIME,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- ============================================================
--  CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    phone       VARCHAR(20),
    birth_date  DATE,
    notes       TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  MENU
-- ============================================================
CREATE TABLE menu (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    description TEXT,
    price       DECIMAL(10, 2) NOT NULL,
    category    VARCHAR(100),
    available   BOOLEAN DEFAULT TRUE,
    image_url   VARCHAR(255),
    branch_id   INT,                           -- NULL = applies to all branches
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES branches(id)
);

-- ============================================================
--  RESERVATIONS
-- ============================================================
CREATE TABLE reservations (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    customer_id  INT NOT NULL,
    table_id     INT NOT NULL,
    employee_id  INT,                          -- who took the reservation
    scheduled_at DATETIME NOT NULL,
    guests       INT NOT NULL DEFAULT 1,
    status       ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    notes        TEXT,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (table_id) REFERENCES tables(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- ============================================================
--  AUDIT_LOG
-- ============================================================
CREATE TABLE audit_log (
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    date       DATETIME DEFAULT CURRENT_TIMESTAMP,
    user       VARCHAR(150),                   -- user who performed the action
    `table`    VARCHAR(100) NOT NULL,          -- affected table
    operation  ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    record_id  INT,                            -- id of the affected record
    old_data   JSON,                           -- data before the change
    new_data   JSON                            -- data after the change
);

-- ============================================================
--  SAMPLE DATA - INSERT STATEMENTS
-- ============================================================

-- ---- ROLES ----
INSERT INTO roles (name, description) VALUES
('Admin',    'Full system access across all branches'),
('Manager',  'Branch-level management and reporting'),
('Waiter',   'Table service and order management'),
('Host',     'Reservations and customer reception'),
('Chef',     'Kitchen and menu management'),
('Supplier', 'External supplier contact role');

-- ---- BRANCHES ----
INSERT INTO branches (name, address, phone, email, active) VALUES
('Downtown',    '123 Main St, New York, NY 10001',       '(212) 555-0101', 'downtown@restaurant.com',    TRUE),
('Midtown',     '456 Park Ave, New York, NY 10022',      '(212) 555-0202', 'midtown@restaurant.com',     TRUE),
('Brooklyn',    '789 Atlantic Ave, Brooklyn, NY 11217',  '(718) 555-0303', 'brooklyn@restaurant.com',    TRUE);

-- ---- AREAS ----
INSERT INTO areas (name, description, branch_id, capacity) VALUES
('Main Hall',   'Central dining area',          1, 80),
('Terrace',     'Outdoor rooftop seating',      1, 40),
('Bar',         'Bar and lounge area',          1, 20),
('Main Hall',   'Central dining area',          2, 60),
('Private Room','VIP and event dining',         2, 30),
('Main Hall',   'Central dining area',          3, 50),
('Garden',      'Outdoor garden seating',       3, 35);

-- ---- TABLES ----
INSERT INTO tables (number, capacity, area_id, status) VALUES
(1,  4, 1, 'available'),
(2,  4, 1, 'occupied'),
(3,  6, 1, 'reserved'),
(4,  2, 1, 'available'),
(5,  8, 1, 'available'),
(6,  4, 2, 'available'),
(7,  4, 2, 'available'),
(8,  2, 3, 'occupied'),
(1,  4, 4, 'available'),
(2,  6, 4, 'available'),
(3,  4, 4, 'maintenance'),
(1, 10, 5, 'available'),
(1,  4, 6, 'available'),
(2,  4, 6, 'occupied'),
(1,  6, 7, 'available');

-- ---- SUPPLIERS ----
INSERT INTO suppliers (name, contact, phone, email, address, tax_id, active) VALUES
('Fresh Farms Co.',     'John Carter',   '(800) 555-1001', 'john@freshfarms.com',    '10 Farm Rd, NJ 07001',          'FF-123456', TRUE),
('Ocean Select',        'Maria Lopez',   '(800) 555-1002', 'maria@oceanselect.com',  '5 Harbor Blvd, NY 10004',       'OS-234567', TRUE),
('Prime Cuts Meats',    'David Kim',     '(800) 555-1003', 'david@primecuts.com',    '88 Butcher St, NY 11201',       'PC-345678', TRUE),
('Harvest Vineyards',   'Sarah Chen',    '(800) 555-1004', 'sarah@harvestwines.com', '200 Vineyard Way, CA 94558',    'HV-456789', TRUE),
('Artisan Bakery',      'Tom Brown',     '(800) 555-1005', 'tom@artisanbakery.com',  '33 Bread Ln, NY 10012',         'AB-567890', FALSE);

-- ---- EMPLOYEES ----
INSERT INTO employees (first_name, last_name, email, phone, position, branch_id, role_id, hire_date, active) VALUES
('James',   'Miller',   'james.miller@restaurant.com',   '(212) 555-2001', 'Head Waiter',   1, 3, '2021-03-15', TRUE),
('Laura',   'Smith',    'laura.smith@restaurant.com',    '(212) 555-2002', 'Host',          1, 4, '2022-06-01', TRUE),
('Carlos',  'Rivera',   'carlos.rivera@restaurant.com',  '(212) 555-2003', 'Chef',          1, 5, '2020-01-10', TRUE),
('Emma',    'Johnson',  'emma.johnson@restaurant.com',   '(212) 555-2004', 'Waiter',        2, 3, '2023-02-20', TRUE),
('Noah',    'Williams', 'noah.williams@restaurant.com',  '(718) 555-2005', 'Host',          2, 4, '2022-09-05', TRUE),
('Olivia',  'Davis',    'olivia.davis@restaurant.com',   '(718) 555-2006', 'Waiter',        3, 3, '2023-07-14', TRUE),
('Liam',    'Garcia',   'liam.garcia@restaurant.com',    '(718) 555-2007', 'Chef',          3, 5, '2021-11-30', TRUE);

-- ---- ADMINISTRATORS ----
INSERT INTO administrators (first_name, last_name, email, password, role_id, branch_id, active) VALUES
('Alice',   'Thompson', 'alice@restaurant.com',          '$2b$12$hashed_password_1', 1, NULL, TRUE),
('Bob',     'Martinez', 'bob.downtown@restaurant.com',   '$2b$12$hashed_password_2', 2, 1,    TRUE),
('Cathy',   'Lee',      'cathy.midtown@restaurant.com',  '$2b$12$hashed_password_3', 2, 2,    TRUE),
('Derek',   'Wilson',   'derek.brooklyn@restaurant.com', '$2b$12$hashed_password_4', 2, 3,    TRUE);

-- ---- CUSTOMERS ----
INSERT INTO customers (first_name, last_name, email, phone, birth_date, notes) VALUES
('Michael', 'Scott',    'michael.scott@email.com',   '(646) 555-3001', '1985-03-15', 'Prefers window tables'),
('Pam',     'Beesly',   'pam.beesly@email.com',      '(646) 555-3002', '1990-07-22', 'Vegetarian'),
('Jim',     'Halpert',  'jim.halpert@email.com',      '(646) 555-3003', '1988-10-01', NULL),
('Dwight',  'Schrute',  'dwight.schrute@email.com',   '(646) 555-3004', '1978-01-20', 'Allergic to shellfish'),
('Angela',  'Martin',   'angela.martin@email.com',    '(646) 555-3005', '1983-11-11', 'Prefers quiet areas'),
('Kevin',   'Malone',   'kevin.malone@email.com',     '(646) 555-3006', '1975-06-01', NULL),
('Kelly',   'Kapoor',   'kelly.kapoor@email.com',     '(646) 555-3007', '1992-02-05', 'Birthday in February'),
('Ryan',    'Howard',   'ryan.howard@email.com',      '(646) 555-3008', '1991-05-17', NULL);

-- ---- MENU ----
INSERT INTO menu (name, description, price, category, available, branch_id) VALUES
('Caesar Salad',        'Romaine lettuce, croutons, parmesan, caesar dressing',  12.50, 'Starters',  TRUE, NULL),
('Tomato Soup',         'Roasted tomato with basil cream',                        9.00, 'Starters',  TRUE, NULL),
('Grilled Salmon',      'Atlantic salmon with lemon butter and seasonal veggies', 28.00, 'Main',     TRUE, NULL),
('Ribeye Steak',        '12oz ribeye, mashed potatoes, grilled asparagus',       45.00, 'Main',      TRUE, NULL),
('Margherita Pizza',    'Tomato, fresh mozzarella, basil',                        16.00, 'Main',     TRUE, NULL),
('Pasta Carbonara',     'Spaghetti, pancetta, egg, parmesan, black pepper',       18.00, 'Main',     TRUE, NULL),
('Veggie Burger',       'Black bean patty, avocado, lettuce, tomato',             14.00, 'Main',     TRUE, NULL),
('Chocolate Lava Cake', 'Warm chocolate cake with vanilla ice cream',             10.00, 'Desserts', TRUE, NULL),
('Cheesecake',          'New York style with berry compote',                       9.00, 'Desserts', TRUE, NULL),
('Craft Lemonade',      'Freshly squeezed with mint',                              5.00, 'Drinks',  TRUE, NULL),
('House Red Wine',      'Cabernet Sauvignon, glass',                              11.00, 'Drinks',   TRUE, NULL),
('Truffle Fries',       'Shoestring fries with truffle oil and parmesan',         13.00, 'Starters', TRUE, 1),
('Lobster Bisque',      'Creamy lobster soup with cognac',                        18.00, 'Starters', TRUE, 2);

-- ---- RESERVATIONS ----
INSERT INTO reservations (customer_id, table_id, employee_id, scheduled_at, guests, status, notes) VALUES
(1, 3,  2, '2026-03-04 19:00:00', 4, 'confirmed',  'Anniversary dinner, please prepare a small dessert'),
(2, 6,  2, '2026-03-04 20:00:00', 2, 'confirmed',  'Vegetarian menu requested'),
(3, 9,  5, '2026-03-04 21:00:00', 3, 'pending',    NULL),
(4, 1,  2, '2026-03-05 12:30:00', 2, 'confirmed',  'No shellfish in any dish'),
(5, 7,  2, '2026-03-05 19:30:00', 5, 'pending',    'Quiet area preferred'),
(6, 10, 5, '2026-03-05 20:00:00', 6, 'confirmed',  NULL),
(7, 13, 6, '2026-03-06 19:00:00', 2, 'pending',    'Birthday celebration'),
(8, 4,  2, '2026-03-06 20:30:00', 1, 'cancelled',  'Customer cancelled via phone'),
(1, 11, 5, '2026-03-07 13:00:00', 4, 'confirmed',  NULL),
(3, 15, 6, '2026-03-07 19:00:00', 3, 'pending',    NULL);
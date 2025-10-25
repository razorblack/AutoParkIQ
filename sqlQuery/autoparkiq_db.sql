-- Creating scheme 
CREATE SCHEMA IF NOT EXISTS autoparkiq_db;
USE autoparkiq_db;

-- Parking Lots Table
CREATE TABLE IF NOT EXISTS parking_lots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    total_floors INT NOT NULL,
    total_spots INT NOT NULL,
    hourly_rate DECIMAL(10, 2) NOT NULL,
    daily_rate DECIMAL(10, 2),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    operating_hours VARCHAR(50),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version BIGINT DEFAULT 0,
    INDEX idx_parking_lot_name (name),
    INDEX idx_parking_lot_status (is_active)
);

-- Parking Floors Table
CREATE TABLE IF NOT EXISTS parking_floors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    parking_lot_id BIGINT NOT NULL,
    floor_number INT NOT NULL,
    floor_name VARCHAR(50),
    total_spots INT NOT NULL,
    motorcycle_spots INT,
    car_spots INT,
    large_spots INT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (parking_lot_id) REFERENCES parking_lots(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_parking_lot_floor (parking_lot_id, floor_number),
    INDEX idx_floor_number (floor_number)
);

-- Parking Spots Table
CREATE TABLE IF NOT EXISTS parking_spots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    parking_floor_id BIGINT NOT NULL,
    spot_number VARCHAR(10) NOT NULL,
    spot_type ENUM('MOTORCYCLE', 'CAR', 'LARGE') NOT NULL,
    spot_status ENUM('AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'RESERVED') NOT NULL DEFAULT 'AVAILABLE',
    location_x DOUBLE,
    location_y DOUBLE,
    is_handicap_accessible BOOLEAN DEFAULT FALSE,
    is_electric_charging BOOLEAN DEFAULT FALSE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (parking_floor_id) REFERENCES parking_floors(id) ON DELETE CASCADE,
    UNIQUE INDEX idx_floor_spot (parking_floor_id, spot_number),
    INDEX idx_spot_type_status (spot_type, spot_status),
    INDEX idx_spot_status (spot_status)
);

-- Vehicles Table
CREATE TABLE IF NOT EXISTS vehicles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('MOTORCYCLE', 'CAR', 'BUS') NOT NULL,
    owner_name VARCHAR(100),
    owner_phone VARCHAR(20),
    owner_email VARCHAR(100),
    color VARCHAR(30),
    model VARCHAR(50),
    manufacturer VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version BIGINT DEFAULT 0,
    UNIQUE INDEX idx_license_plate (license_plate),
    INDEX idx_vehicle_type (vehicle_type)
);

-- Parking Tickets Table
CREATE TABLE IF NOT EXISTS parking_tickets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_id BIGINT NOT NULL,
    parking_spot_id BIGINT NOT NULL,
    entry_time TIMESTAMP NOT NULL,
    exit_time TIMESTAMP NULL,
    ticket_status ENUM('ACTIVE', 'PAYMENT_PENDING', 'PAID', 'CANCELLED', 'EXPIRED') NOT NULL DEFAULT 'ACTIVE',
    hourly_rate DECIMAL(10, 2) NOT NULL,
    total_fee DECIMAL(10, 2),
    paid_amount DECIMAL(10, 2),
    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (parking_spot_id) REFERENCES parking_spots(id),
    INDEX idx_vehicle_ticket (vehicle_id),
    INDEX idx_spot_ticket (parking_spot_id),
    INDEX idx_ticket_status (ticket_status),
    INDEX idx_entry_time (entry_time),
    UNIQUE INDEX idx_ticket_number (ticket_number)
);

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    parking_ticket_id BIGINT NOT NULL,
    transaction_id VARCHAR(50) NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'DIGITAL_WALLET', 'BANK_TRANSFER') NOT NULL,
    payment_status ENUM('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    payment_time TIMESTAMP NULL,
    gateway_transaction_id VARCHAR(100),
    gateway_response VARCHAR(500),
    receipt_number VARCHAR(50),
    notes VARCHAR(500),
    refund_amount DECIMAL(10, 2),
    refund_time TIMESTAMP NULL,
    refund_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    version BIGINT DEFAULT 0,
    FOREIGN KEY (parking_ticket_id) REFERENCES parking_tickets(id),
    INDEX idx_ticket_payment (parking_ticket_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_time (payment_time),
    UNIQUE INDEX idx_transaction_id (transaction_id)
);

-- Sample Data Insertion

-- Insert sample parking lot
INSERT INTO parking_lots (name, address, city, state, total_floors, total_spots, hourly_rate, daily_rate, operating_hours) 
VALUES 
('Downtown Parking Complex', '123 Main Street', 'Springfield', 'IL', 5, 500, 5.00, 40.00, '24/7'),
('Shopping Mall Parking', '456 Commerce Blvd', 'Springfield', 'IL', 3, 300, 3.00, 25.00, '6:00 AM - 11:00 PM');

-- Insert sample parking floors
INSERT INTO parking_floors (parking_lot_id, floor_number, floor_name, total_spots, motorcycle_spots, car_spots, large_spots) 
VALUES 
(1, 1, 'Ground Floor', 100, 20, 70, 10),
(1, 2, 'Second Floor', 100, 15, 75, 10),
(1, 3, 'Third Floor', 100, 15, 75, 10),
(1, 4, 'Fourth Floor', 100, 15, 75, 10),
(1, 5, 'Fifth Floor', 100, 15, 75, 10),
(2, 1, 'Level 1', 100, 25, 65, 10),
(2, 2, 'Level 2', 100, 20, 70, 10),
(2, 3, 'Level 3', 100, 20, 70, 10);

-- Insert sample parking spots for Ground Floor of Downtown Complex
INSERT INTO parking_spots (parking_floor_id, spot_number, spot_type, location_x, location_y, is_handicap_accessible, is_electric_charging) 
VALUES 
-- Motorcycle spots
(1, 'M001', 'MOTORCYCLE', 10.0, 10.0, FALSE, FALSE),
(1, 'M002', 'MOTORCYCLE', 12.0, 10.0, FALSE, FALSE),
(1, 'M003', 'MOTORCYCLE', 14.0, 10.0, FALSE, FALSE),
(1, 'M004', 'MOTORCYCLE', 16.0, 10.0, FALSE, FALSE),
(1, 'M005', 'MOTORCYCLE', 18.0, 10.0, FALSE, FALSE),
-- Car spots
(1, 'C001', 'CAR', 20.0, 10.0, TRUE, FALSE),
(1, 'C002', 'CAR', 25.0, 10.0, FALSE, TRUE),
(1, 'C003', 'CAR', 30.0, 10.0, FALSE, FALSE),
(1, 'C004', 'CAR', 35.0, 10.0, FALSE, FALSE),
(1, 'C005', 'CAR', 40.0, 10.0, FALSE, TRUE),
-- Large spots
(1, 'L001', 'LARGE', 50.0, 10.0, FALSE, FALSE),
(1, 'L002', 'LARGE', 60.0, 10.0, FALSE, FALSE),
(1, 'L003', 'LARGE', 70.0, 10.0, FALSE, FALSE);


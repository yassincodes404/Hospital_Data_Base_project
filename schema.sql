-- =========================
-- DATABASE
-- =========================
DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE IF NOT EXISTS hospital_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE hospital_db;

-- =========================
-- TABLE: departments
-- =========================
CREATE TABLE IF NOT EXISTS departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================
-- TABLE: doctors
-- =========================
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    department_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_doctor_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_doctor_department ON doctors(department_id);

-- =========================
-- TABLE: patients
-- =========================
CREATE TABLE IF NOT EXISTS patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender ENUM('Male','Female') NOT NULL,
    birth_date DATE,
    phone VARCHAR(20) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================
-- TABLE: rooms
-- =========================
CREATE TABLE IF NOT EXISTS rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    type ENUM('Single','Double','ICU') NOT NULL,
    status ENUM('Available','Occupied') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================
-- TABLE: patient_rooms (history tracking)
-- =========================
CREATE TABLE IF NOT EXISTS patient_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,

    CONSTRAINT fk_pr_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_pr_room
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_dates CHECK (discharge_date IS NULL OR discharge_date >= admission_date)
) ENGINE=InnoDB;

CREATE INDEX idx_pr_patient ON patient_rooms(patient_id);
CREATE INDEX idx_pr_room ON patient_rooms(room_id);

-- =========================
-- TABLE: medical_records
-- =========================
CREATE TABLE IF NOT EXISTS medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    diagnosis TEXT NOT NULL,
    notes TEXT,
    record_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_mr_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_mr_patient ON medical_records(patient_id);

-- =========================
-- TABLE: appointments
-- =========================
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_app_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_app_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_app_patient ON appointments(patient_id);
CREATE INDEX idx_app_doctor ON appointments(doctor_id);
CREATE INDEX idx_app_date ON appointments(appointment_date);

-- =========================
-- TABLE: treatments
-- =========================
CREATE TABLE IF NOT EXISTS treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    description TEXT NOT NULL,
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),

    CONSTRAINT fk_treatment_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_treatment_app ON treatments(appointment_id);

-- =========================
-- TABLE: bills
-- =========================
CREATE TABLE IF NOT EXISTS bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    payment_status ENUM('Paid','Unpaid') DEFAULT 'Unpaid',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_bill_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================
-- OPTIONAL: SAFE SEED DATA
-- =========================
INSERT IGNORE INTO departments (name) VALUES
('Cardiology'),
('Neurology'),
('Orthopedics');

INSERT IGNORE INTO rooms (room_number, type) VALUES
('101', 'Single'),
('102', 'Double'),
('ICU1', 'ICU');

-- =========================
-- TRIGGERS AND PROCEDURES
-- =========================
DELIMITER $$

CREATE PROCEDURE sp_generate_bill (
    IN p_appointment_id INT
)
BEGIN
    DECLARE total DECIMAL(10,2);

    -- Calculate total
    SELECT IFNULL(SUM(cost), 0)
    INTO total
    FROM treatments
    WHERE appointment_id = p_appointment_id;

    -- Insert or update bill
    INSERT INTO bills (appointment_id, total_amount)
    VALUES (p_appointment_id, total)
    ON DUPLICATE KEY UPDATE
        total_amount = total;

END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_after_treatment_insert
AFTER INSERT ON treatments
FOR EACH ROW
BEGIN
    CALL sp_generate_bill(NEW.appointment_id);
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_after_patient_room_insert
AFTER INSERT ON patient_rooms
FOR EACH ROW
BEGIN
    UPDATE rooms
    SET status = 'Occupied'
    WHERE room_id = NEW.room_id;
END $$

DELIMITER ;



DELIMITER $$

CREATE TRIGGER trg_after_patient_room_update
AFTER UPDATE ON patient_rooms
FOR EACH ROW
BEGIN
    IF NEW.discharge_date IS NOT NULL THEN
        UPDATE rooms
        SET status = 'Available'
        WHERE room_id = NEW.room_id;
    END IF;
END $$

DELIMITER ;

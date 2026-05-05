-- =========================
-- DATABASE
-- =========================
CREATE DATABASE hospital_db;
USE hospital_db;

-- =========================
-- TABLES
-- =========================

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
);

CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    phone VARCHAR(20)
);

CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10),
    type VARCHAR(20),
    status VARCHAR(20)
);

CREATE TABLE patient_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    room_id INT,
    admission_date DATE,
    discharge_date DATE,
    FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id),
    FOREIGN KEY (room_id)
    REFERENCES rooms(room_id)
);

CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    diagnosis TEXT,
    notes TEXT,
    FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id)
);

CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME,
    status VARCHAR(20),
    FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id)
    REFERENCES doctors(doctor_id)
);

CREATE TABLE treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    description TEXT,
    cost DECIMAL(10,2),
    FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
);

CREATE TABLE bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (appointment_id)
    REFERENCES appointments(appointment_id)
);

-- =========================
-- SIMPLE PROCEDURE
-- =========================
DELIMITER $$

CREATE PROCEDURE add_bill (
    IN app_id INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    INSERT INTO bills (appointment_id, total_amount)
    VALUES (app_id, amount);
END $$

DELIMITER ;

-- =========================
-- SIMPLE TRIGGER
-- =========================
DELIMITER $$

CREATE TRIGGER trg_room_status
AFTER INSERT ON patient_rooms
FOR EACH ROW
BEGIN
    UPDATE rooms
    SET status = 'Occupied'
    WHERE room_id = NEW.room_id;
END $$

DELIMITER ;

-- =========================
-- VIEW 1
-- =========================
CREATE VIEW patient_room_view AS
SELECT p.name AS patient_name,
       r.room_number,
       r.type
FROM patients p
JOIN patient_rooms pr
ON p.patient_id = pr.patient_id
JOIN rooms r
ON pr.room_id = r.room_id;

-- =========================
-- VIEW 2
-- =========================
CREATE VIEW doctor_appointment_view AS
SELECT d.name AS doctor_name,
       p.name AS patient_name,
       a.appointment_date
FROM doctors d
JOIN appointments a
ON d.doctor_id = a.doctor_id
JOIN patients p
ON a.patient_id = p.patient_id;
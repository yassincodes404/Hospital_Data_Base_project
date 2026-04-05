-- =========================
-- ROBUST SEED DATA
-- =========================

USE hospital_db;

-- 1. Departments (some basic departments were added in schema.sql, adding more here)
INSERT IGNORE INTO departments (name) VALUES
('Pediatrics'),
('Oncology'),
('Emergency'),
('Radiology');

-- 2. Doctors
INSERT INTO doctors (name, specialization, department_id) VALUES
('Dr. Alice Smith', 'Cardiologist', 1),
('Dr. Bob Jones', 'Neurologist', 2),
('Dr. Charlie Brown', 'Orthopedic Surgeon', 3),
('Dr. Diana Prince', 'Pediatrician', 4),
('Dr. Evan Wright', 'Oncologist', 5);

-- 3. Patients
INSERT INTO patients (name, gender, birth_date, phone) VALUES
('John Doe', 'Male', '1980-05-15', '555-0101'),
('Jane Smith', 'Female', '1992-11-22', '555-0102'),
('Michael Johnson', 'Male', '1975-03-30', '555-0103'),
('Emily Davis', 'Female', '2005-08-14', '555-0104'),
('William Wilson', 'Male', '1950-12-05', '555-0105');

-- 4. Rooms (Adding more rooms beyond schema.sql)
INSERT IGNORE INTO rooms (room_number, type, status) VALUES
('103', 'Single', 'Available'),
('104', 'Double', 'Available'),
('201', 'Single', 'Occupied'),
('ICU2', 'ICU', 'Available');

-- 5. Patient Rooms (History)
INSERT INTO patient_rooms (patient_id, room_id, admission_date, discharge_date) VALUES
(1, 1, '2023-01-10', '2023-01-15'),
(2, 2, '2023-02-20', '2023-02-25'),
(3, 6, '2023-03-01', NULL); -- Currently admitted (Room 201 should correspond to ID 6, assuming 1-3 from schema and 4-7 from here)

-- 6. Medical Records
INSERT INTO medical_records (patient_id, diagnosis, notes, record_date) VALUES
(1, 'Hypertension', 'Patient advised to reduce sodium intake.', '2023-01-12'),
(2, 'Migraine', 'Prescribed pain relievers.', '2023-02-21'),
(3, 'Fractured Femur', 'Requires surgery and physical therapy.', '2023-03-02'),
(4, 'Asthma', 'Inhaler prescribed.', '2024-01-15'),
(5, 'Coronary Artery Disease', 'Scheduled for bypass surgery.', '2024-02-10');

-- 7. Appointments
INSERT INTO appointments (patient_id, doctor_id, appointment_date, status) VALUES
(1, 1, '2024-06-01 10:00:00', 'Completed'),
(2, 2, '2024-06-02 14:30:00', 'Scheduled'),
(3, 3, '2024-06-05 09:00:00', 'Scheduled'),
(4, 4, '2024-06-10 11:15:00', 'Scheduled'),
(5, 1, '2024-06-15 13:45:00', 'Scheduled');

-- 8. Treatments
INSERT INTO treatments (appointment_id, description, cost) VALUES
(1, 'Echocardiogram and consultation', 350.00),
(2, 'Neurological Assessment', 200.00),
(3, 'Pre-surgery consultation and X-Rays', 500.00),
(4, 'Routine Checkup and Pulmonary Test', 150.00),
(5, 'Pre-op Blood Work', 250.00);

-- 9. Bills (Updates payment_status since the trigger automatically generates these)
INSERT INTO bills (appointment_id, total_amount, payment_status) VALUES
(1, 350.00, 'Paid'),
(2, 200.00, 'Unpaid'),
(3, 500.00, 'Unpaid'),
(4, 150.00, 'Unpaid'),
(5, 250.00, 'Unpaid')
ON DUPLICATE KEY UPDATE payment_status = VALUES(payment_status);

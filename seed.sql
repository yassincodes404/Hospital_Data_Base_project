-- =========================
-- EXTRA SEED DATA
-- =========================

-- More Doctors
INSERT INTO doctors (name, specialization, department_id) VALUES
('Dr. Sarah Lee', 'Radiologist', 7),
('Dr. Omar Hassan', 'Emergency Specialist', 6),
('Dr. Nancy White', 'Pediatrician', 4),
('Dr. Karim Ali', 'Cardiologist', 1),
('Dr. Mona Adel', 'Neurologist', 2);

-- More Patients
INSERT INTO patients (name, gender, birth_date, phone) VALUES
('Ahmed Ali', 'Male', '1998-07-20', '555-0201'),
('Sara Mohamed', 'Female', '2001-09-11', '555-0202'),
('Youssef Ibrahim', 'Male', '1989-01-05', '555-0203'),
('Mariam Adel', 'Female', '1995-06-17', '555-0204'),
('Khaled Hassan', 'Male', '1970-04-09', '555-0205');

-- More Rooms
INSERT INTO rooms (room_number, type, status) VALUES
('202', 'Double', 'Available'),
('203', 'Single', 'Available'),
('204', 'Single', 'Occupied'),
('ICU3', 'ICU', 'Available'),
('205', 'Double', 'Available');

-- More Patient Room Records
INSERT INTO patient_rooms (patient_id, room_id, admission_date, discharge_date) VALUES
(6, 4, '2024-03-01', '2024-03-05'),
(7, 5, '2024-03-10', NULL),
(8, 8, '2024-03-15', '2024-03-20'),
(9, 9, '2024-04-01', NULL),
(10, 10, '2024-04-05', NULL);

-- More Medical Records
INSERT INTO medical_records (patient_id, diagnosis, notes, record_date) VALUES
(6, 'Diabetes', 'Monthly follow-up needed.', '2024-03-02'),
(7, 'Fever', 'Given antibiotics.', '2024-03-11'),
(8, 'Back Pain', 'Physical therapy recommended.', '2024-03-16'),
(9, 'Pneumonia', 'Requires observation.', '2024-04-02'),
(10, 'Heart Disease', 'Medication prescribed.', '2024-04-06');

-- More Appointments
INSERT INTO appointments (patient_id, doctor_id, appointment_date, status) VALUES
(6, 6, '2024-07-01 09:00:00', 'Completed'),
(7, 7, '2024-07-02 10:30:00', 'Scheduled'),
(8, 8, '2024-07-03 12:00:00', 'Completed'),
(9, 9, '2024-07-04 14:00:00', 'Scheduled'),
(10, 10, '2024-07-05 15:30:00', 'Scheduled');

-- More Treatments
INSERT INTO treatments (appointment_id, description, cost) VALUES
(6, 'X-Ray and consultation', 180.00),
(7, 'Emergency treatment', 400.00),
(8, 'Heart checkup', 300.00),
(9, 'MRI Scan', 600.00),
(10, 'Neurological examination', 250.00);

-- More Bills
INSERT INTO bills (appointment_id, total_amount, payment_status) VALUES
(6, 180.00, 'Paid'),
(7, 400.00, 'Unpaid'),
(8, 300.00, 'Paid'),
(9, 600.00, 'Unpaid'),
(10, 250.00, 'Unpaid')
ON DUPLICATE KEY UPDATE
payment_status = VALUES(payment_status);
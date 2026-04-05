<img width="1915" height="993" alt="image" src="https://github.com/user-attachments/assets/63092114-3abd-44f5-aab3-0f4967b93f81" />

## Structure

This script creates a complete hospital database with 8 related tables.  
السكريبت ده بيعمل قاعدة بيانات مستشفى كاملة فيها 8 جداول مترابطة.
## Patients ↔ Appointments (1:N)

One patient can have many appointments, but each appointment belongs to only one patient.  
مريض واحد ممكن يكون عنده مواعيد كتير، لكن كل موعد مرتبط بمريض واحد بس.

This relationship is implemented using `appointments.patient_id` as a foreign key referencing `patients.patient_id`.  
العلاقة دي متطبقة عن طريق `appointments.patient_id` كـ foreign key بيرجع لـ `patients.patient_id`.
## Doctors ↔ Appointments (1:N)

One doctor can handle many appointments, but each appointment is assigned to one doctor.  
الدكتور الواحد ممكن يكون عنده مواعيد كتير، لكن كل موعد مرتبط بدكتور واحد بس.

This is enforced using `appointments.doctor_id` referencing `doctors.doctor_id`.  
العلاقة دي متطبقة باستخدام `appointments.doctor_id` اللي بيرجع لـ `doctors.doctor_id`.
## Departments ↔ Doctors (1:N)

Each department can have multiple doctors, but each doctor belongs to only one department.  
كل قسم ممكن يكون فيه دكاترة كتير، لكن كل دكتور تابع لقسم واحد بس.

This is implemented using `doctors.department_id` referencing `departments.department_id`.  
العلاقة دي متطبقة عن طريق `doctors.department_id` كـ foreign key بيرجع لـ `departments.department_id`.
## Appointments ↔ Treatments (1:N)

Each appointment can include multiple treatments, but each treatment belongs to one appointment only.  
كل موعد ممكن يحتوي على أكتر من علاج، لكن كل علاج مرتبط بموعد واحد بس.

This is done using `treatments.appointment_id` referencing `appointments.appointment_id`.  
العلاقة دي متطبقة باستخدام `treatments.appointment_id` اللي بيرجع لـ `appointments.appointment_id`.
## Appointments ↔ Bills (1:1)

Each appointment has exactly one bill, and each bill is linked to one appointment.  
كل موعد له فاتورة واحدة فقط، وكل فاتورة مرتبطة بموعد واحد.

This is enforced by making `bills.appointment_id` both a foreign key and UNIQUE.  
العلاقة دي متطبقة عن طريق إن `bills.appointment_id` هو foreign key وكمان UNIQUE علشان يمنع التكرار.
## Patients ↔ Medical Records (1:N)

Each patient can have multiple medical records over time, but each record belongs to one patient.  
المريض ممكن يكون له سجلات طبية متعددة مع الوقت، لكن كل سجل مرتبط بمريض واحد.

This is implemented using `medical_records.patient_id` referencing `patients.patient_id`.  
العلاقة دي متطبقة باستخدام `medical_records.patient_id` اللي بيرجع لـ `patients.patient_id`.
## Patients ↔ Rooms (M:N through patient_rooms)

A patient can stay in different rooms over time, and each room can host different patients at different times.  
المريض ممكن يدخل أكتر من غرفة مع الوقت، والغرفة ممكن تستقبل مرضى مختلفين في أوقات مختلفة.

This many-to-many relationship is handled using the `patient_rooms` table.  
العلاقة دي (many-to-many) متحلّة باستخدام جدول وسيط اسمه `patient_rooms`.

## patient_rooms Details (Bridge Table)

The `patient_rooms` table connects patients and rooms and stores admission and discharge dates.  
جدول `patient_rooms` بيربط بين المرضى والغرف وبيخزن تاريخ الدخول والخروج.

It contains:

- `patient_id` → references patient
    
- `room_id` → references room
    
- `admission_date` and `discharge_date`
    

## Cascade Behavior

When a patient or appointment is deleted, related records (appointments, treatments, etc.) are automatically deleted using `ON DELETE CASCADE`.  
لما يتم حذف مريض أو موعد، البيانات المرتبطة بيه (زي المواعيد أو العلاجات) بتتمسح تلقائي باستخدام `ON DELETE CASCADE`.

This prevents orphan records and keeps data consistent.  
وده بيمنع وجود بيانات غير مرتبطة وبيحافظ على تكامل البيانات.
## Performance

Indexes are added on important columns to improve query performance.  
تم إضافة Indexes على الأعمدة المهمة لتحسين سرعة الاستعلامات.
## Stored Procedures

`sp_add_appointment` ensures that patient and doctor exist before inserting a new appointment.  
`sp_add_appointment` بيتأكد إن المريض والدكتور موجودين قبل ما يضيف موعد جديد.
`sp_generate_bill` calculates total treatment cost and updates or inserts the bill.  
`sp_generate_bill` بيحسب تكلفة العلاجات وبيعمل تحديث أو إنشاء للفاتورة.
## Triggers

When a treatment is added, the bill is automatically updated using a trigger.  
عند إضافة علاج، الفاتورة بتتحدث تلقائي باستخدام Trigger.

When a patient is assigned to a room, it becomes occupied, and when discharged, it becomes available again.  
عند حجز مريض في غرفة بتتحول لمشغولة، وعند الخروج بترجع متاحة.
## Architecture Quality

The database separates core data, operations, and business logic, making it scalable and maintainable.  
قاعدة البيانات بتفصل بين البيانات الأساسية والعمليات والـ business logic، وده بيخليها قابلة للتطوير وسهلة الصيانة.

## Schema mysql script :

```sql 
-- =========================
-- DATABASE
-- =========================
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_birth_date CHECK (birth_date <= CURRENT_DATE)
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
-- TABLE: patient_rooms
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

    CONSTRAINT chk_dates CHECK (
            discharge_date IS NULL 
            OR discharge_date >= admission_date
        )
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
-- SAFE SEED DATA
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
-- PROCEDURES
-- =========================

DELIMITER $$

CREATE PROCEDURE sp_add_appointment (
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_date DATETIME
)
BEGIN
    DECLARE patient_exists INT;
    DECLARE doctor_exists INT;

    SELECT COUNT(*) INTO patient_exists 
    FROM patients WHERE patient_id = p_patient_id;

    SELECT COUNT(*) INTO doctor_exists 
    FROM doctors WHERE doctor_id = p_doctor_id;

    IF patient_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patient does not exist';
    ELSEIF doctor_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor does not exist';
    ELSE
        INSERT INTO appointments (patient_id, doctor_id, appointment_date)
        VALUES (p_patient_id, p_doctor_id, p_date);
    END IF;

END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_generate_bill (
    IN p_appointment_id INT
)
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT IFNULL(SUM(cost), 0)
    INTO total
    FROM treatments
    WHERE appointment_id = p_appointment_id;

    INSERT INTO bills (appointment_id, total_amount)
    VALUES (p_appointment_id, total)
    ON DUPLICATE KEY UPDATE
        total_amount = total;

END $$

DELIMITER ;

-- =========================
-- TRIGGERS
-- =========================

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
```

-------------------------------------------------------------
-- HOSPITAL MANAGEMENT SYSTEM 
-------------------------------------------------------------

DROP DATABASE IF EXISTS HospitalDB;
CREATE DATABASE HospitalDB;
USE HospitalDB;

-------------------------------------------------------------
-- 1. MAIN TABLES
-------------------------------------------------------------

CREATE TABLE Patients (
    PatientID VARCHAR(10) PRIMARY KEY,
    PatientName VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    Contact VARCHAR(20)
);

CREATE TABLE Doctors (
    DoctorID VARCHAR(10) PRIMARY KEY,
    DoctorName VARCHAR(100),
    Specialization VARCHAR(50)
);

CREATE TABLE Treatments (
    TreatmentID INT PRIMARY KEY,
    TreatmentName VARCHAR(100),
    Charge DECIMAL(10,2)
);

CREATE TABLE Medicines (
    MedicineID INT PRIMARY KEY,
    MedicineName VARCHAR(100), 
    Price DECIMAL(10,2),
    Stock INT DEFAULT 100
);

-------------------------------------------------------------
-- 2. APPOINTMENTS
-------------------------------------------------------------

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID VARCHAR(10),
    DoctorID VARCHAR(10),
    AppointmentDate DATE,
    AppointmentTime TIME,
    Status VARCHAR(50),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-------------------------------------------------------------
-- 3. APPOINTMENT TREATMENTS / MEDICINES
-------------------------------------------------------------

CREATE TABLE AppointmentTreatments (
    AppointmentID INT,
    TreatmentID INT,
    PRIMARY KEY (AppointmentID, TreatmentID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    FOREIGN KEY (TreatmentID) REFERENCES Treatments(TreatmentID)
);

CREATE TABLE AppointmentMedicines (
    AppointmentID INT,
    MedicineID INT,
    Quantity INT,
    PRIMARY KEY (AppointmentID, MedicineID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    FOREIGN KEY (MedicineID) REFERENCES Medicines(MedicineID)
);

-------------------------------------------------------------
-- 4. BILLING
-------------------------------------------------------------

CREATE TABLE Billing (
    BillID INT PRIMARY KEY,
    AppointmentID INT UNIQUE,
    TreatmentCost DECIMAL(10,2) DEFAULT 0,
    MedicineCost DECIMAL(10,2) DEFAULT 0,
    TotalAmount DECIMAL(10,2) DEFAULT 0,
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid',
    BillDate DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

-------------------------------------------------------------
-- 5. PAYMENTS
-------------------------------------------------------------

CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    BillID INT,
    PaymentMode VARCHAR(20),
    AmountPaid DECIMAL(10,2),
    PaymentDate DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (BillID) REFERENCES Billing(BillID)
);

-------------------------------------------------------------
-- 6. INSERT VALUES (MORE VALUES ADDED)
-------------------------------------------------------------

INSERT INTO Patients VALUES
('P01','Ravi',30,'Male','9876543210'),
('P02','Neha',28,'Female','9876512340'),
('P03','Suresh',45,'Male','9876500001'),
('P04','Ananya',34,'Female','9988776655'),
('P05','Rohit',29,'Male','8877665544'),
('P06','Lakshmi',52,'Female','9001122334'),
('P07','Arjun',40,'Male','9090909090'),
('P08','Meera',36,'Female','9191919191'),
('P09','Kiran',55,'Male','9000022211'),
('P10','Divya',24,'Female','8111122221');

INSERT INTO Doctors VALUES
('D01','Dr. James','General Physician'),
('D02','Dr. Meera','Cardiologist'),
('D03','Dr. Rahul','Dermatologist'),
('D04','Dr. Priya','Neurologist'),
('D05','Dr. Aravind','Orthopedic Surgeon'),
('D06','Dr. Sonia','ENT Specialist');

INSERT INTO Treatments VALUES
(1,'Fever Check',200),
(2,'Blood Test',700),
(3,'ECG',500),
(4,'X-Ray',800),
(5,'Skin Biopsy',1500),
(6,'MRI Scan',3000),
(7,'Ultrasound',1200),
(8,'Skin Allergy Test',900),
(9,'Physiotherapy',600),
(10,'Eye Checkup',300),
(11,'Ear Cleaning',150),
(12,'Thyroid Test',650);

INSERT INTO Medicines VALUES
(1,'Paracetamol',50,100),
(2,'Vitamin C',100,100),
(3,'Cough Syrup',80,50),
(4,'Dolo 650',75,180),
(5,'Cetirizine',40,150),
(6,'Amoxicillin',120,200),
(7,'Ibuprofen',90,80),
(8,'Antacid Syrup',60,90),
(9,'Digene Tablets',55,70),
(10,'Pain Relief Gel',110,60),
(11,'Eye Drops',90,120),
(12,'Throat Spray',130,90);


INSERT INTO Appointments VALUES
(101,'P01','D01','2025-01-10','10:30:00','Scheduled'),
(102,'P02','D03','2025-01-14','11:00:00','Scheduled'),
(103,'P03','D02','2025-01-15','09:30:00','Scheduled'),
(104,'P04','D06','2025-01-16','12:00:00','Scheduled'),
(105,'P05','D04','2025-01-18','03:00:00','Scheduled'),
(106,'P06','D05','2025-01-20','10:15:00','Scheduled'),
(107,'P07','D01','2025-01-22','14:00:00','Scheduled'),
(108,'P08','D02','2025-01-25','16:30:00','Scheduled'),
(109,'P09','D03','2025-01-28','10:00:00','Scheduled'),
(110,'P10','D04','2025-01-30','11:45:00','Scheduled');

INSERT INTO Billing (BillID, AppointmentID) VALUES
(1,101),(2,102),(3,103),(4,104),(5,105),
(6,106),(7,107),(8,108),(9,109),(10,110);

-------------------------------------------------------------
-- 7. BILL CALCULATE PROCEDURE
-------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE CalculateBill(IN appt INT)
BEGIN
    DECLARE t DECIMAL(10,2) DEFAULT 0;
    DECLARE m DECIMAL(10,2) DEFAULT 0;

    SELECT IFNULL(SUM(T.Charge),0) INTO t
    FROM AppointmentTreatments A
    JOIN Treatments T ON A.TreatmentID=T.TreatmentID
    WHERE AppointmentID=appt;

    SELECT IFNULL(SUM(M.Price*A.Quantity),0) INTO m
    FROM AppointmentMedicines A
    JOIN Medicines M ON A.MedicineID=M.MedicineID
    WHERE AppointmentID=appt;

    UPDATE Billing
    SET TreatmentCost=t, MedicineCost=m, TotalAmount=t+m
    WHERE AppointmentID=appt;
END $$
DELIMITER ;

-------------------------------------------------------------
-- 8. AUTO BILL UPDATE + STOCK UPDATE
-------------------------------------------------------------
-- when a treatment is added
DELIMITER $$
CREATE TRIGGER trg_add_treatment
AFTER INSERT ON AppointmentTreatments
FOR EACH ROW
BEGIN
    CALL CalculateBill(NEW.AppointmentID);
END $$
DELIMITER ;

-- when a medicine is added
DELIMITER $$
CREATE TRIGGER trg_add_medicine
AFTER INSERT ON AppointmentMedicines
FOR EACH ROW
BEGIN
    CALL CalculateBill(NEW.AppointmentID);

    UPDATE Medicines
    SET Stock = Stock - NEW.Quantity
    WHERE MedicineID = NEW.MedicineID;
END $$
DELIMITER ;

-- Auto restock
DELIMITER $$
CREATE TRIGGER trg_restock
BEFORE UPDATE ON Medicines
FOR EACH ROW
BEGIN
    IF NEW.Stock <= 20 THEN
        SET NEW.Stock = NEW.Stock + 100;
    END IF;
END $$
DELIMITER ;

-------------------------------------------------------------
-- 9. PAYMENTS
-------------------------------------------------------------

-- Prevent overpay
DELIMITER $$
CREATE TRIGGER trg_prevent_overpay
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE paid DECIMAL(10,2);

    SELECT TotalAmount INTO total FROM Billing WHERE BillID=NEW.BillID;
    SELECT IFNULL(SUM(AmountPaid),0) INTO paid FROM Payments WHERE BillID=NEW.BillID;

    IF (paid + NEW.AmountPaid) > total THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Overpayment not allowed';
    END IF;
END $$
DELIMITER ;

-- Update PaymentStatus
DELIMITER $$
CREATE TRIGGER trg_update_payment_status
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE paid DECIMAL(10,2);

    SELECT TotalAmount INTO total FROM Billing WHERE BillID=NEW.BillID;
    SELECT SUM(AmountPaid) INTO paid FROM Payments WHERE BillID=NEW.BillID;

    IF paid = total THEN
        UPDATE Billing SET PaymentStatus='Paid' WHERE BillID=NEW.BillID;
    ELSE
        UPDATE Billing SET PaymentStatus='Partially Paid' WHERE BillID=NEW.BillID;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_payment_updates_appointment
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE bill_total DECIMAL(10,2);
    DECLARE total_paid DECIMAL(10,2);

    SELECT TotalAmount INTO bill_total
    FROM Billing WHERE BillID = NEW.BillID;

    SELECT IFNULL(SUM(AmountPaid),0) INTO total_paid
    FROM Payments WHERE BillID = NEW.BillID;

    -- If fully paid → mark appointment Completed
    IF total_paid = bill_total THEN
        UPDATE Appointments
        SET Status = 'Completed'
        WHERE AppointmentID = (SELECT AppointmentID FROM Billing WHERE BillID = NEW.BillID);
    END IF;

END $$
DELIMITER ;



-- 11. VIEW

CREATE OR REPLACE VIEW vw_AppointmentSummary AS
SELECT 
A.AppointmentID, P.PatientName, D.DoctorName,
A.AppointmentDate, A.AppointmentTime, A.Status,
B.TotalAmount, B.PaymentStatus
FROM Appointments A
JOIN Patients P ON A.PatientID=P.PatientID
JOIN Doctors D ON A.DoctorID=D.DoctorID
LEFT JOIN Billing B ON A.AppointmentID=B.AppointmentID;

-------------------------------------------------------------
-- 12. FINAL SELECTS
-------------------------------------------------------------

SELECT * FROM Patients;
SELECT * FROM Doctors;
SELECT * FROM Treatments;
SELECT * FROM Medicines;
SELECT * FROM Appointments;
SELECT * FROM Billing;
SELECT * FROM Payments;
SELECT * FROM vw_AppointmentSummary;

insert into appointmenttreatments values(101,1);
insert into appointmentmedicines values(101,1,5);
insert into pAyments(billid,paymentmode,amountpaid) values(1,'UPI',250);




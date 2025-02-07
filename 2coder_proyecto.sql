CREATE SCHEMA coder_proyecto;
USE coder_proyecto;
	
CREATE TABLE Client (
Client_ID INT AUTO_INCREMENT,
    Client_name VARCHAR(100), 
    Email VARCHAR(50),
    Client_phone VARCHAR(20),
    PRIMARY KEY (Client_id)
);

select * from client;

CREATE TABLE Therapist(
Therapist_ID INT AUTO_INCREMENT,
Therapist_name VARCHAR(100),
Service_Name VARCHAR(50),
Therapist_phone VARCHAR(20),
PRIMARY KEY (Therapist_ID)
);

select * from Therapist;

CREATE TABLE Service(
Service_ID INT AUTO_INCREMENT,
Price DECIMAL(10.2),
Duration INT NOT NULL,
Service_Name VARCHAR(50),
primary key (Service_ID)
);

select * from Service;

ALTER TABLE Service
ADD CONSTRAINT UNIQUE (Service_Name);

ALTER TABLE Therapist
ADD CONSTRAINT FK_Service_Name
foreign key (Service_Name) REFERENCES Service(Service_Name)
;
    
CREATE TABLE Appointment (
Appointment_ID INT AUTO_INCREMENT,
Appointment_date DATE,
Appointment_time TIME NOT NULL,
Client_ID INT,
Therapist_ID INT,
Service_ID INT,
primary key (Appointment_ID),
FOREIGN KEY (Client_ID) REFERENCES Client(Client_ID),
FOREIGN KEY (Therapist_ID) REFERENCES Therapist(Therapist_ID),
FOREIGN KEY (Service_ID) REFERENCES Service(Service_ID)
);

select * from Appointment;

CREATE TABLE Payment (
Payment_ID INT AUTO_INCREMENT,
Appointment_ID int,
Payment_date DATE,
Amount decimal (10.2),
Payment_method VARCHAR(20),
PRIMARY KEY (Payment_ID),
FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
);

select * from Payment;

CREATE VIEW ClientAppointment AS
SELECT c.Client_ID, c.Client_name, a.Appointment_date, a.Appointment_time, t.Therapist_name, s.Service_Name
FROM Client c
JOIN Appointment a ON c.Client_ID = a.Client_ID
JOIN Therapist t ON a.Therapist_ID = t.Therapist_ID
JOIN Service s ON a.Service_ID = s.Service_ID;

CREATE VIEW TherapistSchedule AS
SELECT t.Therapist_ID, t.Therapist_name, a.Appointment_date, a.Appointment_time, c.Client_name
FROM Therapist t
JOIN Appointment a ON t.Therapist_ID = a.Therapist_ID
JOIN Client c ON a.Client_ID = c.Client_ID;

CREATE VIEW DailyAppointments AS
SELECT a.Appointment_date, a.Appointment_time, c.Client_name, t.Therapist_name, s.Service_Name
FROM Appointment a
JOIN Client c ON a.Client_ID = c.Client_ID
JOIN Therapist t ON a.Therapist_ID = t.Therapist_ID
JOIN Service s ON a.Service_ID = s.Service_ID
WHERE a.Appointment_date = CURDATE();

DELIMITER //
CREATE FUNCTION GetTotalPaidByClient(clientID INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalPaid DECIMAL(10,2);
    SELECT SUM(p.Amount) INTO totalPaid
    FROM Payment p
    JOIN Appointment a ON p.Appointment_ID = a.Appointment_ID
    WHERE a.Client_ID = clientID;
    RETURN COALESCE(totalPaid, 0);
END;
//

DELIMITER //
CREATE FUNCTION TherapistServiceCount(therapistID INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE serviceCount INT DEFAULT 0;
    SELECT COUNT(DISTINCT Service_ID) INTO serviceCount
    FROM Appointment
    WHERE Therapist_ID = therapistID;
    RETURN serviceCount;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION GetClientAppointmentCount(clientID INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE appointmentCount INT;
    SELECT COUNT INTO appointmentCount
    FROM Appointment
    WHERE Client_ID = clientID;
    RETURN appointmentCount;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddAppointment(
    IN clientID INT, 
    IN therapistID INT, 
    IN serviceID INT, 
    IN appointmentDate DATE, 
    IN appointmentTime TIME
)
BEGIN
    INSERT INTO Appointment (Client_ID, Therapist_ID, Service_ID, Appointment_date, Appointment_time)
    VALUES (clientID, therapistID, serviceID, appointmentDate, appointmentTime);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddPayment(
    IN appointmentID INT, 
    IN paymentDate DATE, 
    IN amount DECIMAL(10,2), 
    IN paymentMethod VARCHAR(20)
)
BEGIN
    INSERT INTO Payment (Appointment_ID, Payment_date, Amount, Payment_method)
    VALUES (appointmentID, paymentDate, amount, paymentMethod);
END //
DELIMITER ;

INSERT INTO Client (Client_name, Email, Client_phone) VALUES
('Luis Suárez', 'l.suarez@gmail.com', '59899168707'),
('Diego Forlán', 'dforlan@gmail.com', '59899169708'),
('Endinson Cavani', 'cavani@gmail.com', '59899168709'),
('Diego Godín', 'godindiego@gmail.com', '59899168710');

SELECT * FROM CLIENT;

INSERT INTO Service (Price, Duration, Service_Name) VALUES
(900, 60, 'Masaje Relajante'),
(1000, 90, 'Terapia'),
(950, 120, 'Acupuntura'),
(890, 60, 'Masaje con piedras');

select * from Service;


INSERT INTO Therapist (Therapist_name, Service_Name, Therapist_phone) VALUES
('Pepe Pérez', 'Masaje Relajante', '24092841'),
('Mariano Martínez', 'Terapia', '24092842'),
('María Fernández', 'Acupuntura', '24092843'),
('Griselda Siciliani', 'Masaje con piedras', '24092844');

select * from Therapist; 


INSERT INTO Appointment (Appointment_date, Appointment_time, Client_ID, Therapist_ID, Service_ID) VALUES
('2025-02-10', '10:00:00', 1, 1, 1),
('2025-02-11', '11:30:00', 2, 2, 2),
('2025-02-12', '14:00:00', 3, 3, 3),
('2025-02-12', '14:30:00', 4, 4, 4);	

select * from Appointment; 

INSERT INTO Payment (Appointment_ID, Payment_date, Amount, Payment_method) VALUES
(9, '2025-02-10', 900.00, 'Efectivo'),
(10, '2025-02-11', 1000.00, 'Tarjeta de Crédito'),
(11, '2025-02-12', 950.00, 'Transferencia'),
(12, '2025-02-12', 890.00, 'Tarjeta de Débito');

select * from Payment;

DELIMITER //
CREATE TRIGGER Prevent_Duplicate_Appointment
AFTER INSERT ON Appointment
FOR EACH ROW
BEGIN
    DELETE FROM Appointment
    WHERE Client_ID = NEW.Client_ID 
    AND Appointment_date = NEW.Appointment_date
    AND Appointment_time = NEW.Appointment_time
    AND Appointment_ID <> NEW.Appointment_ID;
END;
//
DELIMITER ;

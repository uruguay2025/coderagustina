CREATE SCHEMA coder_proyecto;
USE coder_proyecto;
	
CREATE TABLE Clients (
Client_ID INT AUTO_INCREMENT,
    Client_name VARCHAR(100), 
    Email VARCHAR(50),
    Client_phone VARCHAR(20),
    PRIMARY KEY (Client_id)
);

select * from clients;

CREATE TABLE Therapists(
Therapist_ID INT AUTO_INCREMENT,
Therapist_name VARCHAR(100),
Service_Name VARCHAR(50),
Therapist_phone VARCHAR(20),
PRIMARY KEY (Therapist_ID)
);

select * from Therapists;

CREATE TABLE Services(
Service_ID INT AUTO_INCREMENT,
Price DECIMAL(10.2),
Duration INT NOT NULL,
Service_Name VARCHAR(50),
primary key (Service_ID)
);

select * from Services;

ALTER TABLE Services
ADD CONSTRAINT UNIQUE (Service_Name);

ALTER TABLE Therapists
ADD CONSTRAINT FK_Service_Name
foreign key (Service_Name) REFERENCES Services(Service_Name)
;
    
CREATE TABLE Appointments (
Appointment_ID INT AUTO_INCREMENT,
Appointment_date DATE,
Appointment_time TIME NOT NULL,
Client_ID INT,
Therapist_ID INT,
Service_ID INT,
primary key (Appointment_ID),
FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID),
FOREIGN KEY (Therapist_ID) REFERENCES Therapists(Therapist_ID),
FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID)
);

select * from Appointments;

CREATE TABLE Payments (
Payment_ID INT AUTO_INCREMENT,
Appointment_ID int,
Payment_date DATE,
Amount decimal (10.2),
Payment_method VARCHAR(20),
PRIMARY KEY (Payment_ID),
FOREIGN KEY (Appointment_ID) REFERENCES Appointments(Appointment_ID)
);

select * from Payments;

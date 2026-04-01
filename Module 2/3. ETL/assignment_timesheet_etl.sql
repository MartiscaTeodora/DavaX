

/* =========================================================
   0. Create database and schemas
   ========================================================= */

BEGIN
    CREATE DATABASE etlTimesheetDB;
END
GO

USE etlTimesheetDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'hr') EXEC('CREATE SCHEMA hr');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ref') EXEC('CREATE SCHEMA ref');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'work') EXEC('CREATE SCHEMA work');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stage') EXEC('CREATE SCHEMA stage');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw') EXEC('CREATE SCHEMA dw');
GO

/* =========================================================
   1. Drop reporting and staging objects if script is re-run
   ========================================================= */
IF OBJECT_ID('dw.Fact_EmployeeActivity', 'U') IS NOT NULL DROP TABLE dw.Fact_EmployeeActivity;
IF OBJECT_ID('stage.Training_Attendance', 'U') IS NOT NULL DROP TABLE stage.Training_Attendance;
IF OBJECT_ID('stage.Absence_Input', 'U') IS NOT NULL DROP TABLE stage.Absence_Input;
IF OBJECT_ID('ref.Training', 'U') IS NOT NULL DROP TABLE ref.Training;
IF OBJECT_ID('ref.AbsenceType', 'U') IS NOT NULL DROP TABLE ref.AbsenceType;
IF OBJECT_ID('ref.ActivityType', 'U') IS NOT NULL DROP TABLE ref.ActivityType;
IF OBJECT_ID('ref.CalendarDate', 'U') IS NOT NULL DROP TABLE ref.CalendarDate;
GO

/* =========================================================
   2. Original operational model (cleaned and grouped)
   ========================================================= */
IF OBJECT_ID('work.TimesheetEntry', 'U') IS NOT NULL DROP TABLE work.TimesheetEntry;
IF OBJECT_ID('work.Timesheet', 'U') IS NOT NULL DROP TABLE work.Timesheet;
IF OBJECT_ID('work.Proiect', 'U') IS NOT NULL DROP TABLE work.Proiect;
IF OBJECT_ID('ref.Locatie', 'U') IS NOT NULL DROP TABLE ref.Locatie;
IF OBJECT_ID('ref.Client', 'U') IS NOT NULL DROP TABLE ref.Client;
IF OBJECT_ID('hr.Angajat', 'U') IS NOT NULL DROP TABLE hr.Angajat;
GO

CREATE TABLE hr.Angajat (
    idAngajat INT IDENTITY(1,1) PRIMARY KEY,
    manager INT NULL,
    cnp CHAR(13) NOT NULL,
    telefon VARCHAR(15) NOT NULL,
    mail VARCHAR(100) NOT NULL,
    nume VARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Angajat_CNP UNIQUE (cnp),
    CONSTRAINT UQ_Angajat_Mail UNIQUE (mail),
    CONSTRAINT CHK_Angajat_CNP CHECK (LEN(cnp) = 13),
    CONSTRAINT CK_Angajat_Mail CHECK (mail LIKE '%@%.%'),
    CONSTRAINT FK_Angajat_Manager FOREIGN KEY (manager)
        REFERENCES hr.Angajat(idAngajat)
);
GO

CREATE TABLE ref.Client (
    idClient INT IDENTITY(1,1) PRIMARY KEY,
    nume VARCHAR(200) NOT NULL,
    detalii NVARCHAR(MAX) NULL,
    CONSTRAINT CHK_Client_JSON CHECK (detalii IS NULL OR ISJSON(detalii) = 1)
);
GO

CREATE TABLE ref.Locatie (
    idLocatie INT IDENTITY(1,1) PRIMARY KEY,
    adresa VARCHAR(200) NOT NULL,
    detalii VARCHAR(255) NULL
);
GO

CREATE TABLE work.Proiect (
    idProiect INT IDENTITY(1,1) PRIMARY KEY,
    manager INT NOT NULL,
    idClient INT NOT NULL,
    nume VARCHAR(100) NOT NULL,
    detalii NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Proiect_Manager FOREIGN KEY (manager)
        REFERENCES hr.Angajat(idAngajat),
    CONSTRAINT FK_Proiect_Client FOREIGN KEY (idClient)
        REFERENCES ref.Client(idClient),
    CONSTRAINT CHK_Proiect_JSON CHECK (detalii IS NULL OR ISJSON(detalii) = 1)
);
GO

CREATE TABLE work.Timesheet (
    idTimesheet INT IDENTITY(1,1) PRIMARY KEY,
    idAngajat INT NOT NULL,
    dataPontaj DATE NOT NULL,
    startZi TIME NOT NULL,
    endZi TIME NOT NULL,
    idLocatie INT NOT NULL,
    CONSTRAINT FK_Timesheet_Angajat FOREIGN KEY (idAngajat)
        REFERENCES hr.Angajat(idAngajat),
    CONSTRAINT FK_Timesheet_Locatie FOREIGN KEY (idLocatie)
        REFERENCES ref.Locatie(idLocatie),
    CONSTRAINT CHK_Timesheet_Interval CHECK (endZi > startZi),
    CONSTRAINT UQ_Timesheet_EmployeeDate UNIQUE (idAngajat, dataPontaj)
);
GO

CREATE TABLE work.TimesheetEntry (
    idEntry INT IDENTITY(1,1) PRIMARY KEY,
    idTimesheet INT NOT NULL,
    idProiect INT NOT NULL,
    startTime TIME NOT NULL,
    endTime TIME NOT NULL,
    ore DECIMAL(4,2) NOT NULL,
    descriere VARCHAR(255) NULL,
    details NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Entry_Timesheet FOREIGN KEY (idTimesheet)
        REFERENCES work.Timesheet(idTimesheet),
    CONSTRAINT FK_Entry_Proiect FOREIGN KEY (idProiect)
        REFERENCES work.Proiect(idProiect),
    CONSTRAINT CHK_Entry_Interval CHECK (endTime > startTime),
    CONSTRAINT CHK_Entry_Ore CHECK (ore > 0),
    CONSTRAINT CHK_Entry_JSON CHECK (details IS NULL OR ISJSON(details) = 1)
);
GO

CREATE INDEX idx_angajat_mail ON hr.Angajat(mail);
CREATE INDEX idx_angajat_nume ON hr.Angajat(nume);
CREATE INDEX idx_timesheet_employee_date ON work.Timesheet(idAngajat, dataPontaj);
CREATE INDEX idx_entry_timesheet ON work.TimesheetEntry(idTimesheet);
GO

/* =========================================================
   3. Seed data for the original database
   ========================================================= */
INSERT INTO hr.Angajat (manager, cnp, telefon, mail, nume)
VALUES
(NULL, '1980101123456', '0712345678', 'ion.popescu@email.com', 'Ion Popescu'),
(NULL, '1970303123456', '0734567890', 'mihai.popa@email.com', 'Mihai Popa'),
(1, '2960404123456', '0745678901', 'elena.georgescu@email.com', 'Elena Georgescu'),
(1, '2950505123456', '0751111111', 'alex.ionescu@email.com', 'Alex Ionescu'),
(1, '2940606123456', '0752222222', 'maria.popescu@email.com', 'Maria Popescu'),
(2, '1930707123456', '0753333333', 'dan.vasilescu@email.com', 'Dan Vasilescu'),
(2, '2920808123456', '0754444444', 'ioana.stan@email.com', 'Ioana Stan'),
(3, '1910909123456', '0755555555', 'andrei.marin@email.com', 'Andrei Marin');
GO

INSERT INTO ref.Client (nume, detalii)
VALUES
('Endava',    '{"tara":"UK","industrie":"IT","nr_angajati":10000}'),
('Google',    '{"tara":"USA","industrie":"Tech","produse":["Search","Cloud","AI"]}'),
('Amazon',    '{"tara":"USA","industrie":"E-commerce","servicii":["AWS","Retail"]}'),
('Microsoft', '{"tara":"USA","industrie":"Software","produse":["Azure","Office"]}'),
('Oracle',    '{"tara":"USA","industrie":"Database","focus":"enterprise"}');
GO

INSERT INTO ref.Locatie (adresa, detalii)
VALUES
('Bucuresti, Strada Unirii, nr. 3',  'HQ'),
('Timisoara, Strada Cometei, nr. 33','Office'),
('Cluj, Strada 2 Iunie, nr. 333',    'Office'),
('Brasov, Strada Lunga, nr. 3333',   'Client site');
GO

INSERT INTO work.Proiect (manager, idClient, nume, detalii)
VALUES
(1, 1, 'Platforma Banking',   '{"tip":"web","tehnologie":"Java","durata_luni":12}'),
(2, 2, 'Aplicatie Mobile',    '{"tip":"mobile","tehnologie":"Kotlin","durata_luni":8}'),
(1, 3, 'Sistem E-commerce',   '{"tip":"web","tehnologie":"React","durata_luni":10}'),
(3, 4, 'Platforma Cloud',     '{"tip":"cloud","tehnologie":"Azure","durata_luni":15}'),
(2, 5, 'Dashboard Analytics', '{"tip":"BI","tehnologie":"PowerBI","durata_luni":6}');
GO

/* More inserts added so the assignment has enough data for reporting */
INSERT INTO work.Timesheet (idAngajat, dataPontaj, startZi, endZi, idLocatie)
VALUES
(1, '2025-05-07', '08:00', '16:00', 1),
(2, '2025-05-07', '09:00', '17:00', 1),
(3, '2025-05-07', '08:30', '16:30', 2),
(4, '2025-05-07', '08:00', '16:00', 1),
(1, '2025-05-08', '08:00', '16:00', 1),
(2, '2025-05-08', '09:00', '17:00', 2),
(3, '2025-05-08', '08:30', '16:30', 2),
(5, '2025-05-09', '08:00', '16:00', 3),
(6, '2025-05-10', '09:00', '17:00', 3),
(7, '2025-05-10', '08:00', '16:00', 4),
(7, '2025-05-12', '09:00', '17:00', 4),
(8, '2025-05-12', '08:00', '16:00', 4);
GO

INSERT INTO work.TimesheetEntry (idTimesheet, idProiect, startTime, endTime, ore, descriere, details)
VALUES
(1, 1, '08:00', '10:00', 2.00, 'Dezvoltare modul login', '{"task":"development","complexity":"medium","tools":["Spring"]}'),
(1, 2, '10:00', '16:00', 6.00, 'Implementare UI',        '{"task":"frontend","complexity":"high","tools":["Angular"]}'),
(2, 3, '09:00', '12:00', 3.00, 'Fix bug-uri',            '{"task":"bugfix","priority":"high"}'),
(2, 5, '13:00', '17:00', 4.00, 'Creare rapoarte',        '{"task":"reporting","tool":"PowerBI"}'),
(3, 4, '08:30', '16:30', 8.00, 'Configurare infrastructura', '{"task":"devops","platform":"Azure","complexity":"high"}'),
(4, 1, '08:00', '12:00', 4.00, 'API development',        '{"task":"backend"}'),
(4, 3, '12:30', '16:00', 3.50, 'Code review',            '{"task":"review"}'),
(5, 1, '08:00', '11:30', 3.50, 'Analiza cerinte',        '{"task":"analysis"}'),
(5, 5, '12:00', '16:00', 4.00, 'Dashboard update',       '{"task":"reporting"}'),
(6, 2, '09:00', '13:00', 4.00, 'Mobile testing',         '{"task":"testing"}'),
(6, 4, '13:30', '17:00', 3.50, 'Cloud support',          '{"task":"support"}'),
(7, 4, '08:30', '16:00', 7.50, 'Azure deployment',       '{"task":"deployment"}'),
(8, 3, '08:00', '12:00', 4.00, 'UX fixes',               '{"task":"frontend"}'),
(8, 1, '13:00', '16:00', 3.00, 'Banking bug fix',        '{"task":"bugfix"}'),
(9, 5, '09:00', '12:00', 3.00, 'PowerBI model',          '{"task":"reporting"}'),
(9, 2, '13:00', '17:00', 4.00, 'Release support',        '{"task":"release"}'),
(10,4, '08:00', '12:00', 4.00, 'Infra checks',           '{"task":"ops"}'),
(10,5, '13:00', '16:00', 3.00, 'Report cleanup',         '{"task":"reporting"}'),
(11,4, '09:00', '13:00', 4.00, 'Automation scripts',     '{"task":"automation"}'),
(11,5, '13:30', '17:00', 3.50, 'KPI update',             '{"task":"reporting"}'),
(12,1, '08:00', '12:00', 4.00, 'Incident fix',           '{"task":"support"}'),
(12,3, '13:00', '16:00', 3.00, 'Client change request',  '{"task":"change"}');
GO

/* =========================================================
   4. Reporting lookup tables
   ========================================================= */
CREATE TABLE ref.CalendarDate (
    calendar_date DATE PRIMARY KEY,
    calendar_year INT NOT NULL,
    calendar_month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_month INT NOT NULL,
    day_name VARCHAR(20) NOT NULL
);
GO

;WITH d AS (
    SELECT CAST('2025-05-01' AS DATE) AS dt
    UNION ALL
    SELECT DATEADD(DAY, 1, dt)
    FROM d
    WHERE dt < '2025-05-31'
)
INSERT INTO ref.CalendarDate (calendar_date, calendar_year, calendar_month, month_name, day_of_month, day_name)
SELECT
    dt,
    YEAR(dt),
    MONTH(dt),
    DATENAME(MONTH, dt),
    DAY(dt),
    DATENAME(WEEKDAY, dt)
FROM d
OPTION (MAXRECURSION 100);
GO

CREATE TABLE ref.ActivityType (
    activity_type_code VARCHAR(20) PRIMARY KEY,
    activity_type_name VARCHAR(50) NOT NULL
);
GO

INSERT INTO ref.ActivityType (activity_type_code, activity_type_name)
VALUES ('WORK','Worked'), ('ABSENCE','Absent'), ('TRAINING','Training');
GO

CREATE TABLE ref.AbsenceType (
    absence_type_code VARCHAR(10) PRIMARY KEY,
    absence_type_name VARCHAR(50) NOT NULL
);
GO

INSERT INTO ref.AbsenceType (absence_type_code, absence_type_name)
VALUES ('FAC','Facultate'), ('PER','Personal'), ('OTH','Altele');
GO

CREATE TABLE ref.Training (
    training_id INT IDENTITY(1,1) PRIMARY KEY,
    training_name VARCHAR(100) NOT NULL,
    session_date DATE NOT NULL,
    CONSTRAINT UQ_Training UNIQUE (training_name, session_date)
);
GO

/* =========================================================
   5. Staging tables for new input files (CSV)
   ========================================================= */
CREATE TABLE stage.Absence_Input (
    employee_mail VARCHAR(100) NOT NULL,
    absence_date DATE NOT NULL,
    missing_hours DECIMAL(4,2) NOT NULL,
    absence_type_code VARCHAR(10) NOT NULL,
    reason VARCHAR(255) NULL
);
GO

CREATE TABLE stage.Training_Attendance (
    employee_mail VARCHAR(100) NOT NULL,
    employee_name VARCHAR(100) NULL,
    training_name VARCHAR(100) NOT NULL,
    session_date DATE NOT NULL,
    first_join DATETIME2 NOT NULL,
    last_leave DATETIME2 NOT NULL,
    in_meeting_duration VARCHAR(30) NOT NULL,
    role VARCHAR(50) NULL
);
GO
USE etlTimesheetDB;

CREATE TABLE stage.Leave (
    employee_mail VARCHAR(100) NOT NULL,
    employee_name VARCHAR(100) NULL,
    leave_type VARCHAR(100) NOT NULL,
    leave_start DATE NOT NULL,
    leave_end DATE NOT NULL
);
GO
select * from hr.Angajat
-------------
/*aici am ajuns*/
/*
Example load commands after you put CSV files in a folder visible to SQL Server:*/
/*
BULK INSERT stage.Absence_Input
FROM 'C:\Users\tmartisca\OneDrive - ENDAVA\Documents\SQL Server Management Studio 21\absences.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

BULK INSERT stage.Training_Attendance
FROM 'C:\temp\training.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT stage.Leave
FROM 'C:\temp\leave.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
*/

/* Demo inserts so the script works even without BULK INSERT 
INSERT INTO stage.Absence_Input (employee_mail, absence_date, missing_hours, absence_type_code, reason)
VALUES
('alex.ionescu@email.com',     '2025-05-07', 2.00, 'FAC', 'Examen universitar'),
('maria.popescu@email.com',    '2025-05-09', 3.00, 'FAC', 'Curs facultate'),
('dan.vasilescu@email.com',    '2025-05-10', 1.00, 'PER', 'Problema personala'),
('ioana.stan@email.com',       '2025-05-10', 2.00, 'OTH', 'Acte administrative'),
('andrei.marin@email.com',     '2025-05-12', 4.00, 'FAC', 'Sesiune facultate'),
('elena.georgescu@email.com',  '2025-05-08', 1.00, 'PER', 'Consult medical');
GO

INSERT INTO stage.Training_Attendance (employee_mail, employee_name, training_name, session_date, first_join, last_leave, in_meeting_duration, role)
VALUES
('ion.popescu@email.com',       'Ion Popescu',       'SQL Performance Basics', '2025-05-09', '2025-05-09 10:00:00', '2025-05-09 11:25:30', '1h 25m 30s', 'presenter'),
('mihai.popa@email.com',        'Mihai Popa',        'SQL Performance Basics', '2025-05-09', '2025-05-09 10:02:00', '2025-05-09 11:20:13', '1h 18m 13s', 'participant'),
('elena.georgescu@email.com',   'Elena Georgescu',   'SQL Performance Basics', '2025-05-09', '2025-05-09 10:01:00', '2025-05-09 11:22:06', '1h 21m 6s',  'participant'),
('alex.ionescu@email.com',      'Alex Ionescu',      'ETL Introduction',       '2025-05-12', '2025-05-12 14:00:00', '2025-05-12 15:10:00', '1h 10m 0s',  'participant'),
('maria.popescu@email.com',     'Maria Popescu',     'ETL Introduction',       '2025-05-12', '2025-05-12 14:03:00', '2025-05-12 15:05:00', '1h 2m 0s',   'participant'),
('dan.vasilescu@email.com',     'Dan Vasilescu',     'ETL Introduction',       '2025-05-12', '2025-05-12 14:00:00', '2025-05-12 15:12:30', '1h 12m 30s', 'participant'),
('ioana.stan@email.com',        'Ioana Stan',        'ETL Introduction',       '2025-05-12', '2025-05-12 14:05:00', '2025-05-12 15:09:00', '1h 4m 0s',   'participant');
GO
*/
/* =========================================================
   6. Data warehouse fact table
   One row = one employee + one date + one activity
   ========================================================= */
   /*
   ================
   used the wizard instead:
   stage.imp_absences
   stage.imp_leave
   stage.imp_training
   ================
   */
   CREATE UNIQUE INDEX IX_Angajat_Mail
ON hr.Angajat(mail);
CREATE INDEX IX_TrainingAttendance_EmployeeMail
ON stage.imp_training(mail_angajat);


CREATE INDEX IX_Absences_EmployeeMail
ON stage.imp_absences(employee_mail);

CREATE INDEX IX_Leaves_EmployeeMail
ON stage.imp_leave(mail);

CREATE TABLE dw.Fact_EmployeeActivity (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,
    idAngajat INT NOT NULL,
    activity_date DATE NOT NULL,
    activity_type_code VARCHAR(20) NOT NULL,
    project_id INT NULL,
    training_id INT NULL,
    absence_type_code VARCHAR(10) NULL,
    worked_hours DECIMAL(6,2) NOT NULL DEFAULT 0,
    missing_hours DECIMAL(6,2) NOT NULL DEFAULT 0,
    training_minutes INT NOT NULL DEFAULT 0,
    source_system VARCHAR(30) NOT NULL,
    notes VARCHAR(255) NULL,

    CONSTRAINT FK_Fact_Employee 
        FOREIGN KEY (idAngajat) REFERENCES hr.Angajat(idAngajat),

    CONSTRAINT FK_Fact_Project 
        FOREIGN KEY (project_id) REFERENCES work.Proiect(idProiect),

    CONSTRAINT FK_Fact_Training 
        FOREIGN KEY (training_id) REFERENCES ref.Training(training_id),

    CONSTRAINT FK_Fact_AbsenceType 
        FOREIGN KEY (absence_type_code) REFERENCES ref.AbsenceType(absence_type_code),

    CONSTRAINT FK_Fact_ActivityType 
        FOREIGN KEY (activity_type_code) REFERENCES ref.ActivityType(activity_type_code)
);
GO

CREATE INDEX idx_fact_employee_date ON dw.Fact_EmployeeActivity(idAngajat, activity_date);
GO

/* =========================================================
   7. ETL : prepare training lookup values
   ========================================================= */
INSERT INTO ref.Training (training_name, session_date)
SELECT DISTINCT s.training_sesion, s.date
FROM stage.imp_training s
WHERE NOT EXISTS (
    SELECT 1
    FROM ref.Training t
    WHERE t.training_name = s.training_sesion
      AND t.session_date = s.date
);
GO

/* =========================================================
   8. ETL : load worked hours from existing timesheets
   ========================================================= */
INSERT INTO dw.Fact_EmployeeActivity
    (idAngajat, activity_date, activity_type_code, project_id, training_id, absence_type_code,
     worked_hours, missing_hours, training_minutes, source_system, notes)
SELECT
    t.idAngajat,
    t.dataPontaj,
    'WORK',
    e.idProiect,
    NULL,
    NULL,
    e.ore,
    0,
    0,
    'TIMESHEET',
    e.descriere
FROM work.TimesheetEntry e
JOIN work.Timesheet t
    ON t.idTimesheet = e.idTimesheet;
GO

/* =========================================================
   9. ETL : load absences from CSV staging
   Integration key: employee_mail -> hr.Angajat.mail
   ========================================================= */
INSERT INTO dw.Fact_EmployeeActivity
    (idAngajat, activity_date, activity_type_code, project_id, training_id, absence_type_code,
     worked_hours, missing_hours, training_minutes, source_system, notes)
SELECT
    a.idAngajat,
    s.absence_date,
    'ABSENCE',
    NULL,
    NULL,
    s.absence_type_code,
    0,
    s.missing_hours,
    0,
    'ABSENCE_CSV',
    s.reason
FROM stage.imp_absences s
JOIN hr.Angajat a
    ON a.mail = s.employee_mail
WHERE NOT EXISTS (
    SELECT 1
    FROM dw.Fact_EmployeeActivity f
    WHERE f.idAngajat = a.idAngajat
      AND f.activity_date = s.absence_date
      AND f.activity_type_code = 'ABSENCE'
      AND f.absence_type_code = s.absence_type_code
      AND f.missing_hours = s.missing_hours
);
GO
select * from stage.imp_training;
/* =========================================================
   ETL : load training from CSV staging
   Convert text duration like 1h 25m 30s to minutes
   ========================================================= */
INSERT INTO dw.Fact_EmployeeActivity
    (idAngajat, activity_date, activity_type_code, project_id, training_id, absence_type_code,
     worked_hours, missing_hours, training_minutes, source_system, notes)
SELECT
    a.idAngajat,
    s.date,
    'TRAINING',
    NULL,
    t.training_id,
    NULL,
    0,
    0,
    DATEDIFF(MINUTE, s.log_on, s.log_off),
    'TRAINING_CSV',
    CONCAT(ISNULL(s.role, 'participant'), ' - duration text: ', s.in_meeting_time)
FROM stage.imp_training s
JOIN hr.Angajat a
    ON a.mail = s.mail_angajat
JOIN ref.Training t
    ON t.training_name = s.training_sesion
   AND t.session_date = s.date
WHERE NOT EXISTS (
    SELECT 1
    FROM dw.Fact_EmployeeActivity f
    WHERE f.idAngajat = a.idAngajat
      AND f.activity_date = s.date
      AND f.activity_type_code = 'TRAINING'
      AND f.training_id = t.training_id
);
GO

/* =========================================================
    Useful views and reports
   ========================================================= */
CREATE OR ALTER VIEW work.vw_ActivitateDetaliata AS
SELECT
    a.nume AS nume_angajat,
    t.dataPontaj,
    p.nume AS nume_proiect,
    e.startTime,
    e.endTime,
    e.ore,
    e.descriere
FROM work.TimesheetEntry e
JOIN work.Timesheet t ON e.idTimesheet = t.idTimesheet
JOIN hr.Angajat a ON t.idAngajat = a.idAngajat
JOIN work.Proiect p ON e.idProiect = p.idProiect;
GO

CREATE OR ALTER VIEW work.vw_TotalOreAngajat AS
SELECT
    a.idAngajat,
    a.nume,
    SUM(e.ore) AS total_ore
FROM work.TimesheetEntry e
JOIN work.Timesheet t ON e.idTimesheet = t.idTimesheet
JOIN hr.Angajat a ON t.idAngajat = a.idAngajat
GROUP BY a.idAngajat, a.nume;
GO

/* Daily integrated report */
SELECT
    a.nume,
    f.activity_date,
    f.activity_type_code,
    p.nume AS proiect,
    tr.training_name,
    ab.absence_type_name,
    f.worked_hours,
    f.training_minutes,
    f.missing_hours,
    f.source_system,
    f.notes
FROM dw.Fact_EmployeeActivity f
JOIN hr.Angajat a ON a.idAngajat = f.idAngajat
LEFT JOIN work.Proiect p ON p.idProiect = f.project_id
LEFT JOIN ref.Training tr ON tr.training_id = f.training_id
LEFT JOIN ref.AbsenceType ab ON ab.absence_type_code = f.absence_type_code
ORDER BY f.activity_date, a.nume, f.activity_type_code;
GO

/* Monthly aggregate report */
SELECT
    a.nume,
    YEAR(f.activity_date) AS an,
    MONTH(f.activity_date) AS luna,
    SUM(f.worked_hours) AS total_worked_hours,
    SUM(f.training_minutes) AS total_training_minutes,
    SUM(f.missing_hours) AS total_missing_hours
FROM dw.Fact_EmployeeActivity f
JOIN hr.Angajat a ON a.idAngajat = f.idAngajat
GROUP BY a.nume, YEAR(f.activity_date), MONTH(f.activity_date)
ORDER BY a.nume, an, luna;
GO

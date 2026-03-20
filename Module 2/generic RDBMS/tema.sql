CREATE DATABASE TimesheetDB;
GO

USE TimesheetDB;
GO

CREATE SCHEMA hr;
GO

CREATE SCHEMA work;
GO

CREATE SCHEMA ref;
GO

CREATE TABLE hr.Angajat (
    idAngajat INT IDENTITY(1,1) PRIMARY KEY,
    manager INT NULL,
    cnp CHAR(13) NOT NULL,
    telefon VARCHAR(15) NOT NULL,
    mail VARCHAR(100) NOT NULL,
    nume VARCHAR(100) NOT NULL,

    CONSTRAINT UQ_Angajat_CNP UNIQUE (cnp), --constraint unic
    CONSTRAINT UQ_Angajat_Mail UNIQUE (mail), --constraint unic
    CONSTRAINT CHK_Angajat_CNP CHECK (LEN(cnp) = 13), --constraint de corectitudine cnp
    CONSTRAINT FK_Angajat_Manager FOREIGN KEY (manager)
        REFERENCES hr.Angajat(idAngajat)
);
GO

-- Tabel Clienti
CREATE TABLE ref.Client(
    idClient INT IDENTITY(1,1) PRIMARY KEY,
    nume VARCHAR(200) NOT NULL,
    detalii VARCHAR(255) NULL,
);
GO


-- Tabel locatii
CREATE TABLE ref.Locatie (
    idLocatie INT IDENTITY(1,1) PRIMARY KEY,
    adresa VARCHAR(200) NOT NULL,
    detalii VARCHAR(255) NULL
);
GO


-- Tabel proiecte
CREATE TABLE work.Proiect (
    idProiect INT IDENTITY(1,1) PRIMARY KEY,
    manager INT NOT NULL,
    idClient INT NOT NULL,
    nume VARCHAR(100) NOT NULL,
    detalii VARCHAR(255) NULL,

    CONSTRAINT FK_Proiect_Manager FOREIGN KEY (manager)
        REFERENCES hr.Angajat(idAngajat),

    CONSTRAINT FK_Proiect_Client FOREIGN KEY (idClient)
        REFERENCES ref.Client(idClient)
);
GO


-- Tabel timesheet
-- Reprezinta ziua de lucru a unui angajat
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

    CONSTRAINT CHK_Timesheet_Interval CHECK (endZi > startZi)-- constraint logic
);
GO


-- Tabel timesheet entry
-- Reprezinta activitatile efective dintr-un timesheet
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

--ce am facut pana acum
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS

-- indecsi
--CREATE INDEX index_name ON TABLE column;
CREATE INDEX idx_angajat_mail on hr.Angajat(mail)
CREATE INDEX idx_angajat_nume on hr.Angajat(nume)

SELECT DB_NAME();

USE TimesheetDB;
GO

--verificare mail
ALTER TABLE hr.Angajat
ADD CONSTRAINT CK_Angajat_Mail CHECK (mail LIKE '%@%.%');
--populam
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


SELECT * from hr.Angajat;

ALTER TABLE ref.Client
ALTER COLUMN detalii NVARCHAR(MAX);--date JSON

INSERT INTO ref.Client (nume, detalii)
VALUES 
('Endava', '{"tara":"UK","industrie":"IT","nr_angajati":10000}'),
('Google', '{"tara":"USA","industrie":"Tech","produse":["Search","Cloud","AI"]}'),
('Amazon', '{"tara":"USA","industrie":"E-commerce","servicii":["AWS","Retail"]}'),
('Microsoft', '{"tara":"USA","industrie":"Software","produse":["Azure","Office"]}'),
('Oracle', '{"tara":"USA","industrie":"Database","focus":"enterprise"}');

INSERT INTO ref.Locatie (adresa)
VALUES
('Bucruresti, strada Unirii, nr 3'),
('Timisoara, strada Cometei, nr 33'),
('Cluj, strada 2 iunie, nr 333'),
('Brasov, strada Lunga, nr 3333');

INSERT INTO work.Proiect (manager, idClient, nume, detalii)
VALUES
(1, 1, 'Platforma Banking', '{"tip":"web","tehnologie":"Java","durata_luni":12}'),
(2, 2, 'Aplicatie Mobile', '{"tip":"mobile","tehnologie":"Kotlin","durata_luni":8}'),
(1, 3, 'Sistem E-commerce', '{"tip":"web","tehnologie":"React","durata_luni":10}'),
(3, 4, 'Platforma Cloud', '{"tip":"cloud","tehnologie":"Azure","durata_luni":15}'),
(2, 5, 'Dashboard Analytics', '{"tip":"BI","tehnologie":"PowerBI","durata_luni":6}');

INSERT INTO work.Timesheet (idAngajat, dataPontaj, startZi, endZi, idLocatie)
VALUES
(1, '2025-05-07', '08:00', '16:00', 1),
(2, '2025-05-07', '09:00', '17:00', 1),
(3, '2025-05-07', '08:30', '16:30', 2),
(1, '2025-05-08', '08:00', '16:00', 1),
(2, '2025-05-08', '09:00', '17:00', 2);

INSERT INTO work.TimesheetEntry 
(idTimesheet, idProiect, startTime, endTime, ore, descriere, details)
VALUES
(1, 1, '08:00', '10:00', 2, 'Dezvoltare modul login',
 '{"task":"development","complexity":"medium","tools":["Spring"]}'),

(1, 2, '10:00', '16:00', 6, 'Implementare UI',
 '{"task":"frontend","complexity":"high","tools":["Angular"]}'),

(2, 3, '09:00', '12:00', 3, 'Fix bug-uri',
 '{"task":"bugfix","priority":"high"}'),

(2, 5, '13:00', '17:00', 4, 'Creare rapoarte',
 '{"task":"reporting","tool":"PowerBI"}'),

(3, 4, '08:30', '16:30', 8, 'Configurare infrastructura',
 '{"task":"devops","platform":"Azure","complexity":"high"}');


 --view uri

 --la ce proiecte a lucreza angajatii, si cate ire si ce fac
CREATE VIEW work.vw_ActivitateDetaliata AS
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

SELECT * FROM work.vw_ActivitateDetaliata;

INSERT INTO work.Timesheet (idAngajat, dataPontaj, startZi, endZi, idLocatie)
VALUES
(4, '2025-05-07', '08:00', '16:00', 1),
(4, '2025-05-08', '09:00', '17:00', 2),
(5, '2025-05-06', '08:00', '16:00', 3),
(6, '2025-05-10', '09:00', '17:00', 3),
(7, '2025-05-10', '08:00', '16:00', 4),
(7, '2025-05-11', '08:00', '16:00', 4),
(7, '2025-05-12', '09:00', '17:00', 4);

SELECT * from work.Timesheet t LEFT JOIN work.TimesheetEntry e ON e.idProiect=t.idTimesheet;

INSERT INTO work.TimesheetEntry 
(idTimesheet, idProiect, startTime, endTime, ore, descriere, details)
VALUES
(6, 1, '08:00', '10:00', 2, 'Dezvoltare modul login',
 '{"task":"development","complexity":"medium","tools":["Spring"]}'),

(6, 2, '10:00', '16:00', 6, 'Implementare UI',
 '{"task":"frontend","complexity":"high","tools":["Angular"]}'),

(7, 3, '09:00', '12:00', 3, 'Fix bug-uri',
 '{"task":"bugfix","priority":"high"}'),

(8, 5, '13:00', '17:00', 4, 'Creare rapoarte',
 '{"task":"reporting","tool":"PowerBI"}'),
 (8, 4, '17:00', '18:00', 4, 'Creare rapoarte',
 '{"task":"reporting","tool":"PowerBI"}'),

 (10, 1, '08:00', '10:00', 2, 'Dezvoltare modul login',
 '{"task":"development","complexity":"medium","tools":["Spring"]}'),

(10, 2, '10:00', '16:00', 6, 'Implementare UI',
 '{"task":"frontend","complexity":"high","tools":["Angular"]}'),

(11, 3, '09:00', '12:00', 3, 'Fix bug-uri',
 '{"task":"bugfix","priority":"high"}'),

(11, 5, '13:00', '17:00', 4, 'Creare rapoarte',
 '{"task":"reporting","tool":"PowerBI"}'),

(12, 4, '08:30', '16:30', 8, 'Configurare infrastructura',
 '{"task":"devops","platform":"Azure","complexity":"high"}');

 CREATE VIEW work.vw_TotalOreAngajat
WITH SCHEMABINDING
AS
SELECT 
    a.idAngajat,
    a.nume,
    SUM(e.ore) AS total_ore,
    COUNT_BIG(*) AS nr_inregistrari
FROM work.TimesheetEntry e
JOIN work.Timesheet t ON e.idTimesheet = t.idTimesheet
JOIN hr.Angajat a ON t.idAngajat = a.idAngajat
GROUP BY a.idAngajat, a.nume;
GO

CREATE UNIQUE CLUSTERED INDEX IX_vw_TotalOreAngajat
ON work.vw_TotalOreAngajat(idAngajat);

-- Afiseaza totalul orelor lucrate de fiecare angajat
SELECT 
    a.idAngajat,
    a.nume,
    SUM(e.ore) AS total_ore
FROM work.TimesheetEntry e
JOIN work.Timesheet t ON e.idTimesheet = t.idTimesheet
JOIN hr.Angajat a ON t.idAngajat = a.idAngajat
GROUP BY a.idAngajat, a.nume;

--analytic function
-- Afiseaza fiecare activitate si totalul orelor lucrate de angajatul respectiv
SELECT 
    a.idAngajat,
    a.nume,
    t.dataPontaj,
    e.ore,
    SUM(e.ore) OVER (PARTITION BY a.idAngajat) AS total_ore_angajat
FROM work.TimesheetEntry e
JOIN work.Timesheet t ON e.idTimesheet = t.idTimesheet
JOIN hr.Angajat a ON t.idAngajat = a.idAngajat;

-- Afiseaza media orelor per activitate pentru fiecare angajat
SELECT 
    a.nume,
    e.ore,
    AVG(e.ore) OVER (PARTITION BY a.idAngajat) AS medie_ore
FROM work.TimesheetEntry e
JOIN work.Timesheet t ON e.idTimesheet = t.idTimesheet
JOIN hr.Angajat a ON t.idAngajat = a.idAngajat;

-- Afiseaza fiecare activitate si totalul cumulativ al orelor lucrate de fiecare angajat,
-- in ordinea zilei si a orei de inceput
SELECT 
    a.idAngajat,
    a.nume,
    t.dataPontaj,
    e.startTime,
    e.endTime,
    e.ore,
    SUM(e.ore) OVER (
        PARTITION BY a.idAngajat
        ORDER BY t.dataPontaj, e.startTime
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS total_cumulativ_ore
FROM work.TimesheetEntry e
JOIN work.Timesheet t 
    ON e.idTimesheet = t.idTimesheet
JOIN hr.Angajat a 
    ON t.idAngajat = a.idAngajat;
-- ============================================================
--  HospitalDB  |  SQL Server (T-SQL) Version
-- ============================================================

-- ── DATABASE ─────────────────────────────────────────────────
CREATE DATABASE HospitalDB;
GO
USE HospitalDB;
GO

-- ════════════════════════════════════════════════════════════
--  DDL  –  Table Definitions
-- ════════════════════════════════════════════════════════════

-- 1. Hospital Table
--    Composite address: Colony + City + Zip
CREATE TABLE Hospital (
    Hos_ID   INT           PRIMARY KEY,
    Hos_Name VARCHAR(100),
    Contact  VARCHAR(20),
    Colony   VARCHAR(50),   -- Composite: Colony
    City     VARCHAR(50),   -- Composite: City
    Zip      VARCHAR(10)    -- Composite: Zip
);
GO

-- 2. Doctors Table
--    Disjoint rule enforced via CHECK constraint
--    (ENUM does not exist in SQL Server)
CREATE TABLE Doctors (
    Doc_ID  INT          PRIMARY KEY,
    D_Name  VARCHAR(100),
    D_Phone VARCHAR(20),
    D_Type  VARCHAR(20)  NOT NULL
               CONSTRAINT CHK_Doctor_Type
               CHECK (D_Type IN ('Trainee', 'Visiting', 'Permanent')),  -- replaces ENUM
    Hos_ID  INT,
    CONSTRAINT FK_Doctors_Hospital FOREIGN KEY (Hos_ID)
        REFERENCES Hospital(Hos_ID)
);
GO

-- 3. Patients Table
--    D_O_B stored for Derived Attribute 'Age' (calculated via UDF)
CREATE TABLE Patients (
    P_ID    INT          PRIMARY KEY,
    P_Name  VARCHAR(100),
    D_O_B   DATE,                    -- used to derive Age
    Gender  VARCHAR(10),
    Colony  VARCHAR(50),
    City    VARCHAR(50),
    Zip     VARCHAR(10)
);
GO

-- 4. Patient_Phones  (Multivalued Attribute)
CREATE TABLE Patient_Phones (
    P_ID     INT,
    Phone_No VARCHAR(20),
    CONSTRAINT PK_Patient_Phones PRIMARY KEY (P_ID, Phone_No),
    CONSTRAINT FK_PatPhones_Patient FOREIGN KEY (P_ID)
        REFERENCES Patients(P_ID)
);
GO

-- 5. Receptionist Table
CREATE TABLE Receptionist (
    Rec_ID INT          PRIMARY KEY,
    R_Name VARCHAR(100),
    Hos_ID INT,
    CONSTRAINT FK_Receptionist_Hospital FOREIGN KEY (Hos_ID)
        REFERENCES Hospital(Hos_ID)
);
GO

-- 6. Records Table
--    DATETIME is valid in SQL Server (no change needed)
CREATE TABLE Records (
    Record_NO   INT           PRIMARY KEY,
    Appointment DATETIME,
    Description NVARCHAR(MAX),   -- TEXT → NVARCHAR(MAX)
    P_ID        INT,
    Rec_ID      INT,
    CONSTRAINT FK_Records_Patient      FOREIGN KEY (P_ID)
        REFERENCES Patients(P_ID),
    CONSTRAINT FK_Records_Receptionist FOREIGN KEY (Rec_ID)
        REFERENCES Receptionist(Rec_ID)
);
GO

-- 7. Medical Tests Table
--    AUTO_INCREMENT → IDENTITY(1,1)
--    TEXT           → NVARCHAR(MAX)
CREATE TABLE Medical_Tests (
    Test_ID      INT           IDENTITY(1,1) PRIMARY KEY,  -- replaces AUTO_INCREMENT
    P_ID         INT,
    Blood_Test   VARCHAR(50),
    Test_Details NVARCHAR(MAX),  -- replaces TEXT
    Diagnosis    NVARCHAR(MAX),  -- replaces TEXT
    Test_Date    DATE,
    CONSTRAINT FK_MedTests_Patient FOREIGN KEY (P_ID)
        REFERENCES Patients(P_ID)
);
GO

-- 8. Doctor_Patient  (Many-to-Many Relationship)
CREATE TABLE Doctor_Patient (
    Doc_ID INT,
    P_ID   INT,
    CONSTRAINT PK_Doctor_Patient PRIMARY KEY (Doc_ID, P_ID),
    CONSTRAINT FK_DP_Doctor  FOREIGN KEY (Doc_ID) REFERENCES Doctors(Doc_ID),
    CONSTRAINT FK_DP_Patient FOREIGN KEY (P_ID)   REFERENCES Patients(P_ID)
);
GO


-- ════════════════════════════════════════════════════════════
--  DML  –  Insert Statements
-- ════════════════════════════════════════════════════════════

-- ── Hospital (50 rows) ───────────────────────────────────────
INSERT INTO Hospital VALUES
(1,  'City General Hospital',    '042-3555123', 'Model Town',   'Lahore',    '54000'),
(2,  'Shaukat Khanum Hospital',  '042-3571111', 'Johar Town',   'Lahore',    '54770'),
(3,  'Jinnah Hospital',          '042-9920021', 'Jail Road',    'Lahore',    '54550'),
(4,  'Services Hospital',        '042-9923311', 'Shadman',      'Lahore',    '54000'),
(5,  'Aga Khan Hospital',        '021-3486114', 'Stadium Road', 'Karachi',   '74800'),
(6,  'PIMS Hospital',            '051-9261170', 'G-8/3',        'Islamabad', '44000'),
(7,  'Holy Family Hospital',     '051-9290301', 'Satellite Twn','Rawalpindi','46000'),
(8,  'CMH Lahore',               '042-9201111', 'Cantt',        'Lahore',    '54810'),
(9,  'Ittefaq Hospital',         '042-3578901', 'Model Town',   'Lahore',    '54700'),
(10, 'Doctors Hospital',         '042-3591234', 'Canal Bank',   'Lahore',    '54660'),
(11, 'Mayo Hospital',            '042-9921011', 'Anarkali',     'Lahore',    '54000'),
(12, 'Gulab Devi Hospital',      '042-3774001', 'Ferozepur Rd', 'Lahore',    '54600'),
(13, 'DHQ Hospital Multan',      '061-9200401', 'Kutchery Rd',  'Multan',    '60000'),
(14, 'Nishtar Hospital',         '061-9200001', 'Nishtar Rd',   'Multan',    '66000'),
(15, 'Civil Hospital Karachi',   '021-9921601', 'Karachi Cantt','Karachi',   '74200'),
(16, 'Liaquat National Hosp',    '021-3412001', 'Stadium Rd',   'Karachi',   '74800'),
(17, 'Lady Reading Hospital',    '091-9212991', 'Khyber Rd',    'Peshawar',  '25000'),
(18, 'Hayatabad Medical Cmplx',  '091-9218300', 'Hayatabad',    'Peshawar',  '25100'),
(19, 'Allied Hospital',          '041-9200261', 'Jail Rd',      'Faisalabad','38000'),
(20, 'DHQ Hospital Faisalabad',  '041-9200101', 'Kutchery Baz', 'Faisalabad','38000'),
(21, 'Benazir Bhutto Hospital',  '051-9290401', 'Murree Rd',    'Rawalpindi','46000'),
(22, 'Bahawal Victoria Hospital','062-9255001', 'Hospital Rd',  'Bahawalpur','63100'),
(23, 'Civil Hospital Quetta',    '081-9201201', 'Zarghoon Rd',  'Quetta',    '87300'),
(24, 'Bolan Medical Complex',    '081-9202301', 'Brewery Rd',   'Quetta',    '87300'),
(25, 'Sheikh Zayed Hospital',    '042-9923001', 'Canal Rd',     'Lahore',    '54600'),
(26, 'Farooq Hospital',          '042-3578001', 'West Canal Rd','Lahore',    '54770'),
(27, 'Hameed Latif Hospital',    '042-3570001', 'Abu Bakar Blk','Lahore',    '54660'),
(28, 'Omar Hospital',            '042-3521001', 'Cavalry Grnd', 'Lahore',    '54810'),
(29, 'Excel Labs Hospital',      '042-3573001', 'DHA Phase 5',  'Lahore',    '54792'),
(30, 'Chaudhry Hospital',        '041-2630001', 'Ghulam Muhmd', 'Faisalabad','38040'),
(31, 'Rehman Medical Inst',      '091-5842001', 'Phase 5 Hayat','Peshawar',  '25120'),
(32, 'Northwest General Hosp',   '091-5840001', 'Phase 4 Hayat','Peshawar',  '25110'),
(33, 'Mardan Medical Complex',   '0937-870001', 'Mardan Cantt', 'Mardan',    '23200'),
(34, 'Khyber Teaching Hospital', '091-9211501', 'Dalazak Rd',   'Peshawar',  '25000'),
(35, 'Chandka Medical College',  '074-9310001', 'Larkana City', 'Larkana',   '77150'),
(36, 'Liaquat Univ Hospital',    '022-9213001', 'Unit 9',       'Hyderabad', '71000'),
(37, 'Civil Hospital Hyderabad', '022-9200501', 'Hirabad',      'Hyderabad', '71000'),
(38, 'Abbasi Shaheed Hospital',  '021-9921301', 'SITE Area',    'Karachi',   '75700'),
(39, 'Ziauddin Hospital',        '021-3682001', 'Clifton',      'Karachi',   '75600'),
(40, 'South City Hospital',      '021-3587001', 'Bath Island',  'Karachi',   '75530'),
(41, 'Tabba Heart Institute',    '021-3587501', 'Karachi Cantt','Karachi',   '74200'),
(42, 'Indus Hospital',           '021-3527001', 'Korangi',      'Karachi',   '74900'),
(43, 'National Medical Centre',  '021-3480001', 'Gulshan-e-Iq', 'Karachi',   '75300'),
(44, 'United Medical Centre',    '051-2890001', 'Blue Area',    'Islamabad', '44000'),
(45, 'Shifa Int Hospital',       '051-8463000', 'Pitras Bukhari','Islamabad', '44000'),
(46, 'Care Hospital',            '051-2344001', 'G-10 Markaz',  'Islamabad', '44000'),
(47, 'Quaid-e-Azam Intl Hosp',   '051-2314001', 'G-11 Markaz',  'Islamabad', '44000'),
(48, 'Poly Clinic Hospital',     '051-9218200', 'G-6/2',        'Islamabad', '44000'),
(49, 'Pakistan Railway Hospital','051-9215001', 'Golra Rd',     'Rawalpindi','46300'),
(50, 'Fatima Memorial Hospital', '042-3571001', 'Shadman II',   'Lahore',    '54000');
GO

-- ── Patients (50 rows) ──────────────────────────────────────
INSERT INTO Patients (P_ID, P_Name, D_O_B, Gender, Colony, City, Zip) VALUES
(1,  'Ali Ahmed',        '1990-05-12', 'Male',   'Gulberg',       'Lahore',    '54660'),
(2,  'Sara Khan',        '1985-11-20', 'Female', 'DHA Phase 5',   'Karachi',   '75500'),
(3,  'Usman Tariq',      '1992-03-08', 'Male',   'Model Town',    'Lahore',    '54700'),
(4,  'Fatima Noor',      '1998-07-25', 'Female', 'F-8/2',         'Islamabad', '44000'),
(5,  'Hamza Malik',      '1987-12-01', 'Male',   'Johar Town',    'Lahore',    '54770'),
(6,  'Ayesha Siddiqui',  '2000-09-14', 'Female', 'Gulshan-e-Iq',  'Karachi',   '75300'),
(7,  'Bilal Raza',       '1995-04-22', 'Male',   'G-9 Markaz',    'Islamabad', '44000'),
(8,  'Hira Baig',        '1993-06-17', 'Female', 'Samanabad',     'Lahore',    '54500'),
(9,  'Tariq Mehmood',    '1980-01-30', 'Male',   'Satellite Twn', 'Rawalpindi','46000'),
(10, 'Nadia Hussain',    '1989-08-05', 'Female', 'Hayatabad',     'Peshawar',  '25100'),
(11, 'Kamran Sheikh',    '1975-02-18', 'Male',   'Clifton',       'Karachi',   '75600'),
(12, 'Sana Butt',        '2001-10-09', 'Female', 'Wapda Town',    'Lahore',    '54770'),
(13, 'Faisal Iqbal',     '1983-03-27', 'Male',   'Blue Area',     'Islamabad', '44000'),
(14, 'Maryam Zahid',     '1997-05-31', 'Female', 'DHA Phase 2',   'Lahore',    '54792'),
(15, 'Asad Rauf',        '1991-11-15', 'Male',   'Gulberg III',   'Lahore',    '54660'),
(16, 'Rabia Anwar',      '1986-07-04', 'Female', 'Pechs',         'Karachi',   '75400'),
(17, 'Imran Ashraf',     '1978-09-22', 'Male',   'Cantt',         'Lahore',    '54810'),
(18, 'Zainab Ali',       '2003-12-11', 'Female', 'G-10/1',        'Islamabad', '44000'),
(19, 'Naeem Baig',       '1969-04-07', 'Male',   'Ferozepur Rd',  'Lahore',    '54600'),
(20, 'Lubna Farooq',     '1994-06-28', 'Female', 'Korangi',       'Karachi',   '74900'),
(21, 'Shahid Nazir',     '1982-08-16', 'Male',   'Shadman',       'Lahore',    '54000'),
(22, 'Amna Riaz',        '1999-01-03', 'Female', 'Phase 4 Hayat', 'Peshawar',  '25110'),
(23, 'Umer Farhan',      '1996-03-19', 'Male',   'Stadium Rd',    'Karachi',   '74800'),
(24, 'Saima Perveen',    '1988-10-23', 'Female', 'Anarkali',      'Lahore',    '54000'),
(25, 'Junaid Hassan',    '1973-05-08', 'Male',   'Jail Road',     'Lahore',    '54550'),
(26, 'Mehwish Akram',    '2002-02-14', 'Female', 'G-11 Markaz',   'Islamabad', '44000'),
(27, 'Rizwan Qureshi',   '1990-07-07', 'Male',   'Nishtar Rd',    'Multan',    '66000'),
(28, 'Sadia Khalid',     '1984-09-30', 'Female', 'Canal Bank',    'Lahore',    '54660'),
(29, 'Adnan Mirza',      '1977-12-25', 'Male',   'Cavalry Grnd',  'Lahore',    '54810'),
(30, 'Rukhsar Bibi',     '2004-04-18', 'Female', 'DHA Phase 6',   'Lahore',    '54792'),
(31, 'Waseem Aktar',     '1981-06-02', 'Male',   'Unit 9',        'Hyderabad', '71000'),
(32, 'Iram Shaheen',     '1993-08-14', 'Female', 'Gulshan-e-Ravi','Lahore',    '54700'),
(33, 'Zubair Nawaz',     '1985-11-29', 'Male',   'Ghulam Muhmd',  'Faisalabad','38040'),
(34, 'Haleema Yousaf',   '1998-01-06', 'Female', 'Hirabad',       'Hyderabad', '71000'),
(35, 'Shehzad Amir',     '1970-03-21', 'Male',   'Zarghoon Rd',   'Quetta',    '87300'),
(36, 'Noor Fatima',      '2000-05-17', 'Female', 'G-8/3',         'Islamabad', '44000'),
(37, 'Khurram Shahzad',  '1992-07-09', 'Male',   'Pechs Block 2', 'Karachi',   '75400'),
(38, 'Madiha Akhtar',    '1987-10-03', 'Female', 'Abu Bakar Blk', 'Lahore',    '54660'),
(39, 'Salman Yaqoob',    '1979-12-19', 'Male',   'Dalazak Rd',    'Peshawar',  '25000'),
(40, 'Tahira Shabbir',   '1995-02-26', 'Female', 'Murree Rd',     'Rawalpindi','46000'),
(41, 'Babar Zaman',      '1983-04-13', 'Male',   'Johar Town B2', 'Lahore',    '54770'),
(42, 'Asma Javed',       '1996-06-08', 'Female', 'Bath Island',   'Karachi',   '75530'),
(43, 'Naveed Awan',      '1974-08-24', 'Male',   'Shadman II',    'Lahore',    '54000'),
(44, 'Iqra Saleem',      '2001-11-12', 'Female', 'G-6/2',         'Islamabad', '44000'),
(45, 'Furqan Ghani',     '1988-01-27', 'Male',   'Wapda Town B2', 'Lahore',    '54770'),
(46, 'Sumbal Taufiq',    '1991-03-15', 'Female', 'Korangi Crk',   'Karachi',   '74900'),
(47, 'Danish Umar',      '1976-05-03', 'Male',   'Khyber Rd',     'Peshawar',  '25000'),
(48, 'Fareeha Malik',    '1999-07-20', 'Female', 'Canal Rd',      'Lahore',    '54600'),
(49, 'Waqas Ilyas',      '1982-09-06', 'Male',   'Larkana City',  'Larkana',   '77150'),
(50, 'Zeeshan Khan',     '1998-02-15', 'Male',   'Sector F-7',    'Islamabad', '44000');
GO

-- ── Patient_Phones (50 rows – one per patient) ──────────────
INSERT INTO Patient_Phones (P_ID, Phone_No) VALUES
(1,  '0300-1234567'), (2,  '0321-2345678'), (3,  '0333-3456789'),
(4,  '0345-4567890'), (5,  '0301-5678901'), (6,  '0311-6789012'),
(7,  '0322-7890123'), (8,  '0334-8901234'), (9,  '0346-9012345'),
(10, '0302-0123456'), (11, '0312-1234567'), (12, '0323-2345678'),
(13, '0335-3456789'), (14, '0347-4567890'), (15, '0303-5678901'),
(16, '0313-6789012'), (17, '0324-7890123'), (18, '0336-8901234'),
(19, '0348-9012345'), (20, '0304-0123456'), (21, '0314-1234567'),
(22, '0325-2345678'), (23, '0337-3456789'), (24, '0349-4567890'),
(25, '0305-5678901'), (26, '0315-6789012'), (27, '0326-7890123'),
(28, '0338-8901234'), (29, '0341-9012345'), (30, '0306-0123456'),
(31, '0316-1234567'), (32, '0327-2345678'), (33, '0339-3456789'),
(34, '0342-4567890'), (35, '0307-5678901'), (36, '0317-6789012'),
(37, '0328-7890123'), (38, '0331-8901234'), (39, '0343-9012345'),
(40, '0308-0123456'), (41, '0318-1234567'), (42, '0329-2345678'),
(43, '0332-3456789'), (44, '0344-4567890'), (45, '0309-5678901'),
(46, '0319-6789012'), (47, '0361-7890123'), (48, '0362-8901234'),
(49, '0363-9012345'), (50, '0364-0123456');
GO

-- ── Receptionist (50 rows, linked to hospitals 1–50) ────────
INSERT INTO Receptionist (Rec_ID, R_Name, Hos_ID) VALUES
(201, 'Nazia Iqbal',      1),  (202, 'Sobia Mirza',     2),
(203, 'Tahir Mehmood',    3),  (204, 'Amina Bashir',    4),
(205, 'Farhan Butt',      5),  (206, 'Kiran Shehzad',   6),
(207, 'Raza Ul Haq',      7),  (208, 'Hina Gillani',    8),
(209, 'Asif Rehman',      9),  (210, 'Maira Ijaz',     10),
(211, 'Gohar Hussain',   11),  (212, 'Fiza Qadir',     12),
(213, 'Shahbaz Anwar',   13),  (214, 'Misbah Javed',   14),
(215, 'Usman Ghani',     15),  (216, 'Saira Karim',    16),
(217, 'Nasir Hayat',     17),  (218, 'Laila Nawab',    18),
(219, 'Arshad Waqas',    19),  (220, 'Nimra Aslam',    20),
(221, 'Khaled Mehmood',  21),  (222, 'Aqsa Tanveer',   22),
(223, 'Waqar Yusuf',     23),  (224, 'Shazia Altaf',   24),
(225, 'Fawad Khalil',    25),  (226, 'Bushra Nawaz',   26),
(227, 'Tauseef Ahmad',   27),  (228, 'Raheela Zia',    28),
(229, 'Mubasher Ali',    29),  (230, 'Nida Sarwar',    30),
(231, 'Ejaz Ul Islam',   31),  (232, 'Zara Yaqub',     32),
(233, 'Qasim Rauf',      33),  (234, 'Humera Hanif',   34),
(235, 'Zafar Abbas',     35),  (236, 'Samina Pervaiz', 36),
(237, 'Rehan Siddiq',    37),  (238, 'Mehreen Naz',    38),
(239, 'Saad Farooq',     39),  (240, 'Naila Rashid',   40),
(241, 'Bilal Tahir',     41),  (242, 'Ghazala Nisar',  42),
(243, 'Kamran Zulfiqar', 43),  (244, 'Shehla Awan',    44),
(245, 'Haroon Rasheed',  45),  (246, 'Fauzia Jabeen',  46),
(247, 'Aftab Alam',      47),  (248, 'Ruquia Zahoor',  48),
(249, 'Shafique Ullah',  49),  (250, 'Parveen Akhtar', 50);
GO

-- ── Doctors (50 rows, linked to hospitals 1–50) ─────────────
INSERT INTO Doctors (Doc_ID, D_Name, D_Phone, D_Type, Hos_ID) VALUES
(101, 'Dr. Usman Tariq',     '0300-1112223', 'Permanent', 1),
(102, 'Dr. Ayesha Malik',    '0321-4445556', 'Visiting',  2),
(103, 'Dr. Hamza Raza',      '0333-7778889', 'Trainee',   3),
(104, 'Dr. Sana Javed',      '0345-2223334', 'Permanent', 4),
(105, 'Dr. Bilal Nawaz',     '0301-3334445', 'Visiting',  5),
(106, 'Dr. Nadia Farhan',    '0311-4445556', 'Trainee',   6),
(107, 'Dr. Kamran Shah',     '0322-5556667', 'Permanent', 7),
(108, 'Dr. Zara Hussain',    '0334-6667778', 'Visiting',  8),
(109, 'Dr. Asad Mehmood',    '0346-7778889', 'Trainee',   9),
(110, 'Dr. Farah Iqbal',     '0302-8889990', 'Permanent', 10),
(111, 'Dr. Imran Butt',      '0312-9990001', 'Visiting',  11),
(112, 'Dr. Maryam Qureshi',  '0323-1112223', 'Trainee',   12),
(113, 'Dr. Faisal Anwar',    '0335-2223334', 'Permanent', 13),
(114, 'Dr. Hina Baig',       '0347-3334445', 'Visiting',  14),
(115, 'Dr. Shahid Rehman',   '0303-4445556', 'Trainee',   15),
(116, 'Dr. Lubna Mirza',     '0313-5556667', 'Permanent', 16),
(117, 'Dr. Rizwan Awan',     '0324-6667778', 'Visiting',  17),
(118, 'Dr. Amna Sheikh',     '0336-7778889', 'Trainee',   18),
(119, 'Dr. Naeem Gillani',   '0348-8889990', 'Permanent', 19),
(120, 'Dr. Tahira Karim',    '0304-9990001', 'Visiting',  20),
(121, 'Dr. Junaid Aslam',    '0314-1112223', 'Trainee',   21),
(122, 'Dr. Rabia Zahid',     '0325-2223334', 'Permanent', 22),
(123, 'Dr. Adnan Yousaf',    '0337-3334445', 'Visiting',  23),
(124, 'Dr. Iram Shabbir',    '0349-4445556', 'Trainee',   24),
(125, 'Dr. Waqas Gul',       '0305-5556667', 'Permanent', 25),
(126, 'Dr. Saima Nadeem',    '0315-6667778', 'Visiting',  26),
(127, 'Dr. Danish Saleem',   '0326-7778889', 'Trainee',   27),
(128, 'Dr. Iqra Perveen',    '0338-8889990', 'Permanent', 28),
(129, 'Dr. Furqan Hayat',    '0341-9990001', 'Visiting',  29),
(130, 'Dr. Sumbal Rauf',     '0306-1112223', 'Trainee',   30),
(131, 'Dr. Waseem Noor',     '0316-2223334', 'Permanent', 31),
(132, 'Dr. Khurram Arif',    '0327-3334445', 'Visiting',  32),
(133, 'Dr. Madiha Usman',    '0339-4445556', 'Trainee',   33),
(134, 'Dr. Salman Bhatti',   '0342-5556667', 'Permanent', 34),
(135, 'Dr. Noor Aziz',       '0307-6667778', 'Visiting',  35),
(136, 'Dr. Shehzad Akram',   '0317-7778889', 'Trainee',   36),
(137, 'Dr. Fareeha Ejaz',    '0328-8889990', 'Permanent', 37),
(138, 'Dr. Naveed Dogar',    '0331-9990001', 'Visiting',  38),
(139, 'Dr. Aqsa Zaman',      '0343-1112223', 'Trainee',   39),
(140, 'Dr. Zubair Cheema',   '0308-2223334', 'Permanent', 40),
(141, 'Dr. Mehwish Rafiq',   '0318-3334445', 'Visiting',  41),
(142, 'Dr. Babar Niazi',     '0329-4445556', 'Trainee',   42),
(143, 'Dr. Asma Tufail',     '0332-5556667', 'Permanent', 43),
(144, 'Dr. Haroon Bashir',   '0344-6667778', 'Visiting',  44),
(145, 'Dr. Zainab Ghafoor',  '0309-7778889', 'Trainee',   45),
(146, 'Dr. Shafiq Ellahi',   '0319-8889990', 'Permanent', 46),
(147, 'Dr. Ghazala Mufti',   '0361-9990001', 'Visiting',  47),
(148, 'Dr. Ejaz Ul Haq',     '0362-1112223', 'Trainee',   48),
(149, 'Dr. Parveen Sabir',   '0363-2223334', 'Permanent', 49),
(150, 'Dr. Mubasher Chishti','0364-3334445', 'Visiting',  50);
GO

-- ── Records (50 rows) ───────────────────────────────────────
INSERT INTO Records (Record_NO, Appointment, Description, P_ID, Rec_ID) VALUES
(301, '2026-01-05 09:00', 'General checkup',              1,  201),
(302, '2026-01-07 10:30', 'Blood pressure follow-up',     2,  202),
(303, '2026-01-09 11:00', 'Fever and cough consultation', 3,  203),
(304, '2026-01-11 14:00', 'Diabetes monitoring',          4,  204),
(305, '2026-01-13 09:30', 'Eye examination',              5,  205),
(306, '2026-01-15 10:00', 'Orthopedic consultation',      6,  206),
(307, '2026-01-17 11:30', 'Skin allergy treatment',       7,  207),
(308, '2026-01-19 13:00', 'Cardiac evaluation',           8,  208),
(309, '2026-01-21 15:00', 'Dental pain referral',         9,  209),
(310, '2026-01-23 09:00', 'Thyroid test follow-up',      10,  210),
(311, '2026-01-25 10:30', 'Routine health screening',    11,  211),
(312, '2026-01-27 11:00', 'Asthma management',           12,  212),
(313, '2026-01-29 14:00', 'Post-surgery review',         13,  213),
(314, '2026-02-01 09:30', 'Kidney function check',       14,  214),
(315, '2026-02-03 10:00', 'Anemia treatment',            15,  215),
(316, '2026-02-05 11:30', 'Pregnancy checkup',           16,  216),
(317, '2026-02-07 13:00', 'Back pain consultation',      17,  217),
(318, '2026-02-09 15:00', 'ENT examination',             18,  218),
(319, '2026-02-11 09:00', 'Chest X-ray review',          19,  219),
(320, '2026-02-13 10:30', 'Gastritis consultation',      20,  220),
(321, '2026-02-15 11:00', 'Cholesterol follow-up',       21,  221),
(322, '2026-02-17 14:00', 'Migraine treatment',          22,  222),
(323, '2026-02-19 09:30', 'Hepatitis B screening',       23,  223),
(324, '2026-02-21 10:00', 'Vitamin D deficiency',        24,  224),
(325, '2026-02-23 11:30', 'Arthritis consultation',      25,  225),
(326, '2026-02-25 13:00', 'MRI result discussion',       26,  226),
(327, '2026-02-27 15:00', 'Mental health counseling',    27,  227),
(328, '2026-03-01 09:00', 'Vaccine administration',      28,  228),
(329, '2026-03-03 10:30', 'Urology consultation',        29,  229),
(330, '2026-03-05 11:00', 'Physiotherapy referral',      30,  230),
(331, '2026-03-07 14:00', 'Endoscopy follow-up',         31,  231),
(332, '2026-03-09 09:30', 'Child growth assessment',     32,  232),
(333, '2026-03-11 10:00', 'Ultrasound review',           33,  233),
(334, '2026-03-13 11:30', 'Neurology consultation',      34,  234),
(335, '2026-03-15 13:00', 'COVID-19 follow-up',          35,  235),
(336, '2026-03-17 15:00', 'Dermatology checkup',         36,  236),
(337, '2026-03-19 09:00', 'Oncology review',             37,  237),
(338, '2026-03-21 10:30', 'Respiratory therapy',         38,  238),
(339, '2026-03-23 11:00', 'Hypertension control',        39,  239),
(340, '2026-03-25 14:00', 'Blood glucose monitoring',    40,  240),
(341, '2026-03-27 09:30', 'Fracture follow-up',          41,  241),
(342, '2026-03-29 10:00', 'Liver function test review',  42,  242),
(343, '2026-03-31 11:30', 'Nutrition counseling',        43,  243),
(344, '2026-04-02 13:00', 'Allergy testing',             44,  244),
(345, '2026-04-04 15:00', 'General wellness checkup',    45,  245),
(346, '2026-04-06 09:00', 'Post-COVID rehabilitation',   46,  246),
(347, '2026-04-08 10:30', 'Sleep disorder consultation', 47,  247),
(348, '2026-04-10 11:00', 'Immunization session',        48,  248),
(349, '2026-04-12 14:00', 'Pediatric assessment',        49,  249),
(350, '2026-04-14 09:30', 'Annual physical examination', 50,  250);
GO

-- ── Medical Tests (50 rows) – Test_ID auto-generated ────────
INSERT INTO Medical_Tests (P_ID, Blood_Test, Test_Details, Diagnosis, Test_Date) VALUES
(1,  'A+',  'CBC Report',             'Normal',                  '2026-01-06'),
(2,  'O-',  'Sugar Test',             'Diabetes Type 2',         '2026-01-08'),
(3,  'B+',  'Thyroid Panel',          'Hypothyroidism',          '2026-01-10'),
(4,  'AB+', 'Liver Function Test',    'Mild Fatty Liver',        '2026-01-12'),
(5,  'A-',  'Lipid Profile',          'High Cholesterol',        '2026-01-14'),
(6,  'O+',  'CBC Report',             'Anemia',                  '2026-01-16'),
(7,  'B-',  'Kidney Function Test',   'Normal',                  '2026-01-18'),
(8,  'AB-', 'Cardiac Enzymes',        'Stable Angina',           '2026-01-20'),
(9,  'A+',  'HbA1c Test',             'Pre-Diabetic',            '2026-01-22'),
(10, 'O+',  'Thyroid Panel',          'Hyperthyroidism',         '2026-01-24'),
(11, 'B+',  'Urine Analysis',         'UTI Detected',            '2026-01-26'),
(12, 'AB+', 'X-Ray Chest',            'Mild Pneumonia',          '2026-01-28'),
(13, 'A-',  'MRI Brain',              'No Abnormality',          '2026-01-30'),
(14, 'O-',  'ECG',                    'Normal Sinus Rhythm',     '2026-02-01'),
(15, 'B-',  'Blood Culture',          'Bacterial Infection',     '2026-02-03'),
(16, 'AB-', 'Hemoglobin Test',        'Normal',                  '2026-02-05'),
(17, 'A+',  'Vitamin D Test',         'Deficiency',              '2026-02-07'),
(18, 'O+',  'Ultrasound Abdomen',     'Gallstones Found',        '2026-02-09'),
(19, 'B+',  'Stool Test',             'Parasitic Infection',     '2026-02-11'),
(20, 'AB+', 'Hepatitis Panel',        'Hepatitis B Positive',    '2026-02-13'),
(21, 'A-',  'CBC Report',             'Normal',                  '2026-02-15'),
(22, 'O-',  'Blood Pressure Montr',   'Stage 1 Hypertension',    '2026-02-17'),
(23, 'B-',  'Allergy Test',           'Dust Allergy',            '2026-02-19'),
(24, 'AB-', 'Glucose Tolerance',      'Normal',                  '2026-02-21'),
(25, 'A+',  'Iron Studies',           'Iron Deficiency Anemia',  '2026-02-23'),
(26, 'O+',  'Sputum Culture',         'TB Negative',             '2026-02-25'),
(27, 'B+',  'Thyroid Panel',          'Normal',                  '2026-02-27'),
(28, 'AB+', 'COVID-19 PCR',           'Negative',                '2026-03-01'),
(29, 'A-',  'Ultrasound Kidney',      'Kidney Stone 4mm',        '2026-03-03'),
(30, 'O-',  'Dengue Antibody Test',   'Negative',                '2026-03-05'),
(31, 'B-',  'Liver Biopsy Report',    'No Malignancy',           '2026-03-07'),
(32, 'AB-', 'CBC Report',             'Leukocytosis',            '2026-03-09'),
(33, 'A+',  'Creatinine Test',        'Mild Elevation',          '2026-03-11'),
(34, 'O+',  'CT Scan Head',           'No Acute Finding',        '2026-03-13'),
(35, 'B+',  'Bone Density Scan',      'Osteopenia',              '2026-03-15'),
(36, 'AB+', 'Troponin Test',          'Normal',                  '2026-03-17'),
(37, 'A-',  'PSA Test',               'Elevated – Refer Urolog', '2026-03-19'),
(38, 'O-',  'Peak Flow Test',         'Reduced – Asthma',        '2026-03-21'),
(39, 'B-',  'Cortisol Test',          'Normal',                  '2026-03-23'),
(40, 'AB-', 'HbA1c Test',             'Diabetes Type 1',         '2026-03-25'),
(41, 'A+',  'X-Ray Limb',             'Fracture Healed',         '2026-03-27'),
(42, 'O+',  'LFT + GGT',             'Elevated GGT',            '2026-03-29'),
(43, 'B+',  'Cholesterol Panel',      'Normal',                  '2026-03-31'),
(44, 'AB+', 'Skin Patch Test',        'Nickel Allergy',          '2026-04-02'),
(45, 'A-',  'CBC Report',             'Normal',                  '2026-04-04'),
(46, 'O-',  'Spirometry',             'Mild Obstruction',        '2026-04-06'),
(47, 'B-',  'Sleep Study Report',     'Mild Sleep Apnea',        '2026-04-08'),
(48, 'AB-', 'Vaccination Record',     'Immunization Complete',   '2026-04-10'),
(49, 'A+',  'Growth Hormone Test',    'Normal for Age',          '2026-04-12'),
(50, 'O+',  'Full Body Checkup',      'All Parameters Normal',   '2026-04-14');
GO

-- ── Doctor_Patient (50 rows – many-to-many) ─────────────────
INSERT INTO Doctor_Patient (Doc_ID, P_ID) VALUES
(101,1),(102,2),(103,3),(104,4),(105,5),
(106,6),(107,7),(108,8),(109,9),(110,10),
(111,11),(112,12),(113,13),(114,14),(115,15),
(116,16),(117,17),(118,18),(119,19),(120,20),
(121,21),(122,22),(123,23),(124,24),(125,25),
(126,26),(127,27),(128,28),(129,29),(130,30),
(131,31),(132,32),(133,33),(134,34),(135,35),
(136,36),(137,37),(138,38),(139,39),(140,40),
(141,41),(142,42),(143,43),(144,44),(145,45),
(146,46),(147,47),(148,48),(149,49),(150,50);
GO


-- ════════════════════════════════════════════════════════════
--  AGGREGATE FUNCTIONS
-- ════════════════════════════════════════════════════════════

-- 1. Total patients per city
SELECT City, COUNT(P_ID) AS Total_Patients
FROM   Patients
GROUP  BY City;

-- 2. Count of each doctor type
SELECT D_Type, COUNT(Doc_ID) AS Doctor_Count
FROM   Doctors
GROUP  BY D_Type;

-- 3. Oldest and latest test dates
SELECT MIN(Test_Date) AS Oldest_Test,
       MAX(Test_Date) AS Latest_Test
FROM   Medical_Tests;
GO


-- ════════════════════════════════════════════════════════════
--  USER-DEFINED FUNCTION  –  GetPatientAge
--  MySQL:      TIMESTAMPDIFF(YEAR, dob, CURDATE())
--  SQL Server: DATEDIFF(YEAR, dob, GETDATE())  ← exact replacement
-- ════════════════════════════════════════════════════════════

-- No DELIMITER needed in SQL Server; GO separates batches instead
CREATE FUNCTION dbo.GetPatientAge(@dob DATE)
RETURNS INT
AS
BEGIN
    DECLARE @age INT;
    SET @age = DATEDIFF(YEAR, @dob, GETDATE())
               - CASE
                   WHEN (MONTH(@dob) > MONTH(GETDATE()))
                     OR (MONTH(@dob) = MONTH(GETDATE())
                        AND DAY(@dob) > DAY(GETDATE()))
                   THEN 1
                   ELSE 0
                 END;
    -- The extra CASE ensures the birthday hasn't occurred yet this year
    RETURN @age;
END;
GO

-- Function call: patient name + calculated age
SELECT P_Name,
       D_O_B,
       dbo.GetPatientAge(D_O_B) AS Calculated_Age
FROM   Patients;
GO


-- ════════════════════════════════════════════════════════════
--  GROUP BY & ORDER BY
-- ════════════════════════════════════════════════════════════

-- 1. Har city mein kitne patients hain (Group By)
SELECT   City, COUNT(P_ID) AS Total_Patients
FROM     Patients
GROUP BY City;
GO

-- 2. Doctors ki list A-Z (Order By)
SELECT D_Name, D_Type, D_Phone
FROM   Doctors
ORDER BY D_Name ASC;
GO

-- 3. Patients ko umar ke hisab se bari se choti (Descending)
--    dbo. prefix zaroori hai SQL Server mein UDF call ke liye
SELECT   P_Name,
         dbo.GetPatientAge(D_O_B) AS Age
FROM     Patients
ORDER BY Age DESC;
GO


-- ════════════════════════════════════════════════════════════
--  JOINS
-- ════════════════════════════════════════════════════════════

-- 1. Inner Join: Hospital aur uske Doctors
SELECT h.Hos_Name, d.D_Name, d.D_Type
FROM   Hospital h
JOIN   Doctors  d ON h.Hos_ID = d.Hos_ID;
GO

-- 2. Left Join: Patients aur unke Medical Tests
--    (un patients ko bhi dikhayega jinka koi test nahi hua)
SELECT p.P_Name, t.Blood_Test, t.Diagnosis, t.Test_Date
FROM   Patients     p
LEFT JOIN Medical_Tests t ON p.P_ID = t.P_ID;
GO

-- 3. Three-way Join: Receptionist, Records aur Patients
SELECT r.R_Name       AS Receptionist,
       rec.Appointment,
       p.P_Name       AS Patient
FROM   Receptionist r
JOIN   Records      rec ON r.Rec_ID  = rec.Rec_ID
JOIN   Patients     p   ON rec.P_ID  = p.P_ID;
GO


-- ════════════════════════════════════════════════════════════
--  STORED PROCEDURES
--  MySQL:      DELIMITER // ... END //
--  SQL Server: No DELIMITER; GO ends each batch
--  MySQL:      IN param
--  SQL Server: @param (with @ prefix)
--  MySQL:      CALL ProcName()
--  SQL Server: EXEC ProcName
-- ════════════════════════════════════════════════════════════

-- Procedure 1: Kisi khas Patient ki mukammal history
CREATE PROCEDURE GetPatientHistory
    @patientId INT          -- IN  →  @param  (SQL Server style)
AS
BEGIN
    SELECT p.P_Name, p.Gender,
           t.Blood_Test, t.Diagnosis, t.Test_Date
    FROM   Patients      p
    LEFT JOIN Medical_Tests t ON p.P_ID = t.P_ID
    WHERE  p.P_ID = @patientId;
END;
GO

-- Procedure 2: Doctor ka type update karna (e.g. Trainee → Permanent)
CREATE PROCEDURE UpdateDoctorStatus
    @docId     INT,
    @newStatus VARCHAR(20)
AS
BEGIN
    -- Pehle check karo ke naya status valid hai
    IF @newStatus NOT IN ('Trainee', 'Visiting', 'Permanent')
    BEGIN
        RAISERROR('Invalid D_Type. Use Trainee, Visiting, or Permanent.', 16, 1);
        RETURN;
    END;

    UPDATE Doctors
    SET    D_Type = @newStatus
    WHERE  Doc_ID = @docId;
END;
GO

-- Procedure chalane ka tariqa (CALL → EXEC):
-- EXEC GetPatientHistory 1;
-- EXEC UpdateDoctorStatus 103, 'Permanent';
GO


-- ════════════════════════════════════════════════════════════
--  VIEWS
-- ════════════════════════════════════════════════════════════

-- View 1: Patient Medical Summary
--         Patient aur uske test ki details
CREATE VIEW PatientMedicalSummary AS
SELECT p.P_ID, p.P_Name,
       t.Blood_Test, t.Diagnosis, t.Test_Date
FROM   Patients      p
JOIN   Medical_Tests t ON p.P_ID = t.P_ID;
GO

-- View 2: Hospital Staff Directory
--         Doctors aur Receptionists ek jagah (UNION)
CREATE VIEW StaffDirectory AS
SELECT h.Hos_Name,
       d.D_Name  AS Staff_Name,
       'Doctor'  AS Role
FROM   Hospital h
JOIN   Doctors  d ON h.Hos_ID = d.Hos_ID

UNION

SELECT h.Hos_Name,
       r.R_Name,
       'Receptionist'
FROM   Hospital     h
JOIN   Receptionist r ON h.Hos_ID = r.Hos_ID;
GO

-- Views dekhne ka tariqa:
-- SELECT * FROM PatientMedicalSummary;
-- SELECT * FROM StaffDirectory;


-- ════════════════════════════════════════════════════════════
--  TRIGGERS
--  MySQL:      DELIMITER // ... END //
--  SQL Server: No DELIMITER; GO ends each batch
--  MySQL:      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '...'
--  SQL Server: RAISERROR('...', 16, 1); ROLLBACK; RETURN;
--  MySQL:      NEW.column
--  SQL Server: inserted.column  (virtual table inside trigger)
--  MySQL:      NOW() / CURDATE()
--  SQL Server: GETDATE()
--  MySQL:      AUTO_INCREMENT / NULL for PK
--  SQL Server: IDENTITY column — value auto-generated, no NULL needed
--  MySQL:      CONCAT(a, b)
--  SQL Server: a + b  (string concatenation with + operator)
--  MySQL:      BEFORE INSERT trigger
--  SQL Server: INSTEAD OF INSERT trigger  (no BEFORE in SQL Server)
-- ════════════════════════════════════════════════════════════

-- ── Audit Log Table ─────────────────────────────────────────
--  AUTO_INCREMENT → IDENTITY(1,1)
--  TEXT           → NVARCHAR(MAX)
--  TIMESTAMP DEFAULT CURRENT_TIMESTAMP → DATETIME DEFAULT GETDATE()
CREATE TABLE Hospital_Audit_Log (
    Log_ID      INT            IDENTITY(1,1) PRIMARY KEY,
    Table_Name  VARCHAR(50),
    Action_Type VARCHAR(50),
    Description NVARCHAR(MAX),
    Action_Date DATETIME       DEFAULT GETDATE()
);
GO


-- ── Trigger 1: Data Validation — DOB future check ───────────
--  MySQL:      BEFORE INSERT  → SIGNAL if invalid
--  SQL Server: INSTEAD OF INSERT → RAISERROR + ROLLBACK if invalid,
--              otherwise manually re-insert the valid row
--  FIX: SET XACT_ABORT ON ensures clean rollback on error

CREATE TRIGGER Before_Patient_Insert
ON Patients
INSTEAD OF INSERT          -- SQL Server mein BEFORE nahi hota
AS
BEGIN
    SET XACT_ABORT ON;     -- error pe auto rollback — best practice

    -- Agar koi inserted row ki DOB future mein hai to error do
    IF EXISTS (SELECT 1 FROM inserted WHERE D_O_B > CAST(GETDATE() AS DATE))
    BEGIN
        RAISERROR('Error: Date of Birth cannot be in the future!', 16, 1);
        RETURN;            -- XACT_ABORT ON hone se ROLLBACK automatic hai
    END;

    -- Validation pass hui to actual insert karo
    INSERT INTO Patients (P_ID, P_Name, D_O_B, Gender, Colony, City, Zip)
    SELECT P_ID, P_Name, D_O_B, Gender, Colony, City, Zip
    FROM   inserted;
END;
GO


-- ── Trigger 2: Automatic Record Entry after Medical Test ─────
--  MySQL:      AFTER INSERT, NEW.column, NULL for PK, NOW(), CONCAT
--  SQL Server: AFTER INSERT, inserted.column, IDENTITY handles PK,
--              GETDATE(), + operator for string concat
--  BUG FIXED:  Rec_ID was hardcoded as 1 — but Receptionist table has
--              IDs 201-250. Using 201 (first valid Receptionist) instead.
--              Old value (1) would cause FK violation and crash the trigger.

CREATE TRIGGER After_MedicalTest_Insert
ON Medical_Tests
AFTER INSERT
AS
BEGIN
    SET XACT_ABORT ON;

    -- Records.Record_NO is NOT IDENTITY so we generate a unique value
    -- MAX(Record_NO) + ROW_NUMBER() ensures no PK conflict even for batch inserts
    INSERT INTO Records (Record_NO, Appointment, Description, P_ID, Rec_ID)
    SELECT
        ISNULL((SELECT MAX(Record_NO) FROM Records), 0)
            + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),  -- unique per batch row
        GETDATE(),
        'New Medical Test Added: ' + i.Blood_Test
            + ' - Diagnosis: ' + i.Diagnosis,
        i.P_ID,
        201                                                -- FIX: was 1 (invalid FK) → 201
    FROM inserted i;
END;
GO


-- ── Trigger 3: Doctor Disjoint Rule + Audit Log ──────────────
--  MySQL:      BEFORE INSERT + SIGNAL  →  INSTEAD OF INSERT + RAISERROR
--  Audit log insert uses + for concatenation instead of CONCAT()
--  FIX: SET XACT_ABORT ON added for clean error handling

CREATE TRIGGER Validate_Doctor_Type
ON Doctors
INSTEAD OF INSERT          -- BEFORE INSERT → INSTEAD OF INSERT
AS
BEGIN
    SET XACT_ABORT ON;

    -- D_Type validation (CHECK constraint already handles this,
    -- but trigger adds the audit log step too)
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE D_Type NOT IN ('Trainee', 'Visiting', 'Permanent')
    )
    BEGIN
        RAISERROR('Invalid Doctor Type! Must be Trainee, Visiting, or Permanent.', 16, 1);
        RETURN;            -- XACT_ABORT ON se auto rollback
    END;

    -- Validation pass hui — actual row insert karo
    INSERT INTO Doctors (Doc_ID, D_Name, D_Phone, D_Type, Hos_ID)
    SELECT Doc_ID, D_Name, D_Phone, D_Type, Hos_ID
    FROM   inserted;

    -- Audit log mein entry — CONCAT() → + operator
    INSERT INTO Hospital_Audit_Log (Table_Name, Action_Type, Description)
    SELECT
        'Doctors',
        'INSERT',
        'New Doctor added: ' + D_Name
    FROM inserted;
END;
GO

-- ── Trigger Test Commands ────────────────────────────────────
-- Test 1: Future DOB — error expected
-- INSERT INTO Patients (P_ID,P_Name,D_O_B,Gender,Colony,City,Zip)
--     VALUES (51,'Test Patient','2030-01-01','Male','X St','Lahore','54000');

-- Test 2: Invalid Doctor Type — error expected
-- INSERT INTO Doctors (Doc_ID,D_Name,D_Phone,D_Type,Hos_ID)
--     VALUES (200,'Dr. Test','0300-0000000','InvalidType',1);

-- Test 3: Valid Medical Test — auto Record entry bnega (Record_NO 351+)
-- INSERT INTO Medical_Tests (P_ID,Blood_Test,Test_Details,Diagnosis,Test_Date)
--     VALUES (1,'A+','Routine Test','Normal','2026-05-01');

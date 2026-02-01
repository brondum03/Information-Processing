PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Dependent;
DROP TABLE IF EXISTS WorksOn;
DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

BEGIN TRANSACTION;

CREATE TABLE Department (
  dname TEXT NOT NULL,
  dno INTEGER NOT NULL,
  mgrid INTEGER,
  mgstartdate TEXT,
  PRIMARY KEY (dno),
  UNIQUE (dname),
  FOREIGN KEY (mgrid) REFERENCES Employee(empid)
);

CREATE TABLE Employee (
  fname TEXT NOT NULL,
  mint TEXT,
  lname TEXT NOT NULL,
  empid INTEGER NOT NULL,
  bdate TEXT,
  address TEXT,
  gender TEXT CHECK (gender IN ('M','F')),
  salary INTEGER NOT NULL CHECK (salary >= 0),
  superid INTEGER,
  dno INTEGER NOT NULL,
  PRIMARY KEY (empid),
  FOREIGN KEY (superid) REFERENCES Employee(empid),
  FOREIGN KEY (dno) REFERENCES Department(dno)
);

CREATE TABLE Project (
  pname TEXT NOT NULL,
  pno INTEGER NOT NULL,
  plocation TEXT,
  dno INTEGER NOT NULL,
  PRIMARY KEY (pno),
  UNIQUE (pname),
  FOREIGN KEY (dno) REFERENCES Department(dno)
);

CREATE TABLE WorksOn (
  empid INTEGER NOT NULL,
  pno INTEGER NOT NULL,
  hours REAL NOT NULL CHECK (hours >= 0),
  PRIMARY KEY (empid, pno),
  FOREIGN KEY (empid) REFERENCES Employee(empid),
  FOREIGN KEY (pno) REFERENCES Project(pno)
);

CREATE TABLE Dependent (
  empid INTEGER NOT NULL,
  depname TEXT NOT NULL,
  gender TEXT CHECK (gender IN ('M','F')),
  bdate TEXT,
  relationship TEXT,
  PRIMARY KEY (empid, depname),
  FOREIGN KEY (empid) REFERENCES Employee(empid)
);

-- Insert departments first, with mgrid temporarily NULL
INSERT INTO Department (dname, dno, mgrid, mgstartdate) VALUES
  ('HR', 10, NULL, '2023-01-15'),
  ('Engineering', 20, NULL, '2022-09-01'),
  ('Finance', 30, NULL, '2021-04-10'),
  ('Sales', 40, NULL, '2020-06-20'),
  ('IT', 50, NULL, '2024-02-01');

-- Insert employees (each references an existing department)
INSERT INTO Employee (fname, mint, lname, empid, bdate, address, gender, salary, superid, dno) VALUES
  ('Aisha', 'K', 'Rahman', 1001, '1990-03-12', '12 King St, London', 'F', 92000, NULL, 20),
  ('Omar',  'J', 'Hussain', 1002, '1988-11-02', '8 River Rd, London', 'M', 78000, 1001, 20),
  ('Priya', 'M', 'Shah',    1003, '1992-07-25', '21 Park Ave, London', 'F', 68000, 1001, 20),
  ('Tom',   'R', 'Baker',   1004, '1985-01-19', '5 Hill Ln, London',   'M', 83000, NULL, 10),
  ('Nina',  'S', 'Patel',   1005, '1991-09-30', '44 Grove St, London', 'F', 81000, 1004, 10),
  ('Zain',  NULL,'Khan',    1006, '1993-05-14', '3 Market St, London', 'M', 61000, 1004, 40),
  ('Lucy',  'A', 'Chen',    1007, '1989-12-08', '17 Elm St, London',   'F', 76000, NULL, 30),
  ('Hassan','T', 'Ali',     1008, '1994-02-22', '9 Oak Rd, London',    'M', 70000, NULL, 50);

-- Now that employees exist, set department managers
UPDATE Department SET mgrid = 1004 WHERE dno = 10;
UPDATE Department SET mgrid = 1001 WHERE dno = 20;
UPDATE Department SET mgrid = 1007 WHERE dno = 30;
UPDATE Department SET mgrid = 1006 WHERE dno = 40;
UPDATE Department SET mgrid = 1008 WHERE dno = 50;

-- Projects
INSERT INTO Project (pname, pno, plocation, dno) VALUES
  ('Payroll Revamp',     2001, 'London',   30),
  ('Website Redesign',   2002, 'Remote',   50),
  ('Onboarding Update',  2003, 'London',   10),
  ('Product Alpha',      2004, 'Cambridge',20),
  ('Sales Dashboard',    2005, 'Remote',   40);

-- WorksOn (at least 5 rows)
INSERT INTO WorksOn (empid, pno, hours) VALUES
  (1007, 2001, 12.5),
  (1008, 2002, 20.0),
  (1004, 2003,  8.0),
  (1005, 2003, 14.0),
  (1001, 2004, 18.0),
  (1002, 2004, 10.0),
  (1003, 2004, 16.0),
  (1006, 2005, 15.0),
  (1008, 2005,  6.0);

-- Dependents (at least 5 rows)
INSERT INTO Dependent (empid, depname, gender, bdate, relationship) VALUES
  (1001, 'Sara Rahman',   'F', '2018-04-09', 'Daughter'),
  (1002, 'Mariam Hussain','F', '2016-10-12', 'Daughter'),
  (1004, 'Evan Baker',    'M', '2012-06-01', 'Son'),
  (1005, 'Ravi Patel',    'M', '1965-08-20', 'Father'),
  (1007, 'Mei Chen',      'F', '1990-03-03', 'Spouse'),
  (1008, 'Adam Ali',      'M', '2020-09-17', 'Son');

COMMIT;

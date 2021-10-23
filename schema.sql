DROP TABLE IF EXISTS Employees, Contact_Numbers, Junior, Booker, Senior, Manager, Departments, Meeting_Rooms, 
    Health_Declaration, Updates, Sessions, Joins CASCADE;

DROP TYPE IF EXISTS KIND CASCADE;

SET timezone = 'America/Los_Angeles';

-- ##################
--       Tables
-- ##################

CREATE TYPE KIND AS ENUM ('Junior', 'Senior', 'Manager');

CREATE TABLE Departments (
    did SERIAL PRIMARY KEY,
    dname TEXT
); 

CREATE TABLE Employees (
    eid SERIAL PRIMARY KEY,
    ename TEXT,
    email TEXT,
    did INTEGER,
    resigned_date DATE,

    FOREIGN KEY (did) REFERENCES Departments
);

CREATE TABLE Health_Declaration (
    date DATE,
    eid INTEGER,
    temp FLOAT(1),
    fever BOOLEAN,

    PRIMARY KEY (date, eid),
    FOREIGN KEY (eid) REFERENCES Employees
);


CREATE TABLE Contact_Numbers (
    eid INTEGER,
    contact_number TEXT,
    
    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES Employees
);  


CREATE TABLE Junior (
    eid INTEGER,

    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES Employees ON DELETE CASCADE
);  

CREATE TABLE Booker (
    eid INTEGER,

    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES Employees ON DELETE CASCADE
);

CREATE TABLE Senior (
    eid INTEGER,

    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES Booker ON DELETE CASCADE
); 

CREATE TABLE Manager (
    eid INTEGER,

    PRIMARY KEY (eid),
    FOREIGN KEY (eid) REFERENCES Booker ON DELETE CASCADE
); 

CREATE TABLE Meeting_Rooms (
    did INTEGER,
    room INTEGER,
    floor INTEGER,
    rname TEXT,
    capacity INTEGER,

    PRIMARY KEY (room, floor),
    FOREIGN KEY (did) REFERENCES Departments
); 

CREATE TABLE Updates (
    date DATE,
    room INTEGER,
    floor INTEGER,
    eid INTEGER,
    new_cap INTEGER,

    PRIMARY KEY (date, room, floor, eid),
    FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms,
    FOREIGN KEY (eid) REFERENCES Manager
); 

CREATE TABLE Sessions (
    time TIMESTAMP,
    date DATE,
    room INTEGER,
    floor INTEGER,
    booker_eid INTEGER,
    approver_eid INTEGER,

    PRIMARY KEY (time, date, room, floor),
    FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms,
    FOREIGN KEY (booker_eid) REFERENCES Booker (eid),
    FOREIGN KEY (approver_eid) REFERENCES Manager (eid)
);

CREATE TABLE Joins (
    eid INTEGER,
    room INTEGER,
    floor INTEGER,
    time TIMESTAMP,
    date DATE,
    
    FOREIGN KEY (time, date, room, floor) REFERENCES Sessions,
    FOREIGN KEY (eid) REFERENCES Employees
); 

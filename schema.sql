DROP TABLE IF EXISTS Employees, Contact_Numbers, Junior, Booker, Senior, Manager, Departments, Meeting_Rooms, 
    Health_Declaration, Updates, Sessions, Joins CASCADE;

DROP TYPE IF EXISTS KIND CASCADE;

SET timezone = 'America/Los_Angeles';

-- #############################
--       Custom Data Types
-- #############################

CREATE TYPE KIND AS ENUM ('Junior', 'Senior', 'Manager');

-- ##################
--       Tables
-- ##################

CREATE TABLE Departments (
    did INTEGER PRIMARY KEY,
    dname TEXT NOT NULL
); 


CREATE TABLE Employees (
    eid SERIAL PRIMARY KEY,
    ename TEXT NOT NULL,
    email TEXT GENERATED ALWAYS AS (eid::TEXT || '@company.com') STORED,
    did INTEGER CHECK ( NOT (did IS NULL AND resigned_date IS NULL)),
    resigned_date DATE DEFAULT NULL,

    FOREIGN KEY (did) REFERENCES Departments
);


CREATE TABLE Health_Declaration (
    date DATE,
    eid INTEGER,
    temp FLOAT(1) CHECK (temp >= 34 AND temp <= 43),
    fever BOOLEAN GENERATED ALWAYS AS (temp > 37.5) STORED, --derived attribute
    PRIMARY KEY (date, eid),
    FOREIGN KEY (eid) REFERENCES Employees
);

CREATE TABLE Contact_Numbers (
    eid INTEGER,
    contact_number TEXT,
    
    PRIMARY KEY (contact_number),
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
    --non juniors only!
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

    PRIMARY KEY (room, floor),
    FOREIGN KEY (did) REFERENCES Departments
); 


CREATE TABLE Updates (
    date DATE,
    room INTEGER,
    floor INTEGER,
    new_cap INTEGER CHECK (new_cap >= 0),
    eid INTEGER,

    PRIMARY KEY (date, room, floor),
    FOREIGN KEY (eid) REFERENCES Manager,
    FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms
); 


CREATE TABLE Sessions (
    time TIME,
    date DATE,
    room INTEGER,
    floor INTEGER,
    booker_eid INTEGER NOT NULL, --sessions cannot be created without a booker
    approver_eid INTEGER DEFAULT NULL,
 
    PRIMARY KEY (time, date, room, floor),
    FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms,
    FOREIGN KEY (booker_eid) REFERENCES Booker (eid),
    FOREIGN KEY (approver_eid) REFERENCES Manager (eid)
);


CREATE TABLE Joins (
    eid INTEGER,
    room INTEGER,
    floor INTEGER,
    time TIME,
    date DATE,
    
    PRIMARY KEY (eid, room, floor, time, date),
    FOREIGN KEY (time, date, room, floor) REFERENCES Sessions ON DELETE CASCADE,
    FOREIGN KEY (eid) REFERENCES Employees
);

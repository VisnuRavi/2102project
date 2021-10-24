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
    did SERIAL PRIMARY KEY,
    dname TEXT
); 


CREATE TABLE Employees (
    eid SERIAL PRIMARY KEY,
    ename TEXT,
    email TEXT,
    did INTEGER,
    resigned_date DATE DEFAULT NULL,

    FOREIGN KEY (did) REFERENCES Departments
);


CREATE TABLE Health_Declaration (
    date DATE,
    eid INTEGER,
    temp FLOAT(1),
    fever BOOLEAN GENERATED ALWAYS AS (temp > 37.5) STORED, --derived attribute
    PRIMARY KEY (date, eid),
    FOREIGN KEY (eid) REFERENCES Employees
);

-- Todo: limit to 3 per employee
CREATE TABLE Contact_Numbers (
    eid INTEGER,
    contact_number TEXT,
    
    PRIMARY KEY (eid, contact_number),
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
    capacity INTEGER,

    PRIMARY KEY (room, floor),
    FOREIGN KEY (did) REFERENCES Departments
); 


CREATE TABLE Updates (
    date DATE,
    room INTEGER,
    floor INTEGER,
    new_cap INTEGER,

    PRIMARY KEY (date, room, floor),
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
    
    FOREIGN KEY (time, date, room, floor) REFERENCES Sessions,
    FOREIGN KEY (eid) REFERENCES Employees
); 

-- ##################
--       Triggers
-- ##################
CREATE OR REPLACE FUNCTION max_contact_numbers() RETURNS TRIGGER AS $$
    DECLARE
        contact_numbers INTEGER;
    BEGIN
        SELECT COUNT(*) INTO contact_numbers FROM Contact_Numbers WHERE eid = NEW.eid;
        IF (contact_numbers = 3) THEN 
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER max_contact_numbers
BEFORE INSERT on Contact_Numbers
FOR EACH ROW EXECUTE FUNCTION max_contact_numbers(); 
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
    room TEXT,
    floor INTEGER,
    rname TEXT,

    PRIMARY KEY (room, floor),
    FOREIGN KEY (did) REFERENCES Departments
); 

CREATE TABLE Updates (
    date DATE,
    room TEXT,
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
    room TEXT,
    floor INTEGER,
    booker_eid INTEGER,

    PRIMARY KEY (time, date, room, floor),
    FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms,
    FOREIGN KEY (booker_eid) REFERENCES Booker (eid)
);

CREATE TABLE Joins (
    eid INTEGER,
    room TEXT,
    floor INTEGER,
    time TIMESTAMP,
    date DATE,
    
    FOREIGN KEY (time, date, room, floor) REFERENCES Sessions,
    FOREIGN KEY (eid) REFERENCES Employees
); 

-- ###########################
--        Basic Functions
-- ###########################

CREATE OR REPLACE FUNCTION add_department(dname TEXT) RETURNS VOID AS $$
    BEGIN
        INSERT INTO Departments (dname) VALUES (dname);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_employee(ename TEXT, contact_number TEXT, kind KIND, department_name TEXT) RETURNS VOID AS $$
    DECLARE
        created_eid INTEGER;
        created_email TEXT;
        matching_did INTEGER = NULL;
    BEGIN
        -- Find the did based on given department name
        SELECT did FROM Departments WHERE dname = department_name INTO matching_did;
        IF matching_did IS NULL THEN 
            RAISE EXCEPTION 'No such department with the name %', department_name;
        END IF;

        -- Temporarily set email to be NULL as we require the auto-generated eid to create email
        INSERT INTO Employees(ename, email, did, resigned_date) 
        VALUES (ename, NULL, matching_did, NULL) 
        RETURNING eid INTO created_eid;

        -- Create and set email by concatenating name and eid (guaranteed to be unique)
        created_email = CONCAT(ename, created_eid::TEXT, '@company.com');
        UPDATE Employees SET email = created_email WHERE eid = created_eid;

        -- Insert into respective subtable based on kind
        -- TODO: Do we need to insert into Booker as well?
        CASE 
            WHEN kind = 'Junior' THEN
                INSERT INTO Junior VALUES (created_eid);
            WHEN kind = 'Senior' THEN
                INSERT INTO Senior VALUES (created_eid);
            WHEN kind = 'Manager' THEN
                INSERT INTO Manager VALUES (created_eid);
        END CASE;
    END;
$$ LANGUAGE plpgsql;

-- #############################
--         Core Functions
-- #############################

CREATE OR REPLACE FUNCTION add_department(dname TEXT) RETURNS VOID AS $$
    BEGIN
        INSERT INTO Departments (dname) VALUES (dname);
    END;
$$ LANGUAGE plpgsql;

-- #############################
--        Health Functions
-- #############################





-- #############################
--        Admin Functions
-- #############################
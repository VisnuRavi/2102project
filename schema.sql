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


-- ###########################
--        Trigger Functions
-- ###########################

CREATE OR REPLACE FUNCTION FN_Contact_Numbers_Check_Max() RETURNS TRIGGER AS $$
    DECLARE
        contact_numbers INTEGER;
    BEGIN
        SELECT COUNT(*) INTO contact_numbers FROM Contact_Numbers WHERE eid = NEW.eid;
        IF (contact_numbers = 3) THEN 
            RAISE NOTICE 'employee: % can have at most 3 contact numbers', NEW.eid;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

--on deletion of a session, remove all employees attending it (regardless of approval status)
CREATE OR REPLACE FUNCTION FN_Sessions_OnDelete_RemoveAllEmps() RETURNS TRIGGER AS $$
    BEGIN
        DELETE FROM Joins
        WHERE
            OLD.time = time
            AND
            OLD.date = date
            AND
            OLD.room = room
            AND
            OLD.floor = floor;

        RAISE NOTICE 'session on %, %, room: %, floor: %, has been deleted',OLD.date, OLD.time, OLD.room, OLD.floor;
        RETURN OLD;
    END;
$$ LANGUAGE plpgsql;

--on adding on a updates entry, check validity of all rooms pertaining to the entry, delete them if invalid
CREATE OR REPLACE FUNCTION FN_Updates_OnAdd_CheckSessionValidity() RETURNS TRIGGER AS $$
    BEGIN
       WITH invalid_sessions AS (
            SELECT s.time, s.date, s.room, s.floor, s.booker_eid, s.approver_eid
            FROM Sessions s, 
                (SELECT j.time, j.date, COUNT(*) AS participants
                FROM Joins j
                WHERE
                    NEW.floor = j.floor
                    AND
                    NEW.room = j.room
                    AND
                    j.date > NEW.date
                GROUP BY j.time, j.date) AS p
            WHERE
                s.floor = NEW.floor
                AND
                s.room = NEW.room
                AND
                s.time = p.time
                AND
                s.date = p.date
                AND
                --check session validity
                p.participants > NEW.new_cap
       )
        DELETE FROM Sessions s2 
        USING invalid_sessions invs
        WHERE
            s2.time = invs.time
            AND
            s2.date = invs.date
            AND
            s2.room = invs.room
            AND
            s2.floor = invs.floor;
        RETURN OLD;
    END;
$$ LANGUAGE plpgsql;

--On insertion in Joins table, check the necessary constraints
CREATE OR REPLACE FUNCTION FN_Joins_BeforeInsert_Check() RETURNS TRIGGER AS $$
DECLARE
    max_capacity INTEGER = 0;
    curr_emp_count INTEGER = 0;
    num_of_changes INTEGER = 0;
BEGIN
    IF((NEW.date < CURRENT_DATE)) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Please join only future meetings! (date)', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSEIF((NEW.date = CURRENT_DATE) AND NEW.time < CURRENT_TIME) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Please join only future meetings! (time)', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSEIF((SELECT COUNT(*) FROM Sessions WHERE floor = NEW.floor AND room = NEW.room AND date = NEW.date AND time = NEW.time) <> 1) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Invalid Meeting Session Information', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSEIF((SELECT approver_eid FROM Sessions WHERE floor = NEW.floor AND room = NEW.room AND date = NEW.date AND time = NEW.time) IS NOT NULL) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Employees can only join non-approved meetings', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSEIF((SELECT fever FROM Health_Declaration WHERE date = CURRENT_DATE AND eid = NEW.eid) = TRUE) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Employee is having a fever', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSEIF((NEW.eid IN (SELECT eid FROM Joins WHERE room = NEW.room AND NEW.floor = floor AND time = NEW.time AND date = NEW.date)) = TRUE) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Employee is already admitted to this meeting', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSEIF((SELECT resigned_date FROM Employees WHERE eid = NEW.eid) IS NOT NULL) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Employee is resigned', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSEIF ((SELECT employee_concurrent_meeting(NEW.eid, NEW.date, NEW.time, NEW.time + INTERVAL '1 hour')) = TRUE) THEN
        RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Employee is already admitted to concurently timed meeting', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date;
        RETURN NULL;
    ELSE
        SELECT COUNT(*) INTO curr_emp_count
        FROM Joins j
        WHERE 
            j.room = NEW.room
            AND
            j.floor = NEW.floor
            AND
            j.time = NEW.time
            AND
            j.date = NEW.date;

        --maximum allowable room capacity on session's date for relevant room
        SELECT new_cap INTO max_capacity 
        FROM updates
        WHERE 
            room = NEW.room 
            AND 
            floor = NEW.floor
            AND
            --date of meeting strictly AFTER change_date in Updates.
            date < NEW.date
        ORDER BY date DESC
        LIMIT 1;

        IF(max_capacity IS NULL) THEN
            SELECT new_cap INTO max_capacity 
            FROM updates
            WHERE 
                room = NEW.room 
                AND 
                floor = NEW.floor;
        END IF;

        IF ((max_capacity - curr_emp_count) >= 1) THEN
            --add the employee
            RETURN NEW;
        ELSE
            RAISE NOTICE 'Employee % cannot join meeting (room: %, floor: %, time: %, date: %): Meeting is at full capacity (%)', 
                    NEW.eid, NEW.room, NEW.floor, NEW.time, NEW.date, max_capacity;
            RETURN NULL;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;



-- ########################################################################
--       Triggers
-- naming conv for trigger: TR_<TableName>_<ActionName>
-- naming conv for trigger func: FN_<TableName>_<ActionName>
-- ######################################################

CREATE TRIGGER TR_Contact_Numbers_Check_Max
BEFORE INSERT ON Contact_Numbers
FOR EACH ROW EXECUTE FUNCTION FN_Contact_Numbers_Check_Max(); 

CREATE TRIGGER TR_Sessions_OnDelete_RemoveAllEmps
BEFORE DELETE ON Sessions
FOR EACH ROW EXECUTE FUNCTION FN_Sessions_OnDelete_RemoveAllEmps();

CREATE TRIGGER TR_Updates_OnAdd_CheckSessionValidity
AFTER INSERT ON Updates
FOR EACH ROW EXECUTE FUNCTION FN_Updates_OnAdd_CheckSessionValidity();

CREATE TRIGGER TR_Joins_BeforeInsert_Check
BEFORE INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION FN_Joins_BeforeInsert_Check();

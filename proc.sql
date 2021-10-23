-- Basic functions
DROP FUNCTION IF EXISTS add_department(TEXT), 
    add_employee(TEXT, TEXT, KIND, TEXT) CASCADE;

-- Core functions
DROP FUNCTION IF EXISTS search_room(INTEGER, DATE, TIME, TIME) CASCADE;

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

        -- Insert contact number into separate table (since an employee can have multiple)
        INSERT INTO Contact_Numbers values(created_eid, contact_number);

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

CREATE OR REPLACE FUNCTION search_room(qcapacity INTEGER, qdate DATE, start_hour TIME, end_hour TIME) RETURNS TABLE (
    did INTEGER,
    room TEXT,
    floor INTEGER,
    rname TEXT,
    capacity INTEGER
) AS $$
    BEGIN
        RETURN QUERY
        SELECT mr.did, mr.room, mr.floor, mr.rname, mr.capacity
        FROM Sessions s INNER JOIN Meeting_Rooms mr ON s.room = mr.room AND s.floor = mr.floor
        WHERE qcapacity > mr.capacity
            AND qdate = s.date
        EXCEPT
        -- Rooms that have sessions on the given date and within the range
        SELECT mr.did, mr.room, mr.floor, mr.rname, mr.capacity
        FROM Sessions s INNER JOIN Meeting_Rooms mr ON s.room = mr.room AND s.floor = mr.floor
        WHERE qcapacity > mr.capacity
            AND qdate = s.date
            AND s.time >= start_hour
            AND s.time < end_hour;
    END;
$$ LANGUAGE plpgsql;

-- #############################
--        Health Functions
-- #############################





-- #############################
--        Admin Functions
-- #############################
-- Basic functions
DROP FUNCTION IF EXISTS add_department(TEXT), 
    add_employee(TEXT, TEXT, KIND, TEXT) CASCADE;

DROP PROCEDURE IF EXISTS add_room(INTEGER, INTEGER, TEXT, INTEGER) CASCADE;

-- Core functions
DROP FUNCTION IF EXISTS search_room(INTEGER, DATE, TIME, TIME) CASCADE;

DROP PROCEDURE IF EXISTS leave_meeting(INTEGER, INTEGER, DATE, TIMESTAMP, INTEGER) CASCADE;

-- ###########################
--        Basic Functions
-- ###########################

CREATE OR REPLACE FUNCTION add_department(dname TEXT) RETURNS VOID AS $$
    BEGIN
        INSERT INTO Departments (dname) VALUES (dname);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_room(did INTEGER, floor INTEGER, room INTEGER, rname TEXT, capacity INTEGER) AS $$
    BEGIN
        --rather than capacity being updated here, it should be updated in UPDATES table (trigger)
        INSERT INTO Meeting_Rooms(did, room, floor, rname, capacity) VALUES (did, room, floor, rname, capacity);
    END
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


CREATE OR REPLACE PROCEDURE change_capacity (IN _floor INTEGER, IN _room INTEGER, IN _cap INTEGER, IN _date DATE, IN _eid INTEGER) AS $$
    DECLARE
        room_dept INTEGER = NULL;
    BEGIN
        --get room_dept (did)
        SELECT did INTO room_dept FROM Meeting_Rooms mr WHERE mr.room = _room AND mr.floor = _floor;
        --valid manager
        IF (_eid NOT IN (SELECT eid FROM Manager)) THEN
            RAISE EXCEPTION 'Only Managers are allowed to update capacity';
        ELSEIF (_eid NOT IN (SELECT emps.eid FROM Employees emps, Manager mngs 
                                WHERE emps.eid = mngs.eid AND emps.did = room_dept)) THEN
            RAISE EXCEPTION 'Ensure Manager is from same department as the room ';
        ELSE
            --add a new entry to updates table, reflecting change in room's capacity
            INSERT INTO Updates (date,room,floor,new_cap) VALUES (_date, _room, _floor, _cap);
        END IF;
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

CREATE OR REPLACE PROCEDURE unbook_room(_floor INTEGER, _room INTEGER, _date DATE, _time TIMESTAMP, _booker_eid INTEGER) AS $$
    DECLARE
        session_deleted INTEGER = NULL;
    BEGIN
        DELETE FROM Sessions s
        WHERE s.floor = _floor AND
        s.room = _room AND
        s.date = _date AND
        s.time = _time AND
        s.booker_eid = _booker_eid; -- Ensure only booker can unbook

        SELECT @@rowcount INTO session_deleted;
        IF session_deleted <= 0 THEN
            RAISE EXCEPTION 'No meeting found or unauthorised unbooking';
        END IF; 
        
        -- Remove all employees associated with the session
        DELETE FROM Joins j
        WHERE j.floor = _floor AND
        j.room = _room AND
        j.date = _date AND
        j.time = _time;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE leave_meeting(_floor INTEGER, _room INTEGER, _date DATE, _time TIMESTAMP, _eid INTEGER) AS $$
    DECLARE
        approver_eid INTEGER = NULL;
    BEGIN
        SELECT s.approver_eid
        FROM Sessions s
        WHERE s.floor = _floor AND
        s.room = _room AND
        s.date = _date AND
        s.time = _time
        INTO approver_eid;

        -- Ensure employee can only leave unapproved meetings
        IF approver_eid IS NOT NULL THEN
            RAISE EXCEPTION 'Meeting already approved'; 
        END IF;

        DELETE FROM Joins
        WHERE floor = _floor AND
        room = _room AND
        date = _date AND
        time = _time AND
        eid = _eid; 
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE  approve_meeting(_floor INTEGER, _room INTEGER, _date DATE, _time TIME, _eid INTEGER) AS $$
    DECLARE
        room_dept INTEGER = NULL;
        a_eid INTEGER = NULL;
    BEGIN
        --valid manager_check
        SELECT did INTO room_dept FROM Meeting_Rooms WHERE floor = _floor AND room = _room;
        IF((SELECT resigned_date FROM Employees WHERE eid = _eid) IS NOT NULL) THEN
            RAISE EXCEPTION 'Attempt by resigned employee to approve room';
        ELSEIF (_eid NOT IN (SELECT eid FROM Manager)) THEN
            RAISE EXCEPTION 'Only Managers are allowed to approve room';
        ELSEIF (_eid NOT IN (SELECT emps.eid FROM Employees emps, Manager mngs 
                                WHERE emps.eid = mngs.eid AND emps.did = room_dept)) THEN
            RAISE EXCEPTION 'Approving Manager needs to be from same department as the to-be-approved room';
        ELSE
            SELECT s.approver_eid
            FROM Sessions s
            WHERE s.floor = _floor AND
            s.room = _room AND
            s.date = _date AND
            s.time = _time
            INTO a_eid;
            IF a_eid IS NOT NULL THEN
                RAISE EXCEPTION 'Meeting already approved'; 
            ELSE
                --TODO: check date
                --approve meeting
                UPDATE Sessions
                SET approver_eid = _eid
                WHERE 
                floor = _floor AND
                room = _room AND
                date = _date AND
                time = _time;
            END IF;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE join_meeting(_floor INTEGER, _room INTEGER, _date DATE, _time TIME, _eid INTEGER) AS $$
DECLARE
    max_capacity INTEGER = NULL;
    curr_emp_count INTEGER = NULL;
BEGIN

    IF((SELECT COUNT(*) FROM Sessions WHERE floor = _floor AND room = _room AND date = _date AND time = _time) <> 1) THEN
        RAISE EXCEPTION 'Invalid meeting information entered';
    ELSEIF ( (SELECT approver_eid FROM Sessions WHERE floor = _floor AND room = _room AND date = _date AND time = _time) IS NOT NULL) THEN
        RAISE EXCEPTION 'Employees can only join non-approved meetings';
    ELSEIF ( (SELECT fever FROM Health_Declaration WHERE date = CURRENT_DATE AND eid = _eid) = TRUE) THEN
        RAISE EXCEPTION 'Employee is having a fever';
    ELSEIF ( (SELECT fever FROM Health_Declaration WHERE date = CURRENT_DATE AND eid = _eid) IS NULL) THEN
        RAISE EXCEPTION 'Employee has not declared their health today';
    ELSEIF ( (_eid IN (SELECT eid FROM Joins WHERE room = _room AND _floor = floor AND time = _time AND date = _date)) = TRUE) THEN
        RAISE EXCEPTION 'Employee % already added to Meeting on % % at room: %, floor: % ',_eid,_date, _time, _room, _floor;
    ELSE
        --maximum allowable room capacity at time of joining
        SELECT new_cap INTO max_capacity 
        FROM updates
        WHERE 
            room = _room 
            AND 
            floor = _floor
            AND
            date <= CURRENT_DATE
        ORDER BY date DESC
        LIMIT 1;
        --count the current employees in booking-to-join
        SELECT COUNT(*) INTO curr_emp_count
        FROM Joins j
        WHERE 
            j.room = _room
            AND
            j.floor = _floor
            AND
            j.time = _time
            AND
            j.date = _date;

        --check whether this joining employee can fit the maximum allowable room capacity
        IF ( (max_capacity - curr_emp_count) >= 1) THEN
            --add the dude
            INSERT INTO Joins VALUES (_eid, _room, _floor, _time, _date);
        ELSE
            RAISE EXCEPTION 'Meeting on % % at room: %, floor: % is at already at full capacity!', _date, _time, _room, _floor;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- #############################
--        Health Functions
-- #############################





-- #############################
--        Admin Functions
-- #############################


-- ###########################
--        Trigger Functions
-- ###########################
CREATE OR REPLACE FUNCTION FN_Meeting_Rooms_AfterInsert() RETURNS TRIGGER AS $$ 
BEGIN
    INSERT INTO Updates (date,room,floor,new_cap) VALUES (CURRENT_DATE, NEW.room, NEW.floor, NEW.capacity);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
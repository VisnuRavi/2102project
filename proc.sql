-- Basic functions
DROP FUNCTION IF EXISTS add_department(TEXT), 
    add_employee(TEXT, TEXT, KIND, INTEGER) CASCADE;

DROP PROCEDURE IF EXISTS add_room(INTEGER, INTEGER, INTEGER, TEXT, INTEGER),
    change_capacity(INTEGER, INTEGER, INTEGER, DATE, INTEGER),
    remove_department(INTEGER),
    remove_employee(INTEGER, DATE) CASCADE;

-- Core functions
DROP FUNCTION IF EXISTS search_room(INTEGER, DATE, TIME, TIME) CASCADE;

DROP PROCEDURE IF EXISTS leave_meeting(INTEGER, INTEGER, DATE, TIMESTAMP, INTEGER) CASCADE;

-- Health functions
DROP PROCEDURE IF EXISTS declare_health(INTEGER, DATE, FLOAT(1)) CASCADE;
DROP FUNCTION IF EXISTS three_day_employee_room(INTEGER, DATE),
    three_day_room_employee(INTEGER, INTEGER, DATE) CASCADE;

-- Admin functions
DROP FUNCTION IF EXISTS non_compliance(DATE, DATE),
    view_booking_report(DATE, INTEGER),
    view_manager_report(DATE,INTEGER) CASCADE;


-- ###########################
--        Basic Functions
-- ###########################

CREATE OR REPLACE FUNCTION add_department(dname TEXT) RETURNS VOID AS $$
    BEGIN
        INSERT INTO Departments (dname) VALUES (dname);
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE remove_department(_did INTEGER) AS $$
    DELETE FROM Departments WHERE did = _did;
$$ LANGUAGE sql;


CREATE OR REPLACE PROCEDURE add_room(did INTEGER, floor INTEGER, room INTEGER, rname TEXT, capacity INTEGER) AS $$
    BEGIN
        INSERT INTO Meeting_Rooms(did, room, floor, rname) VALUES (did, room, floor, rname);
        --insert into updates table (non-trigger implementation)
        INSERT INTO Updates (date,room,floor,new_cap) VALUES (CURRENT_DATE, room, floor, capacity);

    END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_employee(ename TEXT, contact_number TEXT, kind KIND, did INTEGER) RETURNS VOID AS $$
    DECLARE
        created_eid INTEGER;
        created_email TEXT;
    BEGIN
        -- Temporarily set email to be NULL as we require the auto-generated eid to create email
        INSERT INTO Employees(ename, email, did, resigned_date) 
        VALUES (ename, NULL, did, NULL) 
        RETURNING eid INTO created_eid;

        -- Create and set email by concatenating name and eid (guaranteed to be unique)
        created_email = CONCAT(ename, created_eid::TEXT, '@company.com');
        UPDATE Employees SET email = created_email WHERE eid = created_eid;

        -- Insert contact number into separate table (since an employee can have multiple)
        INSERT INTO Contact_Numbers values(created_eid, contact_number);

        -- Insert into respective subtable based on kind
        CASE 
            WHEN kind = 'Junior' THEN
                INSERT INTO Junior VALUES (created_eid);
            WHEN kind = 'Senior' THEN
                INSERT INTO Booker VALUES (created_eid);
                INSERT INTO Senior VALUES (created_eid);
            WHEN kind = 'Manager' THEN
                INSERT INTO Booker VALUES (created_eid);
                INSERT INTO Manager VALUES (created_eid);
        END CASE;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE remove_employee(eid1 INTEGER, resigned_date1 DATE) AS $$
    UPDATE Employees SET resigned_date = resigned_date1 WHERE eid = eid1;
$$ LANGUAGE sql;


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
    room INTEGER,
    floor INTEGER,
    rname TEXT
) AS $$
    DECLARE
        stripped_start_hour TIME;
        stripped_end_hour TIME;
    BEGIN
        IF (end_hour <= start_hour) THEN
            RAISE EXCEPTION 'End hour must be greater than start hour';
        END IF;
        
        IF (qcapacity <= 0) THEN
            RAISE EXCEPTION 'Capacity must be greater than 0';
        END IF;

        SELECT date_trunc('hour', start_hour) INTO stripped_start_hour;
        SELECT date_trunc('hour', end_hour) INTO stripped_end_hour;

        RETURN QUERY
        SELECT mr.did, mr.room, mr.floor, mr.rname
        FROM Meeting_Rooms mr
        EXCEPT
        -- Rooms that have sessions on the given date and within the range
        SELECT mr.did, mr.room, mr.floor, mr.rname
        FROM Sessions s INNER JOIN Meeting_Rooms mr 
            ON s.room = mr.room 
            AND s.floor = mr.floor
            INNER JOIN Updates u
            ON s.room = u.room
            AND s.floor = u.floor 
        WHERE qcapacity <= u.new_cap
            AND qdate = s.date
            AND s.time >= stripped_start_hour
            AND s.time < stripped_end_hour;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fnStripMinSec(_time TIME) RETURNS TIME AS $$
    BEGIN
        RETURN DATEADD(hour, DATEDIFF(hour, 0, _time), 0);
    END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE book_room(_floor INTEGER, _room INTEGER, _date DATE, _start_hour TIME, _end_hour TIME, _booker_eid INTEGER) AS $$
    DECLARE
        room_available INTEGER;
        is_booker INTEGER;
        current_hour TIME := _start_hour;
    BEGIN
        --this also handles when cap=0, as search room will give rooms with cap>0
        SELECT COUNT(*) INTO room_available 
        FROM search_room(1, _date, _start_hour, _end_hour) 
        WHERE floor = _floor AND room = _room;

        IF (room_available > 0) THEN
            SELECT COUNT(*) INTO is_booker
            FROM Booker NATURAL JOIN Employees
            WHERE eid = _booker_eid
            AND resigned_date IS NULL;
            
            IF (is_booker) > 0 THEN
                WHILE current_hour < _end_hour LOOP
                    INSERT INTO Sessions VALUES (current_hour, _date, _room, _floor, _booker_eid);
                    INSERT INTO Joins VALUES (_booker_eid, _room, _floor, current_hour, _date);
                    current_hour := current_hour + INTERVAL '1 hour';
                END LOOP;
            ELSE
                RAISE EXCEPTION 'Only a booker can book a meeting room';
            END IF;
        ELSE
            RAISE EXCEPTION 'Meeting room is unavailable';
        END IF;
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

CREATE OR REPLACE PROCEDURE declare_health(_eid INTEGER, _date DATE, _temperature FLOAT(1)) AS $$
    BEGIN
        INSERT INTO Health_Declaration values (_date, _eid, _temperature);
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION three_day_employee_room(_eid INTEGER, start_date DATE)
RETURNS TABLE (
    floor INTEGER,
    room INTEGER
) AS $$
    BEGIN
        RETURN QUERY
        SELECT DISTINCT j.floor, j.room
        FROM Joins j
        WHERE j.eid = _eid
        AND j.date <= start_date
        AND j.date >= start_date - 3; --should this be -3 or -2?
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION three_day_room_employee(_floor INTEGER, _room INTEGER, start_date DATE)
RETURNS TABLE (
    eid INTEGER
) AS $$
    BEGIN
        RETURN QUERY
        SELECT DISTINCT j.eid
        FROM Joins j NATURAL JOIN Sessions s
        WHERE j.floor = _floor
        AND j.room = _room
        AND j.date <= start_date
        AND j.date >= start_date - 3 -- from day D-3 to day D (according to doc)
        AND s.approver_eid IS NOT NULL; -- ensure meeting has occurred
    END;
$$ LANGUAGE plpgsql;

-- #############################
--        Admin Functions
-- #############################

CREATE OR REPLACE FUNCTION non_compliance(start_date DATE, end_date DATE) RETURNS TABLE (
    eid INTEGER,
    number_of_days INTEGER
) AS $$
    BEGIN
        RETURN QUERY
        SELECT hd.eid, CAST(CAST(end_date AS DATE) - CAST(start_date AS DATE) + 1 - COUNT(*) AS INTEGER)
        FROM Health_Declaration hd
        WHERE hd.date >= start_date AND hd.date <= end_date
        GROUP BY hd.eid
        HAVING CAST(CAST(end_date AS DATE) - CAST(start_date AS DATE) + 1 - COUNT(*) AS INTEGER) > 0
        ORDER BY CAST(CAST(end_date AS DATE) - CAST(start_date AS DATE) + 1 - COUNT(*) AS INTEGER) DESC, hd.eid;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION view_booking_report(_start_date DATE, _booker_eid INTEGER) 
RETURNS TABLE (
    floor INTEGER,
    room INTEGER,
    date DATE,
    start_hour TIME,
    is_approved INTEGER
) AS $$
    DECLARE
    is_booker INTEGER;
    BEGIN
    SELECT COUNT(*) INTO is_booker FROM Booker b WHERE b.eid = _booker_eid;
    IF (is_booker > 0) THEN
        RETURN QUERY
        SELECT s.floor, s.room, s.date, s.time, s.approver_eid
        FROM Meeting_Rooms mr NATURAL JOIN Sessions s
        WHERE s.booker_eid = _booker_eid
        AND s.date >= _start_date
        ORDER BY s.date, s.time ASC;
    ELSE
        RAISE EXCEPTION 'This employee could not have booked any meetings.';
    END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION view_manager_report(start_date DATE, approver_eid INTEGER) 
RETURNS TABLE (
    floor INTEGER, 
    room INTEGER, 
    date DATE, 
    start_hour TIME, 
    booker_eid INTEGER
) AS $$
    DECLARE
    is_manager INTEGER;
    manager_did INTEGER;
    BEGIN
    SELECT COUNT(*) INTO is_manager FROM Manager WHERE eid = approver_eid;
    IF (is_manager > 0) THEN
        SELECT did INTO manager_did FROM Employees WHERE eid = approver_eid;

        RETURN QUERY
        SELECT s.floor, s.room, s.date, s.time, s.booker_eid
        FROM Meeting_Rooms mr NATURAL JOIN Sessions s
        WHERE s.approver_eid IS NULL
        AND mr.did = manager_did
        AND s.date >= start_date
        ORDER BY s.date, s.time ASC;
    END IF;
    END;
$$ LANGUAGE plpgsql;




-- ###########################
--        Trigger Functions
-- ###########################

CREATE OR REPLACE FUNCTION FN_Contact_Numbers_Check_Max() RETURNS TRIGGER AS $$
    DECLARE
        contact_numbers INTEGER;
    BEGIN
        SELECT COUNT(*) INTO contact_numbers FROM Contact_Numbers WHERE eid = NEW.eid;
        IF (contact_numbers = 3) THEN 
            RAISE EXCEPTION 'An employee can have at most 3 contact numbers';
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;
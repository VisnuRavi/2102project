-- Basic functions
DROP PROCEDURE IF EXISTS 
    add_department(INTEGER, TEXT), 
    remove_department(INTEGER),
    add_room(INTEGER, INTEGER, INTEGER, TEXT, INTEGER),
    change_capacity(INTEGER, INTEGER, INTEGER, DATE, INTEGER),
    add_employee(TEXT, TEXT, KIND, INTEGER),
    remove_employee(INTEGER, DATE) 
CASCADE;

-- Core functions
DROP FUNCTION IF EXISTS 
    search_room(INTEGER, DATE, TIME, TIME)
CASCADE;

DROP PROCEDURE IF EXISTS 
    book_room(INTEGER, INTEGER, DATE, TIME, TIME, INTEGER),
    unbook_room(INTEGER, INTEGER, DATE, TIME, TIME, INTEGER),
    join_meeting(INTEGER, INTEGER, DATE, TIME, INTEGER),
    leave_meeting(INTEGER, INTEGER, DATE, TIME, TIME, INTEGER),
    approve_meeting(INTEGER, INTEGER, DATE, TIME, INTEGER)
CASCADE;

-- Health functions
DROP PROCEDURE IF EXISTS 
    declare_health(INTEGER, DATE, FLOAT(1)),
    remove_employee_from_future_meeting_seven_days(DATE, INTEGER),
    remove_fever_employee_from_all_meetings(DATE, INTEGER)
CASCADE;

DROP FUNCTION IF EXISTS 
    contact_tracing(INTEGER, DATE),
    three_day_employee_room(INTEGER, DATE),
    three_day_room_employee(INTEGER, INTEGER, DATE)
CASCADE;

-- Admin functions
DROP FUNCTION IF EXISTS 
    non_compliance(DATE, DATE),
    view_booking_report(DATE, INTEGER),
    view_future_meeting(start_date DATE, INTEGER),
    view_manager_report(DATE,INTEGER) 
CASCADE;

-- Trigger, seems to only work when done individually
DROP TRIGGER IF EXISTS TR_Contact_Numbers_Check_Max ON Contact_Numbers;
DROP TRIGGER IF EXISTS TR_Sessions_OnDelete_RemoveAllEmps ON Sessions;
DROP TRIGGER IF EXISTS TR_Updates_OnAdd_CheckSessionValidity ON Updates;
DROP TRIGGER IF EXISTS TR_Departments_BeforeDelete_Check ON Departments;
DROP TRIGGER IF EXISTS TR_Employees_AfterUpdate_EditAffectedMeetings ON Employees;
DROP TRIGGER IF EXISTS TR_Joins_BeforeInsert_Check ON Joins;
DROP TRIGGER IF EXISTS TR_Health_Declaration_AfterInsertUpdate_Contact_Tracing ON Health_Declaration;
DROP TRIGGER IF EXISTS TR_Sessions_BeforeUpdate_Approval_Check() ON Sessions;

-- Trigger Functions
DROP FUNCTION IF EXISTS
    FN_Contact_Numbers_Check_Max(),
    FN_Sessions_OnDelete_RemoveAllEmps(),
    FN_Updates_OnAdd_CheckSessionValidity(),
    FN_Departments_BeforeDelete_Check(),
    FN_Joins_BeforeInsert_Check(),
    FN_contact_tracing(),
    FN_Employees_AfterUpdate_EditAffectedMeetings(),
    FN_Sessions_BeforeUpdate_Approval_Check();

-- ###########################
--        Basic Functions
-- ###########################

CREATE OR REPLACE PROCEDURE add_department(did INTEGER, dname TEXT) AS $$
    BEGIN
        INSERT INTO Departments (did, dname) VALUES (did, dname);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE remove_department(_did INTEGER) AS $$
    BEGIN
    DELETE FROM Departments WHERE did = _did;
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_room(eid INTEGER, did INTEGER, floor INTEGER, room INTEGER, rname TEXT, capacity INTEGER) AS $$
    BEGIN
        -- check if this eid is a manager. 
        INSERT INTO Meeting_Rooms (did, room, floor, rname) VALUES (did, room, floor, rname);
        -- insert into updates table (non-trigger implementation)
        INSERT INTO Updates (date, room, floor, new_cap, eid) VALUES (CURRENT_DATE, room, floor, capacity, eid);
    END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_employee(ename TEXT, contact_number TEXT, kind KIND, did INTEGER) AS $$
    DECLARE
        created_eid INTEGER;
        created_email TEXT;
    BEGIN
        -- Temporarily set email to be NULL as we require the auto-generated eid to create email
        INSERT INTO Employees(ename, email, did, resigned_date) 
        VALUES (ename, NULL, did, NULL) 
        RETURNING eid INTO created_eid;

        -- Create and set email by concatenating name and eid (guaranteed to be unique)
        created_email = CONCAT(created_eid::TEXT, '@company.com');
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

CREATE OR REPLACE PROCEDURE change_capacity (_floor INTEGER, _room INTEGER, _cap INTEGER, _date DATE, _eid INTEGER) AS $$
    DECLARE
        room_dept INTEGER = NULL;
    BEGIN
        -- get room_dept (did)
        SELECT did INTO room_dept FROM Meeting_Rooms mr WHERE mr.room = _room AND mr.floor = _floor;
        
        -- valid manager
        IF (_eid NOT IN (SELECT eid FROM Manager)) THEN
            RAISE EXCEPTION 'Only Managers are allowed to update capacity';
        ELSEIF (_eid NOT IN (
            SELECT emps.eid 
            FROM Employees emps, Manager mngs 
            WHERE emps.eid = mngs.eid AND emps.did = room_dept)
        ) THEN
            RAISE EXCEPTION 'Ensure Manager is from same department as the room';
        ELSEIF ((SELECT resigned_date 
                FROM Employees 
                WHERE eid = _eid) IS NOT NULL
        ) THEN
            RAISE EXCEPTION 'Attempt by resigned employee to change capacity!';
            
        ELSE
            --add a new entry to updates table, reflecting change in room's capacity
            INSERT INTO Updates (date,room,floor,new_cap,eid) VALUES (_date, _room, _floor, _cap,_eid);
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE remove_employee(eid1 INTEGER, resigned_date1 DATE) AS $$
    UPDATE Employees SET resigned_date = resigned_date1 WHERE eid = eid1;
$$ LANGUAGE sql;

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
        WHERE qcapacity <= (
            SELECT new_cap 
            FROM Updates u 
            WHERE u.room = mr.room 
                AND u.floor = mr.floor
                AND u.date <= qdate
            ORDER BY u.date DESC
            LIMIT 1
        )
        EXCEPT
        -- Rooms that have sessions on the given date and within the range
        SELECT mr.did, mr.room, mr.floor, mr.rname
        FROM Sessions s INNER JOIN Meeting_Rooms mr 
            ON s.room = mr.room 
            AND s.floor = mr.floor
            AND qdate = s.date
            AND s.time >= stripped_start_hour
            AND s.time < stripped_end_hour;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION employee_concurrent_meeting(_eid INTEGER, _date DATE, _start_hour TIME, _end_hour TIME) 
RETURNS BOOLEAN AS $$
    DECLARE
        in_concurrent_meeting BOOLEAN := FALSE;
        count INTEGER;
    BEGIN
        WHILE _start_hour < _end_hour LOOP
            SELECT COUNT(*) INTO count FROM Joins WHERE eid = _eid AND date = _date AND time = _start_hour;
            IF count > 0 THEN
                in_concurrent_meeting := TRUE;
                EXIT;
            END IF;
            _start_hour := _start_hour + INTERVAL '1 hour'; 
        END LOOP;
        RETURN in_concurrent_meeting;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE book_room(_floor INTEGER, _room INTEGER, _date DATE, _start_hour TIME, 
    _end_hour TIME, _booker_eid INTEGER) 
AS $$
    DECLARE
        room_available INTEGER;
        is_booker INTEGER;
        current_hour TIME := _start_hour;
        have_fever BOOLEAN;
        in_concurrent_meeting BOOLEAN;
    BEGIN
        IF (_date = CURRENT_DATE AND _start_hour > CURRENT_TIME) OR _date > CURRENT_DATE THEN
            --this also handles when cap=0, as search room will give rooms with cap>0
            SELECT COUNT(*) INTO room_available 
            FROM search_room(1, _date, _start_hour, _end_hour) 
            WHERE floor = _floor AND room = _room;

            IF (room_available > 0) THEN
                SELECT fever INTO have_fever FROM Health_Declaration WHERE date = CURRENT_DATE AND eid = _booker_eid;
                -- raise notice 'hf %, cd % , ct %', have_fever, CURRENT_DATE, CURRENT_TIME;
                IF have_fever = TRUE THEN
                    RAISE EXCEPTION 'Employees having a fever cannot book a room';
                END IF;

                SELECT COUNT(*) INTO is_booker
                FROM Booker NATURAL JOIN Employees
                WHERE eid = _booker_eid
                AND resigned_date IS NULL;

                IF (is_booker) > 0 THEN
                    SELECT employee_concurrent_meeting(_booker_eid, _date, _start_hour, _end_hour) INTO in_concurrent_meeting;
                    --Raise notice 'con %', a;
                    IF in_concurrent_meeting = TRUE THEN
                        RAISE EXCEPTION 'Booker is already in a different meeting in the specified date and time';
                    END IF;

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
        ELSE
            RAISE EXCEPTION 'Bookings can only be made for future meetings';
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE unbook_room(_floor INTEGER, _room INTEGER, _date DATE, _start_hour TIME, _end_hour TIME, 
    _booker_eid INTEGER) 
AS $$
    DECLARE
        is_booker INTEGER;
        session_exists INTEGER;
        current_hour_check TIME := _start_hour;
        current_hour_remove TIME := _start_hour;
    BEGIN
        IF _start_hour >= _end_hour THEN
            RAISE EXCEPTION 'Start hour should be earlier than end hour';
        END IF;

        WHILE current_hour_check < _end_hour LOOP
            SELECT COUNT(*) INTO session_exists
            FROM Sessions s
            WHERE s.floor = _floor AND
            s.room = _room AND
            s.date = _date AND
            s.time = current_hour_check;

            IF (session_exists) = 0 THEN
                RAISE EXCEPTION 'Not all sessions in this time range have been booked';
            END IF;

            SELECT s.booker_eid INTO is_booker
            FROM Sessions s
            WHERE s.floor = _floor AND
            s.room = _room AND
            s.date = _date AND
            s.time = current_hour_check AND
            s.booker_eid = _booker_eid; -- Ensure only booker of the session can unbook

            IF (is_booker) IS NULL THEN
                RAISE EXCEPTION 'Only the booker of the session can unbook';
            END IF;

            current_hour_check := current_hour_check + INTERVAL '1 hour';
        END LOOP;

        WHILE current_hour_remove < _end_hour LOOP
            -- Remove the session
            DELETE FROM Sessions s 
            WHERE s.time = current_hour_remove 
            AND s.date = _date 
            AND s.room = _room 
            AND s.floor = _floor 
            AND s.booker_eid = _booker_eid;

            -- Remove all employees associated with the session
            DELETE FROM Joins j
            WHERE j.floor = _floor AND
            j.room = _room AND
            j.date = _date AND
            j.time = current_hour_remove;

            current_hour_remove := current_hour_remove + INTERVAL '1 hour';
        END LOOP;

    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE join_meeting(_floor INTEGER, _room INTEGER, _date DATE, _start_hour TIME, _end_hour TIME,
    _eid INTEGER) AS $$
DECLARE
    current_hour_check TIME := _start_hour;
BEGIN
    while current_hour_check < _end_hour LOOP
        INSERT INTO Joins VALUES (_eid, _room, _floor, current_hour_check, _date);
        current_hour_check := current_hour_check + INTERVAL '1 hour';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE leave_meeting(_floor INTEGER, _room INTEGER, _date DATE, _start_hour TIME, _end_hour TIME, 
    _eid INTEGER) 
AS $$
    DECLARE
        approver_eid INTEGER;
        booker_eid INTEGER;
        current_hour_check TIME := _start_hour;
        current_hour_remove TIME := _start_hour;
    BEGIN
        WHILE current_hour_check < _end_hour LOOP
            SELECT s.approver_eid, s.booker_eid INTO approver_eid, booker_eid
            FROM Sessions s
            WHERE s.floor = _floor AND
            s.room = _room AND
            s.date = _date AND
            s.time = current_hour_check;

            -- Ensure employee can only leave unapproved meetings
            IF approver_eid IS NOT NULL THEN
                RAISE EXCEPTION 'Session starting at % already approved, employees may not leave an approved session.', current_hour_check; 
            END IF;

            -- Ensure booker cannot leave a session they have booked themselves
            IF booker_eid = _eid THEN
                RAISE EXCEPTION 'Session starting at % is booked by this employee, employees may not leave a session they have booked themselves.', current_hour_check;
            END IF;

            current_hour_check := current_hour_check + INTERVAL '1 hour';
        END LOOP;

        WHILE current_hour_remove < _end_hour LOOP
            DELETE FROM Joins
            WHERE floor = _floor AND
            room = _room AND
            date = _date AND
            time = current_hour_remove AND
            eid = _eid;

            current_hour_remove := current_hour_remove + INTERVAL '1 hour';
        END LOOP;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE approve_meeting(_floor INTEGER, _room INTEGER, _date DATE, _start_hour TIME, _end_hour TIME,
 _eid INTEGER) AS $$
    DECLARE
        room_dept INTEGER = NULL;
        a_eid INTEGER = NULL;
    BEGIN
        --valid manager_check.
        --prevent past meeting.
        --sessions exists check.
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

-- #############################
--        Health Functions
-- #############################

CREATE OR REPLACE PROCEDURE declare_health(_eid INTEGER, _date DATE, _temperature FLOAT(1)) AS $$
    BEGIN
        IF (SELECT resigned_date FROM Employees WHERE eid = _eid) IS NOT NULL THEN
            RAISE EXCEPTION 'Employee has resigned';
        END IF;

        IF (SELECT eid FROM Health_Declaration WHERE date = _date AND eid = _eid) IS NOT NULL THEN
            UPDATE Health_Declaration SET temp = _temperature WHERE date = _date AND eid = _eid;
        ELSE 
            INSERT INTO Health_Declaration values (_date, _eid, _temperature);
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION contact_tracing(_eid INTEGER, _date DATE) RETURNS TABLE (
    eid INTEGER
) AS $$
    DECLARE
        is_fever BOOLEAN;
        temp_mr RECORD;
        temp_eid RECORD;
        original_eid RECORD;
    BEGIN
        CREATE TEMP TABLE result(eid INTEGER) ON COMMIT DROP;
        SELECT fever FROM Health_Declaration h WHERE h.eid = _eid INTO is_fever;

        -- do nothing and return empty table 
        IF (is_fever = FALSE) THEN
            RETURN QUERY SELECT r.eid FROM result r;
        END IF;

        -- remove the fever employee from all future meeting room booking, approved or not
        CALL remove_fever_employee_from_all_meetings(_date, _eid);

        FOR temp_mr IN 
            -- find all meeting rooms the employee had a meeting in in the past 3 days
            SELECT room, floor FROM three_day_employee_room(_eid, _date)
        LOOP    
            -- find all employees that were in the meeting room in the past 3 days
            FOR temp_eid IN
                SELECT tdre.eid FROM three_day_room_employee(temp_mr.floor, temp_mr.room, _date) tdre
            LOOP
                -- removes the employee from future meeting (both approved and not approved) in the next 7 days
                CALL remove_employee_from_future_meeting_seven_days(_date, temp_eid.eid);
                
                -- add the eid to our result
                INSERT INTO result values(temp_eid.eid);
            END LOOP;
        END LOOP;

        -- exclude queried employee as close contact
        RETURN QUERY 
            SELECT DISTINCT r.eid 
            FROM result r
            EXCEPT 
            SELECT e.eid
            FROM employees e
            WHERE e.eid = _eid
            ORDER BY eid;
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
        FROM Joins j NATURAL JOIN Sessions s
        WHERE j.eid = _eid
        AND j.date <= start_date
        AND j.date >= start_date - 3 -- from day D-3 to day D (according to doc)
        AND s.approver_eid IS NOT NULL; -- ensure meeting has occurred
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

CREATE OR REPLACE PROCEDURE remove_fever_employee_from_all_meetings(_date DATE, _eid INTEGER) AS $$
BEGIN
    --it is assumed that _eid is already known to have a fever.
    --the constraint of all future meeting is understood as: meeting's date >= current_date

    --delete entire sessions if booker (trigger)
    IF(_eid IN (SELECT eid FROM Booker)) THEN
        DELETE FROM Sessions
        WHERE
            booker_eid = _eid
            AND
            date >= _date;
    END IF;
    --continue on the delete other sessions booker/or employee inside
    DELETE FROM Joins
    WHERE
        eid = _eid
        AND
        date >= _date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE remove_employee_from_future_meeting_seven_days(_date DATE, _eid INTEGER) AS $$
BEGIN
    --delete entire sessions + join entries if _eid is a booker (trigger)
    IF(_eid IN (SELECT eid FROM Booker)) THEN
        DELETE FROM Sessions
        WHERE
            booker_eid = _eid
            AND
            date >= _date
            AND
            date <= _date + 7;
    END IF;

    --delete relevant join entries
    DELETE FROM Joins
    WHERE
        eid = _eid
        AND
        date >= _date
        AND
        date <= _date + 7;
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
        IF (start_date > end_date) THEN 
            RAISE EXCEPTION 'Start date must be before end date';
        END IF;

        RETURN QUERY
        SELECT hd.eid, CAST((end_date - start_date + 1) - COUNT(*) AS INTEGER)
        FROM Health_Declaration hd
        WHERE hd.date >= start_date AND hd.date <= end_date
        GROUP BY hd.eid
        HAVING CAST((end_date - start_date + 1) - COUNT(*) AS INTEGER) > 0
        ORDER BY CAST((end_date - start_date + 1) - COUNT(*) AS INTEGER) DESC, hd.eid;
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

CREATE OR REPLACE FUNCTION view_future_meeting(start_date DATE, _eid INTEGER)
RETURNS TABLE (
    floor INTEGER, 
    room INTEGER, 
    date DATE, 
    start_hour TIME
) AS $$
    DECLARE
    BEGIN
        --since only approved meetings can be viewed, need 'Sessions' table as well.
        RETURN QUERY
        SELECT s.floor,s.room,s.date,s.time 
        FROM 
        Joins j JOIN Sessions s 
        ON 
            j.room = s.room 
            AND 
            j.floor = s.floor 
            AND 
            s.time = j.time 
            AND 
            s.date = j.date 
        WHERE 
        s.date >= start_date AND j.eid = _eid
        AND
        s.approver_eid IS NOT NULL
        ORDER BY s.date, s.time ASC;
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
                    --check here
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

CREATE OR REPLACE FUNCTION FN_Departments_BeforeDelete_Check() RETURNS TRIGGER AS $$
    DECLARE
        has_employees INTEGER;
        has_meeting_rooms INTEGER;
    BEGIN
    SELECT COUNT(*) INTO has_employees
    FROM Employees e
    WHERE e.did = OLD.did;
    IF has_employees > 0 THEN
        RAISE NOTICE 'There are still employees in this department that have yet to be transferred or removed';
        RETURN NULL;
    END IF;

    SELECT COUNT(*) INTO has_meeting_rooms
    FROM Meeting_Rooms mr
    WHERE mr.did = OLD.did;
    IF has_meeting_rooms > 0 THEN
        RAISE NOTICE 'There are still meeting rooms associated with this department';
        RETURN NULL;
    END IF;
    END;
$$ LANGUAGE plpgsql;

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
    ELSEIF( ((SELECT resigned_date FROM Employees WHERE eid = NEW.eid) IS NOT NULL) AND 
            ((SELECT resigned_date FROM Employees WHERE eid = NEW.eid) > NEW.date)
          ) THEN
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

-- Wrapper trigger function that calls contact tracing function
CREATE OR REPLACE FUNCTION FN_contact_tracing() RETURNS TRIGGER AS $$
BEGIN
    PERFORM contact_tracing(NEW.eid, NEW.date);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FN_Employees_AfterUpdate_EditAffectedMeetings()
RETURNS TRIGGER AS $$
    DECLARE
    is_booker BOOLEAN;
    is_manager BOOLEAN;
    BEGIN
        IF NEW.resigned_date IS NOT NULL THEN
            SELECT (EXISTS (SELECT 1 FROM MANAGER WHERE eid = NEW.eid)) INTO is_manager;
            SELECT (EXISTS (SELECT 1 FROM BOOKER WHERE eid = NEW.eid)) INTO is_booker;

            IF is_manager = TRUE THEN
                UPDATE Sessions SET approver_eid = NULL 
                WHERE date > NEW.resigned_date
                AND approver_eid = NEW.eid;
            END IF;

            IF is_booker = TRUE THEN
                DELETE FROM Joins j 
                USING Sessions s
                WHERE s.booker_eid = NEW.eid
                AND j.room = s.room AND j.floor = s.floor AND j.date = s.date AND j.time = s.time
                AND j.date > NEW.resigned_date;

                DELETE FROM Sessions
                WHERE booker_eid = NEW.eid
                AND date > NEW.resigned_date;

            END IF;
                
                DELETE from Joins 
                WHERE eid = NEW.eid 
                AND date > NEW.resigned_date;

        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FN_Updates_BeforeInsert_Check_Manager_Validity()
RETURNS TRIGGER AS $$
    DECLARE
        valid_manager_check INTEGER := 0;
    BEGIN
        --still check dept manager = updating manager
        SELECT COUNT(*) INTO valid_manager_check
        FROM ((SELECT eid,did FROM Manager NATURAL JOIN Employees) AS me
             NATURAL JOIN Meeting_Rooms) AS t
        WHERE
            t.eid = NEW.eid AND
            t.room = NEW.room AND
            t.floor = NEW.floor;

        --rare case of a manager belonging to 2 departments
        IF(valid_manager_check >= 1) THEN
            RETURN NEW;
        ELSE
            RAISE NOTICE 'Manager (%) not in same department as Meeting Room (r:%, f:%)',
            NEW.eid, NEW.room, NEW.floor;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

/*
CREATE OR REPLACE FUNCTION FN_Sessions_BeforeUpdate_Approval_Check()
RETURNS TRIGGER AS $$
    DECLARE
    BEGIN
        --as manager now takes in _eid no need to check if its manager.
    END;
$$ LANGUAGE plpgsql;
*/

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

CREATE TRIGGER TR_Departments_BeforeDelete_Check
BEFORE DELETE ON Departments
FOR EACH ROW EXECUTE FUNCTION FN_Departments_BeforeDelete_Check();

CREATE TRIGGER TR_Employees_AfterUpdate_EditAffectedMeetings
AFTER UPDATE ON Employees
FOR EACH ROW EXECUTE FUNCTION FN_Employees_AfterUpdate_EditAffectedMeetings();

CREATE TRIGGER TR_Joins_BeforeInsert_Check
BEFORE INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION FN_Joins_BeforeInsert_Check();

CREATE TRIGGER TR_Health_Declaration_AfterInsertUpdate_Contact_Tracing
AFTER INSERT OR UPDATE ON Health_Declaration 
FOR EACH ROW WHEN (NEW.fever = TRUE) EXECUTE FUNCTION FN_contact_tracing();

CREATE TRIGGER TR_Updates_BeforeInsert_Check_Manager_Validity
BEFORE INSERT ON Updates
FOR EACH ROW EXECUTE FUNCTION FN_Updates_BeforeInsert_Check_Manager_Validity();


/*
CREATE TRIGGER TR_Sessions_BeforeUpdate_Approval_Check
BEFORE UPDATE ON Sessions
FOR EACH ROW EXECUTE FN_Sessions_BeforeUpdate_Approval_Check();
*/

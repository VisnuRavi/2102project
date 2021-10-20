/*change capacity
change_capacity: This routine is used to change the capacity of the room. 
The inputs to the routine should minimally include: 
Floor number 
Room number 
Capacity 
Date
The date is assumed to be today but is given as part of the input for simplicity.
*/
-- CALL change_capacity(1,'big room', 20, )
CREATE OR REPLACE PROCEDURE change_capacity
    (IN floor INTEGER, IN room TEXT, IN ncap INTEGER, IN date DATE, IN manager_eid INTEGER)
AS $$
    UPDATE Updates u
    SET new_cap = ncap
    WHERE
        u.floor = floor
        AND
        u.room = room
        AND
        u.date = date
        AND
        u.eid = manager_eid
$$ LANGUAGE sql;



/*
join_meeting: This routine is used to join a booked meeting room. 
The inputs to the routine should    minimally include:
Floor number Room number Date Start hour End hour Employee ID
The employee ID is the ID of the employee that is joining the booked meeting room.
If the employee is allowed to join (see the conditions necessary for this in Application), 
the routine will process the join. Since an approved meeting
cannot have a change in participants, the employee is not allowed to join an approved meeting.
*/

/*
approve_meeting: 
This routine is used to approve a booking. 
The inputs to the routine should minimally include: 
Floor number Room number Date Start hour End hour Employee ID
The employee ID is the ID of the manager that is approving the booking. 
If the approval is allowed (see the
conditions necessary for this in Application), the routine will process the approval.
*/

--test data for 2102 project
--departments

INSERT INTO Departments VALUES
--did format: 9xx 
--ddname format: dept9xx
(900,'dept900'),
(901,'dept901'),
(902,'dept902'),
(903,'dept903'),
(904,'dept904');

--employees
INSERT INTO Employees VALUES
--eid format: junior-> 1xx, senior->2xx, manager-><3xx
--ename format: name_<type>_<eid>
--email format: <ename>@mail.com
--did: each department has 2 juniors, 2 seniors, 2 managers
--resign_date: default null

(100, 'name_j_100', 'name_j_100@mail.com', 900, NULL),
(101, 'name_j_101', 'name_j_101@mail.com', 900, NULL),
(200, 'name_s_200', 'name_s_200@mail.com', 900, NULL),
(201, 'name_s_201', 'name_s_201@mail.com', 900, NULL),
(300, 'name_m_300', 'name_m_300@mail.com', 900, NULL),
(301, 'name_m_301', 'name_m_301@mail.com', 900, NULL),

(102, 'name_j_102', 'name_j_102@mail.com', 901, NULL),
(103, 'name_j_103', 'name_j_103@mail.com', 901, NULL),
(202, 'name_s_202', 'name_s_202@mail.com', 901, NULL),
(203, 'name_s_203', 'name_s_203@mail.com', 901, NULL),
(302, 'name_m_302', 'name_m_302@mail.com', 901, NULL),
(303, 'name_m_303', 'name_m_303@mail.com', 901, NULL),

(104, 'name_j_104', 'name_j_104@mail.com', 902, NULL),
(105, 'name_j_105', 'name_j_105@mail.com', 902, NULL),
(204, 'name_s_204', 'name_s_204@mail.com', 902, NULL),
(205, 'name_s_205', 'name_s_205@mail.com', 902, NULL),
(304, 'name_m_304', 'name_m_304@mail.com', 902, NULL),
(305, 'name_m_305', 'name_m_305@mail.com', 902, NULL),

(106, 'name_j_106', 'name_j_106@mail.com', 903, NULL),
(107, 'name_j_107', 'name_j_107@mail.com', 903, NULL),
(206, 'name_s_206', 'name_s_206@mail.com', 903, NULL),
(207, 'name_s_207', 'name_s_207@mail.com', 903, NULL),
(306, 'name_m_306', 'name_m_306@mail.com', 903, NULL),
(307, 'name_m_307', 'name_m_307@mail.com', 903, NULL),

(108, 'name_j_108', 'name_j_108@mail.com', 904, NULL),
(109, 'name_j_109', 'name_j_109@mail.com', 904, NULL),
(208, 'name_s_208', 'name_s_208@mail.com', 904, NULL),
(209, 'name_s_209', 'name_s_209@mail.com', 904, NULL),
(308, 'name_m_308', 'name_m_308@mail.com', 904, NULL),
(309, 'name_m_309', 'name_m_309@mail.com', 904, NULL);

--Health declaration
INSERT INTO Health_Declaration (date, eid, temp) VALUES
--date: CURRENT_DATE
--eid: all the eids
--temp: 37.5
--current date used for testing purposes
(CURRENT_DATE,100, 37.5),
(CURRENT_DATE,101, 37.5),
(CURRENT_DATE,200, 37.5),
(CURRENT_DATE,201, 37.5),
(CURRENT_DATE,300, 37.5),
(CURRENT_DATE,301, 37.5),
(CURRENT_DATE,102, 37.5),
(CURRENT_DATE,103, 37.5),
(CURRENT_DATE,202, 37.5),
(CURRENT_DATE,203, 37.5),
(CURRENT_DATE,302, 37.5),
(CURRENT_DATE,303, 37.5),
(CURRENT_DATE,104, 37.5),
(CURRENT_DATE,105, 37.5),
(CURRENT_DATE,204, 37.5),
(CURRENT_DATE,205, 37.5),
(CURRENT_DATE,304, 37.5),
(CURRENT_DATE,305, 37.5),
(CURRENT_DATE,106, 37.5),
(CURRENT_DATE,107, 37.5),
(CURRENT_DATE,206, 37.5),
(CURRENT_DATE,207, 37.5),
(CURRENT_DATE,306, 37.5),
(CURRENT_DATE,307, 37.5),
(CURRENT_DATE,108, 37.5),
(CURRENT_DATE,109, 37.5),
(CURRENT_DATE,208, 37.5),
(CURRENT_DATE,209, 37.5),
(CURRENT_DATE,308, 37.5),
(CURRENT_DATE,309, 37.5);

/*
('2000-12-31',100, 37.5),
('2000-12-31',101, 37.5),
('2000-12-31',200, 37.5),
('2000-12-31',201, 37.5),
('2000-12-31',300, 37.5),
('2000-12-31',301, 37.5),
('2000-12-31',102, 37.5),
('2000-12-31',103, 37.5),
('2000-12-31',202, 37.5),
('2000-12-31',203, 37.5),
('2000-12-31',302, 37.5),
('2000-12-31',303, 37.5),
('2000-12-31',104, 37.5),
('2000-12-31',105, 37.5),
('2000-12-31',204, 37.5),
('2000-12-31',205, 37.5),
('2000-12-31',304, 37.5),
('2000-12-31',305, 37.5),
('2000-12-31',106, 37.5),
('2000-12-31',107, 37.5),
('2000-12-31',206, 37.5),
('2000-12-31',207, 37.5),
('2000-12-31',306, 37.5),
('2000-12-31',307, 37.5),
('2000-12-31',108, 37.5),
('2000-12-31',109, 37.5),
('2000-12-31',208, 37.5),
('2000-12-31',209, 37.5),
('2000-12-31',308, 37.5),
('2000-12-31',309, 37.5);
*/

INSERT INTO Contact_Numbers VALUES
(100, '+6510045678'),
(101, '+6510145678'),
(200, '+6520045678'),
(201, '+6520145678'),
(300, '+6530045678'),
(301, '+6530145678'),

(102, '+6510245678'),
(103, '+6510345678'),
(202, '+6520245678'),
(203, '+6520345678'),
(302, '+6530245678'),
(303, '+6530345678'),

(104, '+6510445678'),
(105, '+6510545678'),
(204, '+6520445678'),
(205, '+6520545678'),
(304, '+6530445678'),
(305, '+6530545678'),

(106, '+6510645678'),
(107, '+6510745678'),
(206, '+6520645678'),
(207, '+6520745678'),
(306, '+6530645678'),
(307, '+6530745678'),

(108, '+6510845678'),
(109, '+6510945678'),
(208, '+6520845678'),
(209, '+6520945678'),
(308, '+6530845678'),
(309, '+6530945678');

INSERT INTO Booker VALUES
(200),
(201),
(202),
(203),
(204),
(205),
(206),
(207),
(208),
(209),
(300),
(301),
(302),
(303),
(304),
(305),
(306),
(307),
(308),
(309);



INSERT INTO Junior VALUES
(100),
(102),
(104),
(106),
(108);
INSERT INTO Junior VALUES
(101),
(103),
(105),
(107),
(109);



INSERT INTO Senior VALUES
(200),
(202),
(204),
(206),
(208);
INSERT INTO Senior VALUES
(201),
(203),
(205),
(207),
(209);


INSERT INTO Manager VALUES
(300),
(302),
(304),
(306),
(308);
INSERT INTO Manager VALUES
(301),
(303),
(305),
(307),
(309);


--capacity removed from meeting rooms
INSERT INTO Meeting_Rooms VALUES
(900, 0, 0, 'bigroom'),
(900, 1, 0, 'smallroom'),
(901, 0, 1, 'bigroom'),
(901, 1, 1, 'smallroom'),
(902, 0, 2, 'bigroom'),
(902, 1, 2, 'smallroom'),
(903, 0, 3, 'bigroom'),
(903, 1, 3, 'smallroom'),
(904, 0, 4, 'bigroom'),
(904, 1, 4, 'smallroom');
/*debugging: #81
INSERT INTO Meeting_Rooms VALUES
(904, 1, 11, 'testingroom');
*/

--capacity added via updates table
INSERT INTO Updates Values
(CURRENT_DATE, 0, 0, 6),
(CURRENT_DATE, 1, 0, 6),
(CURRENT_DATE, 0, 1, 6),
(CURRENT_DATE, 1, 1, 6),
(CURRENT_DATE, 0, 2, 6),
(CURRENT_DATE, 1, 2, 6),
(CURRENT_DATE, 0, 3, 6),
(CURRENT_DATE, 1, 3, 6),
(CURRENT_DATE, 0, 4, 6),
(CURRENT_DATE, 1, 4, 6);
/*debugging: #81
INSERT INTO Updates VALUES
(CURRENT_DATE, 1, 11, 10);
*/


/*
CALL add_room(900, 0, 0, 'bigroom', 6);
CALL add_room(900, 0, 1, 'smallroom', 6);
CALL add_room(901, 1, 1, 'bigroom', 6);
CALL add_room(901, 1, 0, 'smallroom', 6);
CALL add_room(902, 2, 1, 'bigroom', 6);
CALL add_room(902, 2, 0, 'smallroom', 6);
CALL add_room(903, 3, 1, 'bigroom', 6);
CALL add_room(903, 3, 0, 'smallroom', 6);
CALL add_room(904, 4, 1, 'bigroom', 6);
CALL add_room(904, 4, 0, 'smallroom', 6);


--change capacity -> 7 days later
CALL change_capacity(0, 0, 2, CURRENT_DATE + 7, 300);
CALL change_capacity(0, 1, 2, CURRENT_DATE + 7, 301);
CALL change_capacity(1, 0, 2, CURRENT_DATE + 7, 302);
CALL change_capacity(1, 1, 2, CURRENT_DATE + 7, 303);
CALL change_capacity(2, 0, 2, CURRENT_DATE + 7, 304);
CALL change_capacity(2, 1, 2, CURRENT_DATE + 7, 305);
CALL change_capacity(3, 0, 2, CURRENT_DATE + 7, 306);
CALL change_capacity(3, 1, 2, CURRENT_DATE + 7, 307);
CALL change_capacity(4, 0, 2, CURRENT_DATE + 7, 308);
CALL change_capacity(4, 1, 2, CURRENT_DATE + 7, 309);
*/

/*debugging: #81
CALL change_capacity(11, 1, 2, '2021-11-03', 309);
CALL change_capacity(11, 1, 3, '2021-11-04', 309);
*/


/*
--test for capacity change
CALL change_capacity(0, 0, 2, CURRENT_DATE + 1, 300);
CALL change_capacity(1, 0, 2, CURRENT_DATE + 1, 302);
CALL change_capacity(2, 0, 2, CURRENT_DATE + 1, 304);
*/

--creating 8 sessions -> 2 per department -> same meeting room per dept, but different dates (cap change)
--booker id -> senior
--approver_id = NULL
INSERT INTO Sessions VALUES
('10:00:00', CURRENT_DATE, 0, 0, 200,NULL),
('10:00:00', CURRENT_DATE + 7, 0, 0, 200,NULL),
('10:00:00', CURRENT_DATE, 0, 1, 202,NULL),
('10:00:00', CURRENT_DATE + 7, 0, 1, 202,NULL),
('10:00:00', CURRENT_DATE, 0, 2, 204,NULL),
('10:00:00', CURRENT_DATE + 7, 0, 2, 204,NULL),
('10:00:00', CURRENT_DATE, 0, 3, 206,NULL),
('10:00:00', CURRENT_DATE + 7, 0, 3, 206,NULL);
/*debugging: #81
INSERT INTO Sessions VALUES
('10:00:00', CURRENT_DATE, 1, 11, 206,NULL),
('10:00:00', '2021-11-03', 1, 11, 206,NULL),
('10:00:00', '2021-11-04', 1, 11, 206,NULL);
*/


/*
--test for capacity change
INSERT INTO Sessions VALUES
('10:00:00', CURRENT_DATE + 6, 0, 0, 200,NULL),
('10:00:00', CURRENT_DATE + 7, 0, 0, 200,NULL),
('10:00:00', CURRENT_DATE + 8, 0, 0, 200,NULL);
*/


--join meetings test

--booker already inside for that session
INSERT INTO Joins VALUES
(200, 0, 0, '10:00:00', CURRENT_DATE),
(200, 0, 0, '10:00:00', CURRENT_DATE + 7),
(202, 0, 1, '10:00:00', CURRENT_DATE),
(202, 0, 1, '10:00:00', CURRENT_DATE + 7),
(204, 0, 2, '10:00:00', CURRENT_DATE),
(204, 0, 2, '10:00:00', CURRENT_DATE + 7),
(206, 0, 3, '10:00:00', CURRENT_DATE),
(206, 0, 3, '10:00:00', CURRENT_DATE + 7);
/*debugging: #81
--booker
INSERT INTO Joins VALUES
(206, 1, 11, '10:00:00', CURRENT_DATE),
(206, 1, 11, '10:00:00', '2021-11-03'),
(206, 1, 11, '10:00:00', '2021-11-04');
--session 1: 9 more pax allowed in
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 100);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 101);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 102);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 103);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 104);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 105);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 106);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 107);
CALL join_meeting(11,1, CURRENT_DATE, '10:00:00', 108);
--session 2: 1 more pax allowed in
CALL join_meeting(11,1,'2021-11-03' , '10:00:00', 100);
--session 3: 2 more pax allowed in
CALL join_meeting(11,1,'2021-11-04' , '10:00:00', 100);
CALL join_meeting(11,1,'2021-11-04' , '10:00:00', 101);
*/

/*
--test booker (should throw error)
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 200);


--employees (except booker) from each dept try to join meeting 1 (cap: 6) and meeting 2 (cap: 2)
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 301);


CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 301);
*/


/*
--test for capacity change
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE, '10:00:00', 301);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '10:00:00', 301);


CALL join_meeting(1, 0, CURRENT_DATE, '10:00:00', 102);
CALL join_meeting(1, 0, CURRENT_DATE, '10:00:00', 103);
CALL join_meeting(1, 0, CURRENT_DATE, '10:00:00', 203);
CALL join_meeting(1, 0, CURRENT_DATE, '10:00:00', 302);
CALL join_meeting(1, 0, CURRENT_DATE, '10:00:00', 303);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '10:00:00', 102);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '10:00:00', 103);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '10:00:00', 203);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '10:00:00', 302);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '10:00:00', 303);

CALL join_meeting(2, 0, CURRENT_DATE, '10:00:00', 104);
CALL join_meeting(2, 0, CURRENT_DATE, '10:00:00', 105);
CALL join_meeting(2, 0, CURRENT_DATE, '10:00:00', 205);
CALL join_meeting(2, 0, CURRENT_DATE, '10:00:00', 304);
CALL join_meeting(2, 0, CURRENT_DATE, '10:00:00', 305);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '10:00:00', 104);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '10:00:00', 105);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '10:00:00', 205);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '10:00:00', 304);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '10:00:00', 305);
*/

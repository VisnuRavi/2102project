--test data for 2102 project
--departments

INSERT INTO Departments VALUES
--did format: 9xx 
--ddname format: dept9xx
(900,'dept900'),
(901,'dept901'),
(902,'dept902'),
(903,'dept903'),
(904,'dept904'),
(905,'dept905'),
(906,'dept906'),
(907,'dept907'),
(908,'dept908'),
(909,'dept909'),
(910,'dept910');

--employees
INSERT INTO Employees (eid, ename, did, resigned_date) VALUES
--eid format: junior-> 1xx, senior->2xx, manager-><3xx
--ename format: name_<type>_<eid>
--email format: <eid>DEFAULT
--did: each department has 2 juniors, 2 seniors, 2 managers
--resign_date: default null

(100, 'name_j_100', 900, NULL),
(101, 'name_j_101', 900, NULL),
(200, 'name_s_200', 900, NULL),
(201, 'name_s_201', 900, NULL),
(300, 'name_m_300', 900, NULL),
(301, 'name_m_301', 900, NULL),

(102, 'name_j_102', 901, NULL),
(103, 'name_j_103', 901, NULL),
(202, 'name_s_202', 901, NULL),
(203, 'name_s_203', 901, NULL),
(302, 'name_m_302', 901, NULL),
(303, 'name_m_303', 901, NULL),

(104, 'name_j_104', 902, NULL),
(105, 'name_j_105', 902, NULL),
(204, 'name_s_204', 902, NULL),
(205, 'name_s_205', 902, NULL),
(304, 'name_m_304', 902, NULL),
(305, 'name_m_305', 902, NULL),

(106, 'name_j_106', 903, NULL),
(107, 'name_j_107', 903, NULL),
(206, 'name_s_206', 903, NULL),
(207, 'name_s_207', 903, NULL),
(306, 'name_m_306', 903, NULL),
(307, 'name_m_307', 903, NULL),

(108, 'name_j_108', 904, NULL),
(109, 'name_j_109', 904, NULL),
(208, 'name_s_208', 904, NULL),
(209, 'name_s_209', 904, NULL),
(308, 'name_m_308', 904, NULL),
(309, 'name_m_309', 904, NULL);

/*
debugging: #83 #80 #68
INSERT INTO Employees VALUES
(100, 'name_j_100', '100@mail.com', 900, NULL),
(101, 'name_j_101', '101@mail.com', 900, NULL),
(200, 'name_s_200', '200@mail.com', 900, NULL),
(201, 'name_s_201', '201@mail.com', 900, NULL),
(300, 'name_m_300', '300@mail.com', 900, NULL),
(301, 'name_m_301', '301@mail.com', 900, CURRENT_DATE),

(102, 'name_j_102', '102DEFAULT', 901, NULL),
(103, 'name_j_103', '103DEFAULT', 901, NULL),
(202, 'name_s_202', '202DEFAULT', 901, NULL),
(203, 'name_s_203', '203DEFAULT', 901, NULL),
(302, 'name_m_302', '302DEFAULT', 901, NULL),
(303, 'name_m_303', '303DEFAULT', 901, CURRENT_DATE),

(104, 'name_j_104', '104DEFAULT', 902, NULL),
(105, 'name_j_105', '105DEFAULT', 902, NULL),
(204, 'name_s_204', '204DEFAULT', 902, NULL),
(205, 'name_s_205', '205DEFAULT', 902, NULL),
(304, 'name_m_304', '304DEFAULT', 902, NULL),
(305, 'name_m_305', '305DEFAULT', 902, CURRENT_DATE),

(106, 'name_j_106', '106DEFAULT', 903, NULL),
(107, 'name_j_107', '107DEFAULT', 903, NULL),
(206, 'name_s_206', '206DEFAULT', 903, NULL),
(207, 'name_s_207', '207DEFAULT', 903, NULL),
(306, 'name_m_306', '306DEFAULT', 903, NULL),
(307, 'name_m_307', '307DEFAULT', 903, CURRENT_DATE),

(108, 'name_j_108', '108DEFAULT', 904, NULL),
(109, 'name_j_109', '109DEFAULT', 904, NULL),
(208, 'name_s_208', '208DEFAULT', 904, NULL),
(209, 'name_s_209', '209DEFAULT', 904, NULL),
(308, 'name_m_308', '308DEFAULT', 904, NULL),
(309, 'name_m_309', '309DEFAULT', 904, CURRENT_DATE);

*/




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

/*debugging: #83 #80 #68
INSERT INTO Health_Declaration (date, eid, temp) VALUES
(CURRENT_DATE,100, 37.6),
(CURRENT_DATE,200, 37.5),
(CURRENT_DATE,201, 37.5),
(CURRENT_DATE,300, 37.5),
(CURRENT_DATE,301, 37.5),
(CURRENT_DATE,102, 37.6),
(CURRENT_DATE,202, 37.5),
(CURRENT_DATE,203, 37.5),
(CURRENT_DATE,302, 37.5),
(CURRENT_DATE,303, 37.5),
(CURRENT_DATE,104, 37.6),
(CURRENT_DATE,204, 37.5),
(CURRENT_DATE,205, 37.5),
(CURRENT_DATE,304, 37.5),
(CURRENT_DATE,305, 37.5),
(CURRENT_DATE,106, 37.6),
(CURRENT_DATE,206, 37.5),
(CURRENT_DATE,207, 37.5),
(CURRENT_DATE,306, 37.5),
(CURRENT_DATE,307, 37.5),
(CURRENT_DATE,108, 37.6),
(CURRENT_DATE,208, 37.5),
(CURRENT_DATE,209, 37.5),
(CURRENT_DATE,308, 37.5),
(CURRENT_DATE,309, 37.5);
*/

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
(CURRENT_DATE-7, 0, 0, 6, 300),
(CURRENT_DATE-7, 1, 0, 6, 301),
(CURRENT_DATE-7, 0, 1, 6, 302),
(CURRENT_DATE-7, 1, 1, 6, 303),
(CURRENT_DATE-7, 0, 2, 6, 304),
(CURRENT_DATE-7, 1, 2, 6, 305),
(CURRENT_DATE-7, 0, 3, 6, 306),
(CURRENT_DATE-7, 1, 3, 6, 307),
(CURRENT_DATE-7, 0, 4, 6, 308),
(CURRENT_DATE-7, 1, 4, 6, 309);
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
debugging: #83 #80 #68
CALL change_capacity(0, 0, 2, '2021-11-03', 301);
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
('19:00:00', CURRENT_DATE, 0, 0, 200,NULL),
('19:00:00', CURRENT_DATE + 7, 0, 0, 200,NULL),
('19:00:00', CURRENT_DATE, 0, 1, 202,NULL),
('19:00:00', CURRENT_DATE + 7, 0, 1, 202,NULL),
('19:00:00', CURRENT_DATE, 0, 2, 204,NULL),
('19:00:00', CURRENT_DATE + 7, 0, 2, 204,NULL),
('19:00:00', CURRENT_DATE, 0, 3, 206,NULL),
('19:00:00', CURRENT_DATE + 7, 0, 3, 206,NULL);

/*debugging: #81
INSERT INTO Sessions VALUES
('19:00:00', CURRENT_DATE, 1, 11, 206,NULL),
('19:00:00', '2021-11-03', 1, 11, 206,NULL),
('19:00:00', '2021-11-04', 1, 11, 206,NULL);
*/


/*
--test for capacity change
INSERT INTO Sessions VALUES
('19:00:00', CURRENT_DATE + 6, 0, 0, 200,NULL),
('19:00:00', CURRENT_DATE + 7, 0, 0, 200,NULL),
('19:00:00', CURRENT_DATE + 8, 0, 0, 200,NULL);
*/


--join meetings test

--booker already inside for that session
INSERT INTO Joins VALUES
(200, 0, 0, '19:00:00', CURRENT_DATE),
(200, 0, 0, '19:00:00', CURRENT_DATE + 7),
(202, 0, 1, '19:00:00', CURRENT_DATE),
(202, 0, 1, '19:00:00', CURRENT_DATE + 7),
(204, 0, 2, '19:00:00', CURRENT_DATE),
(204, 0, 2, '19:00:00', CURRENT_DATE + 7),
(206, 0, 3, '19:00:00', CURRENT_DATE),
(206, 0, 3, '19:00:00', CURRENT_DATE + 7);
/*debugging: #81
--booker
INSERT INTO Joins VALUES
(206, 1, 11, '19:00:00', CURRENT_DATE),
(206, 1, 11, '19:00:00', '2021-11-03'),
(206, 1, 11, '19:00:00', '2021-11-04');
--session 1: 9 more pax allowed in
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 100);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 101);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 102);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 103);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 104);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 105);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 106);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 107);
CALL join_meeting(11,1, CURRENT_DATE, '19:00:00', 108);
--session 2: 1 more pax allowed in
CALL join_meeting(11,1,'2021-11-03' , '19:00:00', 100);
--session 3: 2 more pax allowed in
CALL join_meeting(11,1,'2021-11-04' , '19:00:00', 100);
CALL join_meeting(11,1,'2021-11-04' , '19:00:00', 101);
*/

/*
--test booker (should throw error)
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 200);


--employees (except booker) from each dept try to join meeting 1 (cap: 6) and meeting 2 (cap: 2)
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 301);


CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 301);
*/


/*
--test for capacity change
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE, '19:00:00', 301);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 100);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 101);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 201);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 300);
CALL join_meeting(0, 0, CURRENT_DATE + 7, '19:00:00', 301);


CALL join_meeting(1, 0, CURRENT_DATE, '19:00:00', 102);
CALL join_meeting(1, 0, CURRENT_DATE, '19:00:00', 103);
CALL join_meeting(1, 0, CURRENT_DATE, '19:00:00', 203);
CALL join_meeting(1, 0, CURRENT_DATE, '19:00:00', 302);
CALL join_meeting(1, 0, CURRENT_DATE, '19:00:00', 303);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '19:00:00', 102);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '19:00:00', 103);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '19:00:00', 203);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '19:00:00', 302);
CALL join_meeting(1, 0, CURRENT_DATE + 7, '19:00:00', 303);

CALL join_meeting(2, 0, CURRENT_DATE, '19:00:00', 104);
CALL join_meeting(2, 0, CURRENT_DATE, '19:00:00', 105);
CALL join_meeting(2, 0, CURRENT_DATE, '19:00:00', 205);
CALL join_meeting(2, 0, CURRENT_DATE, '19:00:00', 304);
CALL join_meeting(2, 0, CURRENT_DATE, '19:00:00', 305);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '19:00:00', 104);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '19:00:00', 105);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '19:00:00', 205);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '19:00:00', 304);
CALL join_meeting(2, 0, CURRENT_DATE + 7, '19:00:00', 305);
*/

-- Contact tracing test cases
insert into sessions VALUES
('12:00:00', current_date, 0, 1, 200, 302),
('12:00:00', current_date + 7, 0, 1, 201, NULL),
('12:00:00', current_date + 8, 0, 1, 201, 302),
('12:00:00', current_date + 9, 0, 1, 201, NULL);

insert into joins VALUES
(100, 0, 1, '12:00:00', current_date),
(101, 0, 1, '12:00:00', current_date),
(200, 0, 1, '12:00:00', current_date),

(100, 0, 1, '12:00:00', current_date + 7),
(100, 0, 1, '12:00:00', current_date + 8),
(100, 0, 1, '12:00:00', current_date + 9),

(101, 0, 1, '12:00:00', current_date + 7),
(101, 0, 1, '12:00:00', current_date + 8),
(101, 0, 1, '12:00:00', current_date + 9),

(201, 0, 1, '12:00:00', current_date + 7),
(201, 0, 1, '12:00:00', current_date + 8),
(201, 0, 1, '12:00:00', current_date + 9);

insert into sessions values
-- past meeting of fever employee 200
('15:00:00', current_date - 1, 0, 1, 200, 300),

('15:00:00', current_date - 3, 0, 1, 201, 301),

-- different booker than 201, otherwise the meetings will be deleted because
-- 201 is a close contact of 200
('15:00:00', current_date + 6, 0, 1, 202, NULL),
('15:00:00', current_date + 7, 0, 1, 202, 302),
('15:00:00', current_date + 8, 0, 1, 202, NULL);

insert into joins values
-- past meeting of fever employee 200
(200, 0, 1, '15:00:00', current_date - 1),

-- same approved meeting room 3 days ago as fever employee 200
(201, 0, 1, '15:00:00', current_date - 3),
(101, 0, 1, '15:00:00', current_date - 3),

(101, 0, 1, '15:00:00', current_date + 6),
(101, 0, 1, '15:00:00', current_date + 7),
(101, 0, 1, '15:00:00', current_date + 8),

(202, 0, 1, '15:00:00', current_date + 6),
(202, 0, 1, '15:00:00', current_date + 7),
(202, 0, 1, '15:00:00', current_date + 8);
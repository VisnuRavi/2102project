--testing for joins trigger

INSERT INTO Departments VALUES
(900,'dept900'),
(901,'dept901'),
(902,'dept902'),
(903,'dept903'),
(904,'dept904');

INSERT INTO Employees VALUES
(100, 'name_j_100', 'name_j_100@mail.com', 900, NULL),
(101, 'name_j_101', 'name_j_101@mail.com', 900, NULL),
(200, 'name_s_200', 'name_s_200@mail.com', 900, NULL),
(201, 'name_s_201', 'name_s_201@mail.com', 900, NULL),
(300, 'name_m_300', 'name_m_300@mail.com', 900, NULL),
(301, 'name_m_301', 'name_m_301@mail.com', 900, CURRENT_DATE),

(102, 'name_j_102', 'name_j_102@mail.com', 901, NULL),
(103, 'name_j_103', 'name_j_103@mail.com', 901, NULL),
(202, 'name_s_202', 'name_s_202@mail.com', 901, NULL),
(203, 'name_s_203', 'name_s_203@mail.com', 901, NULL),
(302, 'name_m_302', 'name_m_302@mail.com', 901, NULL),
(303, 'name_m_303', 'name_m_303@mail.com', 901, CURRENT_DATE),

(104, 'name_j_104', 'name_j_104@mail.com', 902, NULL),
(105, 'name_j_105', 'name_j_105@mail.com', 902, NULL),
(204, 'name_s_204', 'name_s_204@mail.com', 902, NULL),
(205, 'name_s_205', 'name_s_205@mail.com', 902, NULL),
(304, 'name_m_304', 'name_m_304@mail.com', 902, NULL),
(305, 'name_m_305', 'name_m_305@mail.com', 902, CURRENT_DATE),

(106, 'name_j_106', 'name_j_106@mail.com', 903, NULL),
(107, 'name_j_107', 'name_j_107@mail.com', 903, NULL),
(206, 'name_s_206', 'name_s_206@mail.com', 903, NULL),
(207, 'name_s_207', 'name_s_207@mail.com', 903, NULL),
(306, 'name_m_306', 'name_m_306@mail.com', 903, NULL),
(307, 'name_m_307', 'name_m_307@mail.com', 903, CURRENT_DATE),

(108, 'name_j_108', 'name_j_108@mail.com', 904, NULL),
(109, 'name_j_109', 'name_j_109@mail.com', 904, NULL),
(208, 'name_s_208', 'name_s_208@mail.com', 904, NULL),
(209, 'name_s_209', 'name_s_209@mail.com', 904, NULL),
(308, 'name_m_308', 'name_m_308@mail.com', 904, NULL),
(309, 'name_m_309', 'name_m_309@mail.com', 904, CURRENT_DATE);

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

INSERT INTO Updates Values
(CURRENT_DATE, 0, 0, 2),
(CURRENT_DATE, 1, 0, 2),
(CURRENT_DATE, 0, 1, 2),
(CURRENT_DATE, 1, 1, 2),
(CURRENT_DATE, 0, 2, 2),
(CURRENT_DATE, 1, 2, 2),
(CURRENT_DATE, 0, 3, 2),
(CURRENT_DATE, 1, 3, 2),
(CURRENT_DATE, 0, 4, 2),
(CURRENT_DATE, 1, 4, 2),

(CURRENT_DATE + 3, 1, 4, 3),
(CURRENT_DATE + 6, 1, 4, 4);


INSERT INTO Sessions VALUES
('20:00:00', CURRENT_DATE, 0, 0, 200,NULL), --non approve
('20:00:00', CURRENT_DATE, 1, 0, 201,NULL),  --approve
('20:00:00', CURRENT_DATE, 1, 1, 202,NULL),  --concurrent session

('20:00:00', CURRENT_DATE, 1, 4, 208,NULL), --session on initialisation_change_date (2pax)
('20:00:00', CURRENT_DATE + 2, 1, 4, 208,NULL), --session right before 1st_change_date (2pax)
('20:00:00', CURRENT_DATE + 3, 1, 4, 208,NULL), --session ON 1st_change_date (2pax)
('20:00:00', CURRENT_DATE + 4, 1, 4, 208,NULL), --session AFTER 1st_change_date (3pax)
('20:00:00', CURRENT_DATE + 6, 1, 4, 208,NULL), --session ON 2nd_change_date (3pax)
('20:00:00', CURRENT_DATE + 7, 1, 4, 208,NULL); --session AFTER 2nd_change_date (4pax)

--admit booker
INSERT INTO Joins VALUES
(200, 0, 0, '20:00:00', CURRENT_DATE),
(201, 1, 0, '20:00:00', CURRENT_DATE),
(202, 1, 1, '20:00:00', CURRENT_DATE),

(208, 1, 4, '20:00:00', CURRENT_DATE),
(208, 1, 4, '20:00:00', CURRENT_DATE + 2),
(208, 1, 4, '20:00:00', CURRENT_DATE + 3),
(208, 1, 4, '20:00:00', CURRENT_DATE + 4),
(208, 1, 4, '20:00:00', CURRENT_DATE + 6),
(208, 1, 4, '20:00:00', CURRENT_DATE + 7);



--approve the approved case
CALL approve_meeting(0,1, CURRENT_DATE, '20:00:00', 300);


--testing start (ALL SHOULD THROW NOTICE)
INSERT INTO Joins VALUES
--invalid meeting session (valid employee, invalid meeting)
(101,10,0,'20:00:00', CURRENT_DATE),
--past time and date (valid employee, invalid meeting)
(101,0,0,'20:00:00', CURRENT_DATE - 1),
(101,0,0, CURRENT_TIME - INTERVAL '1 hour', CURRENT_DATE),
--approved meeting (valid employee, invalid meeting)
(101,1,0,'20:00:00', CURRENT_DATE),
--fever employee(invalid employee, valid meeting)
(100,0,0, '20:00:00', CURRENT_DATE),
--past admission(invalid employee (booker), valid meeting)
(200,0,0, '20:00:00', CURRENT_DATE),
--resignation (invalid employee, valid meeting)
(301,0,0, '20:00:00', CURRENT_DATE),
--concurrent meeting (invalid employee (booker of another meeting), valid session)
(202,0,0, '20:00:00', CURRENT_DATE);


--testing for capacity allowance

--test 1 (1 more pax)
INSERT INTO Joins VALUES
(101, 1, 4, '20:00:00', CURRENT_DATE),
(103, 1, 4, '20:00:00', CURRENT_DATE); --throw notice

--test 2 (1 more pax)
INSERT INTO Joins VALUES
(101, 1, 4, '20:00:00', CURRENT_DATE + 2),
(103, 1, 4, '20:00:00', CURRENT_DATE + 2); --throw notice

--test 3 (1 more pax)
INSERT INTO Joins VALUES
(101, 1, 4, '20:00:00', CURRENT_DATE + 3),
(103, 1, 4, '20:00:00', CURRENT_DATE + 3); --throw notice

--test 4 (2 more pax)
INSERT INTO Joins VALUES
(101, 1, 4, '20:00:00', CURRENT_DATE + 4),
(103, 1, 4, '20:00:00', CURRENT_DATE + 4),
(105, 1, 4, '20:00:00', CURRENT_DATE + 4); --throw notice

--test 5 (2 more pax)
INSERT INTO Joins VALUES
(101, 1, 4, '20:00:00', CURRENT_DATE + 6),
(103, 1, 4, '20:00:00', CURRENT_DATE + 6),
(105, 1, 4, '20:00:00', CURRENT_DATE + 6); --throw notice

--test 6 (3 more pax)
INSERT INTO Joins VALUES
(101, 1, 4, '20:00:00', CURRENT_DATE + 7),
(103, 1, 4, '20:00:00', CURRENT_DATE + 7),
(105, 1, 4, '20:00:00', CURRENT_DATE + 7),
(107, 1, 4, '20:00:00', CURRENT_DATE + 7); --throw notice












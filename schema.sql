DROP TABLE IF EXISTS Employees, Contact_Numbers, Junior, Booker, Senior, Manager, Departments, Meeting_Rooms, 
    Health_Declaration, Updates, Sessions, Joins CASCADE;

SET timezone = 'America/Los_Angeles';

CREATE TABLE Departments (
    did INTEGER,
    dname TEXT,

    PRIMARY KEY (did)
); 

CREATE TABLE Employees (
    eid INTEGER,
    ename TEXT,
    email TEXT,
    did INTEGER,
    resigned_date DATE,

    PRIMARY KEY (eid),
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




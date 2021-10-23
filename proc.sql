CREATE OR REPLACE FUNCTION add_department(did INTEGER, dname TEXT) RETURNS VOID AS $$
    BEGIN
        INSERT INTO Departments(did, dname) VALUES (did, dname);
    END;
$$ LANGUAGE plpgsql;
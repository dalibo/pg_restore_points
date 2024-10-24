-- File restore_points--1.0.sql

-- Creation of the table to track restore points
CREATE TABLE rspt.restore_points (
    id serial PRIMARY KEY,
    name text UNIQUE NOT NULL,
    point_time timestamp with time zone DEFAULT now(),
    lsn pg_lsn NOT NULL,
    walfile text NOT NULL
);

-- Creation of the PL/pgSQL function to manage restore points
CREATE OR REPLACE FUNCTION rspt.pg_create_restore_point(name text) RETURNS bool AS $body$
DECLARE
    lsn pg_lsn;
    walfile_name text;
BEGIN
    -- Create a restore point
    lsn := pg_catalog.pg_create_restore_point(name);

    -- Get the associated WAL file
    walfile_name := pg_walfile_name(lsn);

    -- Insert restore point information into the table
    INSERT INTO rspt.restore_points (name, lsn, walfile)
    VALUES (name, lsn, walfile_name);

    RETURN true;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in pg_create_restore_point: %', SQLERRM;
        RETURN false;
END;
$body$ LANGUAGE plpgsql;

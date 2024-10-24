-- Creation of the table to track restore points
CREATE TABLE rspt.restore_points (
    id serial PRIMARY KEY,
    restore_point_name text NOT NULL,
    point_time timestamp with time zone DEFAULT now(),
    lsn pg_lsn NOT NULL,
    walfile text NOT NULL
);

-- Creation of the PL/pgSQL function to manage restore points
CREATE OR REPLACE FUNCTION rspt.pg_create_restore_point(p_restore_point_name text) RETURNS bool AS $body$
DECLARE
    lsn pg_lsn;
    walfile_name text;
    existing_count int;
BEGIN
    -- The parameter must not be empty or contain only spaces
    IF p_restore_point_name IS NULL OR LENGTH(TRIM(p_restore_point_name)) = 0 THEN
        RAISE EXCEPTION 'The restore point name cannot be empty or contain only spaces';
    END IF;

    -- Create a restore point
    lsn := pg_catalog.pg_create_restore_point(p_restore_point_name);

    -- Get the associated WAL file
    walfile_name := pg_catalog.pg_walfile_name(lsn);

    -- Insert the restore point information into the table
    INSERT INTO rspt.restore_points (restore_point_name, lsn, walfile)
    VALUES (p_restore_point_name, lsn, walfile_name);

    RETURN true;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in pg_create_restore_point: %', SQLERRM;
        RETURN false;
END;
$body$ LANGUAGE plpgsql;

-- Creation of the PL/pgSQL function to purge restore points
CREATE OR REPLACE FUNCTION rspt.pg_purge_restore_points(interval_param INTERVAL) RETURNS VOID AS $$
BEGIN
    -- Delete restore points that are older than the specified interval
    DELETE FROM rspt.restore_points
    WHERE point_time < NOW() - interval_param;

    -- Return a confirmation message (optional)
    RAISE NOTICE 'Restore points older than % have been deleted.', interval_param;
END;
$$ LANGUAGE plpgsql;

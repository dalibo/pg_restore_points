-- Creation of the table to track restore points
CREATE TABLE rspt.restore_points (
    id serial PRIMARY KEY,
    restore_point_name text NOT NULL,
    point_time timestamp with time zone DEFAULT now(),
    lsn pg_lsn NOT NULL,
    walfile text NOT NULL
);

-- Creation of the enumerated type
CREATE TYPE rspt.restore_point_mode
AS
ENUM
(
    'NOSTRICT',
    'STRICT',
    'USTRICT'
);

-- Creation of the PL/pgSQL function to manage restore points
CREATE OR REPLACE FUNCTION rspt.pg_create_restore_point(p_restore_point_name text, p_mode rspt.restore_point_mode DEFAULT 'NOSTRICT') RETURNS bool AS $body$
DECLARE
    lsn pg_lsn;
    walfile_name text;
    existing_count int;
BEGIN
    -- The parameter must not be empty or contain only spaces
    IF LENGTH(TRIM(p_restore_point_name)) = 0 THEN
        RAISE EXCEPTION 'The restore point name cannot be empty or contain only spaces';
    END IF;

    -- Logic based on the mode
    IF p_mode = 'STRICT' THEN
        -- Check if the restore_point_name and walfile pair already exists
        walfile_name := pg_catalog.pg_walfile_name(pg_catalog.pg_current_wal_lsn());
        SELECT COUNT(1) INTO existing_count
        FROM rspt.restore_points
        WHERE restore_point_name = p_restore_point_name AND walfile = walfile_name;

        -- If they exist RAISE an exception
        IF existing_count > 0 THEN
            RAISE EXCEPTION 'A restore point with the name % and the same WAL file already exists', p_restore_point_name;
        END IF;

    ELSIF p_mode = 'USTRICT' THEN
        -- Check if only the restore_point_name already exists
        SELECT COUNT(1) INTO existing_count
        FROM rspt.restore_points
        WHERE restore_point_name = p_restore_point_name;
        
        -- If it exists RAISE an exception
        IF existing_count > 0 THEN
            RAISE EXCEPTION 'A restore point with the name % already exists', p_restore_point_name;
        END IF;
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

-- Function to purge restore points older than a specified interval
CREATE OR REPLACE FUNCTION rspt.pg_purge_restore_points(interval_param INTERVAL) RETURNS TABLE 
( point_name text , 
  with_point_time timestamp with time zone, 
  in_walfile text )
 AS $$
BEGIN
    -- Delete restore points older than the specified interva
    RETURN QUERY DELETE FROM rspt.restore_points
    WHERE point_time < NOW() - interval_param 
    RETURNING restore_point_name,point_time,walfile ; 

END;
$$ LANGUAGE plpgsql;
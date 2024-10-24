-- Load the extension
CREATE EXTENSION IF NOT EXISTS pg_restore_points;

-- Test: Create a restore point with NOSTRICT mode
SELECT rspt.pg_create_restore_point('test_point_nostrict') = true;

-- Test: Create a restore point with NOSTRICT mode
SELECT rspt.pg_create_restore_point('test_point_nostrict') = true;

-- Test: Check the addition in the table
SELECT COUNT(1) = 2 FROM rspt.restore_points WHERE restore_point_name = 'test_point_nostrict';

-- Test: Create a restore point with STRICT mode
SELECT rspt.pg_create_restore_point('test_point_strict', 'STRICT') = true;

-- Test: Create a second restore point with STRICT mode and the same WAL
SELECT rspt.pg_create_restore_point('test_point_strict', 'STRICT') = false;

-- Test: Check the addition in the table
SELECT COUNT(1) = 1 FROM rspt.restore_points WHERE restore_point_name = 'test_point_strict';

-- Test: Create a restore point with STRICT mode
SELECT rspt.pg_create_restore_point('test_point_ustrict', 'USTRICT') = true;

-- Test: Create a second restore point with STRICT mode and the same WAL
SELECT rspt.pg_create_restore_point('test_point_ustrict', 'USTRICT') = false;

-- Test: Check the addition in the table
SELECT COUNT(1) = 1 FROM rspt.restore_points WHERE restore_point_name = 'test_point_strict';

-- Test: Wait for 5 seconds
SELECT pg_sleep(5);

-- Test: Purge restore points older than one day
SELECT COUNT(1) = 4 FROM rspt.pg_purge_restore_points('1 second');

-- Test: Check the content after the purge
SELECT * FROM rspt.restore_points;

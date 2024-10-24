Voici la traduction en anglais :

# restore_points

## Description

`restore_points` is a PostgreSQL extension that allows managing restore points in a PostgreSQL instance. It creates a schema, table, sequence, and function to facilitate the management and tracking of restore points.

### Features

- **Restore Point Management**: Creates and logs restore points in a dedicated table.
- **PL/pgSQL Function**: The `rspt.pg_create_restore_point` function creates a restore point using `pg_create_restore_point()` and logs the information in the `rspt.restore_points` table. It supports different validation modes.
- **Creation Modes**:
  - `NOSTRICT`: Creates the restore point without any prior validation.
  - `STRICT`: Ensures that the combination of `restore_point_name` and `walfile` does not already exist.
  - `USTRICT`: Ensures only that the restore point name does not already exist.
- **WAL File Tracking**: Associates each restore point with the corresponding WAL file using `pg_walfile_name()`.

### Installation

1. Compile and install the extension with `make`:

   ```bash
   make install
   ```

2. In PostgreSQL, create the extension:

   ```sql
   CREATE EXTENSION restore_points;
   ```

### Usage

```sql
-- Create a restore point (by default with NOSTRICT mode)
SELECT rspt.pg_create_restore_point('backup_2024_10_22');

-- Create a restore point with STRICT mode
SELECT rspt.pg_create_restore_point('backup_2024_10_22', 'STRICT');

-- View existing restore points
SELECT * FROM rspt.restore_points;
```

### `restore_points` Table Structure

- **id**: Unique identifier of the restore point.
- **restore_point_name**: Name of the restore point.
- **point_time**: Date and time of the restore point creation.
- **lsn**: Log Sequence Number associated with the restore point.
- **walfile**: WAL file corresponding to the LSN.

### Restore Point Purging Function

The `restore_points` extension also provides a function to purge restore points older than a specified time interval.

#### Function `rspt.pg_purge_restore_points`

The `purge_restore_points(interval_param INTERVAL)` function allows deleting restore points based on a specified interval. This is useful for managing old restore points and avoiding the accumulation of unnecessary data.

#### Syntax

```sql
SELECT rspt.pg_purge_restore_points('interval_value');
```

- **interval_value**: The time interval (e.g., `'1 month'`, `'2 days'`, `'6 hours'`, etc.) for which restore points older than this value will be deleted.

#### Usage

```sql
-- Deletes all restore points older than one month
SELECT rspt.pg_purge_restore_points('1 month');
```

#### Technical Details:
- The function uses the `point_time` column of the `rspt.restore_points` table to determine which records to delete.
- A `NOTICE` message is returned indicating that the purge was successful.

### Authors

Extension developed by Dalibo, 2024.

Here is the "Contributors" section translated to English:

**Contributors**

- [Robin Portigliatti](https://www.linkedin.com/in/robin-portigliatti-464838a7/) ;
- [Guillaume Armede](https://www.linkedin.com/in/guillaume-armede-811304147/) ;
- [Franck Boudehen](https://www.linkedin.com/in/franck-boudehen-35754b65) ;
- [Guillaume Lelarge](https://github.com/gleu).


### Instructions

1. Download this repository.
2. Then run `make install`:

   ```bash
   make install
   ```

3. Then run `make installcheck`:

   ```bash
   make installcheck
   ```
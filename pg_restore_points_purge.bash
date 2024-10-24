#!/bin/bash

# Directory containing WAL files
WAL_DIR="/tmp/pg_wal"

# Connection to PostgreSQL
PGDATABASE="postgres"
PGUSER="postgres"

# Temporary file to store the restore points found in WAL files
TEMP_FILE=$(mktemp)

# Function to extract information from pg_waldump
process_wal_file() {
    local walfile=$1
    # Use pg_waldump and grep to extract RESTORE POINT
    pg_waldump "$walfile" 2>/dev/null | grep "RESTORE_POINT" | while read -r line; do
        # Extract the restore point name and LSN
        restore_point_name=$(echo "$line" | grep -oP 'RESTORE_POINT \K\S+')
        walfile_basename=$(basename "$walfile")
        # Check if values are not empty before adding them to the temp file
        if [[ -n "$restore_point_name" && -n "$walfile_basename" ]]; then
            # Store the results in the requested format in the temp file
            echo "$restore_point_name;$walfile_basename" >> "$TEMP_FILE"
        fi
    done
}

# List the files in the WAL directory and process each file
for walfile in "$WAL_DIR"/*; do
    if [[ -f "$walfile" ]]; then
        process_wal_file "$walfile"
    fi
done

# Build the SQL query to delete restore points not found in the WAL files
if [[ -s "$TEMP_FILE" ]]; then
    sql_values=$(awk -F';' '{printf "(\047%s\047,\047%s\047),", $1, $2}' "$TEMP_FILE" | sed 's/,$//')

    # Execute the SQL delete query
    psql -d "$PGDATABASE" -U "$PGUSER" -c "
        DELETE FROM rspt.restore_points
        WHERE (restore_point_name, walfile) NOT IN (
            SELECT * FROM (VALUES $sql_values) AS t(restore_point_name, walfile)
        );
    "
else
    echo "No restore points found in WAL files."
fi

# Delete the temporary file
rm "$TEMP_FILE"

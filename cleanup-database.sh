#!/bin/bash

# Clean up the database and start fresh
echo "Cleaning up database for a fresh start..."

# Connect to the PostgreSQL container
echo "Connecting to PostgreSQL..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Drop views and tables in the cbs schema
DROP SCHEMA IF EXISTS cbs CASCADE;

-- Drop views and tables in the netherlands schema
DROP SCHEMA IF EXISTS netherlands CASCADE;

-- Create a clean cbs schema
CREATE SCHEMA cbs;

-- Show schemas to confirm cleanup
SELECT schema_name FROM information_schema.schemata 
WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'public', 'topology', 'tiger', 'tiger_data');
"

echo "Database cleaned up successfully!"
echo "You can now run ./import-cbs-data.sh to import the data with visualization support."
#!/bin/bash

# Import full vk500-2023 dataset into PostgreSQL with password handling
echo "Preparing to import full vk500-2023 dataset..."

# Create a custom docker container with GDAL and PostgreSQL client
echo "Creating importer container..."
docker run -d --name gis-importer \
  --network dekart-viz_default \
  -v /Users/giovi/Documents/Projects/dekart-viz/data:/data \
  -v /Users/giovi/Documents/Projects/dekart-viz/QGIS_export:/qgis_export \
  ghcr.io/osgeo/gdal:ubuntu-full-3.7.0 \
  sleep infinity

# Wait for container to start
sleep 2

# Install PostgreSQL client in the container
echo "Installing PostgreSQL client..."
docker exec gis-importer apt-get update -q
docker exec gis-importer apt-get install -y postgresql-client -q

# Get PostGIS container IP
DB_IP=$(docker inspect dekart-viz-db-1 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "PostgreSQL container IP: $DB_IP"

# Create a .pgpass file for password-less authentication
echo "Setting up PostgreSQL authentication..."
docker exec gis-importer bash -c "echo '$DB_IP:5432:dekart:dekart_user:your_password' > ~/.pgpass && chmod 600 ~/.pgpass"

# Create schema for Netherlands data
echo "Creating schema..."
docker exec gis-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c 'CREATE SCHEMA IF NOT EXISTS netherlands;'"

# Check if table already exists and drop if it does
echo "Checking for existing table..."
docker exec gis-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c 'DROP TABLE IF EXISTS netherlands.vk500;'"

# Use ogr2ogr to import the GeoPackage
echo "Importing vk500-2023.gpkg (this will take several minutes)..."
docker exec gis-importer bash -c "ogr2ogr -f PostgreSQL PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' /qgis_export/vk500-2023.gpkg -lco SCHEMA=netherlands -lco GEOMETRY_NAME=geom -lco FID=id -lco PRECISION=NO -nln vk500 -s_srs EPSG:28992 -t_srs EPSG:4326"

# Create indexes for better performance
echo "Creating indexes..."
docker exec gis-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
  -- Create spatial index
  CREATE INDEX IF NOT EXISTS vk500_geom_idx ON netherlands.vk500 USING GIST (geom);
  
  -- Create indexes on commonly used columns
  CREATE INDEX IF NOT EXISTS vk500_inwoners_idx ON netherlands.vk500 (aantal_inwoners);
  CREATE INDEX IF NOT EXISTS vk500_woningen_idx ON netherlands.vk500 (aantal_woningen);
  CREATE INDEX IF NOT EXISTS vk500_inkomen_idx ON netherlands.vk500 (gemiddeld_inkomen_huishouden);
  
  -- Output count of imported features
  SELECT COUNT(*) FROM netherlands.vk500;
'"

# Clean up
echo "Cleaning up..."
docker rm -f gis-importer

echo "Import completed! Full data is now available in the PostgreSQL database."
echo "You can now create queries in Dekart using: SELECT * FROM netherlands.vk500 LIMIT 1000;"
echo ""
echo "Visualization tips:"
echo "1. Use geom field for polygon shapes"
echo "2. Use aantal_inwoners for population density (color/height)"
echo "3. Use gemiddeld_inkomen_huishouden for income distribution"
echo "4. Use stedelijkheid for urbanization levels"
echo ""
echo "NOTE: For large datasets, always use LIMIT to avoid overloading the visualization."
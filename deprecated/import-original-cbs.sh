#!/bin/bash

# Import the original CBS VK500 dataset from the provider
echo "Preparing to import the original CBS VK500 dataset..."

# Create a custom docker container with GDAL and PostgreSQL client
echo "Creating importer container..."
docker run -d --name cbs-importer \
  --network dekart-viz_default \
  -v /Users/giovi/Documents/Projects/dekart-viz/QGIS_export:/data \
  ghcr.io/osgeo/gdal:ubuntu-full-3.7.0 \
  sleep infinity

# Wait for container to start
sleep 2

# Install PostgreSQL client in the container
echo "Installing PostgreSQL client..."
docker exec cbs-importer apt-get update -q
docker exec cbs-importer apt-get install -y postgresql-client -q

# Get PostGIS container IP
DB_IP=$(docker inspect dekart-viz-db-1 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "PostgreSQL container IP: $DB_IP"

# Create a .pgpass file for password-less authentication
echo "Setting up PostgreSQL authentication..."
docker exec cbs-importer bash -c "echo '$DB_IP:5432:dekart:dekart_user:your_password' > ~/.pgpass && chmod 600 ~/.pgpass"

# Create schema for CBS data
echo "Creating schema..."
docker exec cbs-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c 'CREATE SCHEMA IF NOT EXISTS cbs;'"

# Check if table already exists and drop if it does
echo "Checking for existing table..."
docker exec cbs-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c 'DROP TABLE IF EXISTS cbs.vk500;'"

# Use ogr2ogr to import the GeoPackage with explicit coordinate transformation
echo "Importing cbs_vk500_2023_v1.gpkg (this will take several minutes)..."
docker exec cbs-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/cbs_vk500_2023_v1.gpkg \
  -lco SCHEMA=cbs \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -lco PRECISION=NO \
  -nln vk500 \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

# Create indexes for better performance
echo "Creating indexes..."
docker exec cbs-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
  -- Create spatial index
  CREATE INDEX IF NOT EXISTS cbs_vk500_geom_idx ON cbs.vk500 USING GIST (geom);
  
  -- Create indexes on commonly used columns
  CREATE INDEX IF NOT EXISTS cbs_vk500_inwoners_idx ON cbs.vk500 (aantal_inwoners);
  CREATE INDEX IF NOT EXISTS cbs_vk500_woningen_idx ON cbs.vk500 (aantal_woningen);
  CREATE INDEX IF NOT EXISTS cbs_vk500_inkomen_idx ON cbs.vk500 (gemiddeld_inkomen_huishouden);
  
  -- Output count of imported features
  SELECT COUNT(*) FROM cbs.vk500;
'"

# Clean up
echo "Cleaning up..."
docker rm -f cbs-importer

echo "Import completed! Full data is now available in the PostgreSQL database."
echo "You can now create queries in Dekart using: SELECT * FROM cbs.vk500 LIMIT 1000;"
echo ""
echo "Visualization tips:"
echo "1. Try this query for visualization:"
echo "   SELECT id, geom, aantal_inwoners, stedelijkheid FROM cbs.vk500 WHERE aantal_inwoners > 0 LIMIT 500;"
echo ""
echo "IMPORTANT: For large datasets, always use LIMIT to avoid overloading the visualization."
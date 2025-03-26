#!/bin/bash

# This script imports the vk500-2023.gpkg GeoPackage into PostgreSQL
echo "Importing vk500-2023 GeoPackage into PostgreSQL..."

# Create network for import
echo "Creating network for import..."
docker network create import-network

# Connect PostgreSQL container to the network
echo "Connecting PostgreSQL container to network..."
docker network connect import-network dekart-viz-db-1

# Get IP address of PostgreSQL container in the import-network
DB_IP=$(docker inspect dekart-viz-db-1 --format '{{.NetworkSettings.Networks.import_network.IPAddress}}')
echo "PostgreSQL IP: $DB_IP"

# Import the GeoPackage using GDAL
echo "Importing GeoPackage with GDAL (this may take a few minutes)..."
docker run --rm --network import-network -v /Users/giovi/Documents/Projects/dekart-viz/data:/data ghcr.io/osgeo/gdal:ubuntu-full-3.7.0 \
    ogr2ogr -f "PostgreSQL" \
    PG:"host=$DB_IP user=dekart_user password=your_password dbname=dekart" \
    /data/vk500-2023.gpkg \
    -lco GEOMETRY_NAME=geom \
    -lco FID=id \
    -lco PRECISION=NO \
    -nln netherlands.vk500 \
    -overwrite \
    -s_srs EPSG:28992 \
    -t_srs EPSG:4326

# Create indexes for better performance
echo "Creating indexes..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
    -- Create spatial index
    CREATE INDEX IF NOT EXISTS vk500_geom_idx ON netherlands.vk500 USING GIST (geom);
    
    -- Create indexes on commonly used columns
    CREATE INDEX IF NOT EXISTS vk500_inwoners_idx ON netherlands.vk500 (aantal_inwoners);
    CREATE INDEX IF NOT EXISTS vk500_woningen_idx ON netherlands.vk500 (aantal_woningen);
    CREATE INDEX IF NOT EXISTS vk500_inkomen_idx ON netherlands.vk500 (gemiddeld_inkomen_huishouden);
    
    -- Output count of imported features
    SELECT COUNT(*) FROM netherlands.vk500;
"

# Clean up network
echo "Cleaning up network..."
docker network disconnect import-network dekart-viz-db-1
docker network rm import-network

echo "Import completed! Data is now available in the PostgreSQL database."
echo "You can now create queries in Dekart using: SELECT * FROM netherlands.vk500 LIMIT 1000;"
echo "NOTE: For large datasets, always use LIMIT to avoid overloading the visualization."
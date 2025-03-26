#!/bin/bash

# Import the CBS VK500 dataset and create visualization-friendly views
echo "Importing CBS VK500 dataset with GeoJSON support..."

# Step 1: Create a custom docker container with GDAL and PostgreSQL client
echo "Creating importer container..."
docker run -d --name cbs-importer \
  --network dekart-viz_default \
  -v /Users/giovi/Documents/Projects/dekart-viz/QGIS_export:/data \
  ghcr.io/osgeo/gdal:ubuntu-full-3.7.0 \
  sleep infinity

# Wait for container to start
sleep 2

# Step 2: Install PostgreSQL client in the container
echo "Installing PostgreSQL client..."
docker exec cbs-importer apt-get update -q
docker exec cbs-importer apt-get install -y postgresql-client -q

# Step 3: Get PostGIS container IP
DB_IP=$(docker inspect dekart-viz-db-1 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "PostgreSQL container IP: $DB_IP"

# Step 4: Set up PostgreSQL authentication
echo "Setting up PostgreSQL authentication..."
docker exec cbs-importer bash -c "echo '$DB_IP:5432:dekart:dekart_user:your_password' > ~/.pgpass && chmod 600 ~/.pgpass"

# Step 5: Create schema for CBS data
echo "Creating schema..."
docker exec cbs-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c 'CREATE SCHEMA IF NOT EXISTS cbs;'"

# Step 6: Drop existing tables if they exist
echo "Checking for existing tables..."
docker exec cbs-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
  -- Drop views first because they depend on the table
  DROP VIEW IF EXISTS cbs.vk500_geojson CASCADE;
  DROP VIEW IF EXISTS cbs.vk500_points CASCADE;
  -- Then drop the table
  DROP TABLE IF EXISTS cbs.vk500 CASCADE;
'"

# Step 7: Import the GeoPackage with explicit coordinate transformation
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

# Step 8: Create views for better visualization
echo "Creating visualization-friendly views..."
docker exec cbs-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
  -- Create GeoJSON view for polygon visualization
  CREATE VIEW cbs.vk500_geojson AS
  SELECT 
    id,
    ST_AsGeoJSON(geom) AS geometry,
    aantal_inwoners AS population,
    stedelijkheid AS urbanization_level,
    gemiddeld_inkomen_huishouden AS avg_household_income,
    gemiddelde_woz_waarde_woning AS avg_housing_value,
    aantal_woningen AS housing_units,
    dichtstbijzijnde_treinstation_afstand_in_km AS train_station_distance
  FROM 
    cbs.vk500;
  
  -- Create point centroid view
  CREATE VIEW cbs.vk500_points AS
  SELECT 
    id,
    ST_X(ST_Centroid(geom)) AS longitude,
    ST_Y(ST_Centroid(geom)) AS latitude,
    aantal_inwoners AS population,
    stedelijkheid AS urbanization_level,
    gemiddeld_inkomen_huishouden AS avg_household_income,
    gemiddelde_woz_waarde_woning AS avg_housing_value,
    aantal_woningen AS housing_units,
    dichtstbijzijnde_treinstation_afstand_in_km AS train_station_distance
  FROM 
    cbs.vk500;
'"

# Step 9: Create indexes for better performance
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

# Step 10: Clean up
echo "Cleaning up..."
docker rm -f cbs-importer

echo "Import completed! Data and visualization views are now available."
echo ""
echo "You can use these queries for visualization:"
echo ""
echo "1. For polygon visualization (use 'geometry' field as GeoJSON):"
echo "   SELECT * FROM cbs.vk500_geojson WHERE population > 0 LIMIT 500;"
echo ""
echo "2. For point visualization (use 'longitude' and 'latitude' fields):"
echo "   SELECT * FROM cbs.vk500_points WHERE population > 0 LIMIT 500;"
echo ""
echo "For both views, you can use fields like population, urbanization_level, avg_household_income, etc. for styling."
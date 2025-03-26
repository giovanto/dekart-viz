#!/bin/bash

# Import all data for Dekart-Viz platform
# This script imports:
# 1. CBS VK500 (500m grid) data
# 2. CBS VK100 (100m grid) data
# 3. Base map layers from QGIS

echo "Starting data import for Dekart-Viz..."

# Create a custom docker container with GDAL
echo "Setting up importer container..."
docker run -d --name geodata-importer \
  --network dekart-viz_default \
  -v /Users/giovi/Documents/Projects/dekart-viz/QGIS_export:/data \
  ghcr.io/osgeo/gdal:ubuntu-full-3.7.0 \
  sleep infinity

# Wait for container to start
sleep 2

# Install PostgreSQL client
echo "Installing PostgreSQL client..."
docker exec geodata-importer apt-get update -q
docker exec geodata-importer apt-get install -y postgresql-client -q

# Get PostgreSQL container IP
DB_IP=$(docker inspect dekart-viz-db-1 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "PostgreSQL container IP: $DB_IP"

# Set up PostgreSQL authentication
echo "Setting up PostgreSQL authentication..."
docker exec geodata-importer bash -c "echo '$DB_IP:5432:dekart:dekart_user:your_password' > ~/.pgpass && chmod 600 ~/.pgpass"

# Clean existing schemas
echo "Cleaning existing schemas..."
docker exec geodata-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
DROP SCHEMA IF EXISTS basemap CASCADE;
DROP SCHEMA IF EXISTS cbs_complete CASCADE;
DROP SCHEMA IF EXISTS cbs_vk100 CASCADE;

CREATE SCHEMA IF NOT EXISTS basemap;
CREATE SCHEMA IF NOT EXISTS cbs_complete;
CREATE SCHEMA IF NOT EXISTS cbs_vk100;
'"

# =====================
# Import Base Map Layers
# =====================
echo "Importing base map layers from SB_Base_Layers.gpkg..."

echo "Importing country boundaries (Landsgrens)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg 0_Landsgrens \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln country \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing railways (Spoor2023)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg 0_Spoor2023 \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln railways \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing highways (autosnelweg)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg S_Top100NL_wegdeel_autosnelweg \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln highways \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing main roads (hoofdweg)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg S_Top100NL_wegdeel_hoofdweg \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln main_roads \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing built-up areas (bebouwdgebied)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg Top100NL_terrein_bebouwdgebied \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln built_up \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing forests (bos)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg Top100NL_terrein_bos_min25ha \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln forests \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing heathland (heide)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg Top100NL_terrein_heide_min25ha \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln heathland \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing sandy areas (zand)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg Top100NL_terrein_zand_min25ha \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln sand \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing water bodies (waterdeel)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg Top100NL_waterdeel_min25ha \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln water \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing industrial areas (bedrijventerreinen)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/SB_Base_Layers.gpkg T_IBIS_2022_Bedrijventerreinen \
  -lco SCHEMA=basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln industrial \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

# =====================
# Import CBS VK500 Data
# =====================
echo "Importing CBS VK500 data (500m grid)..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/cbs_vk500_2023_v1.gpkg \
  -lco SCHEMA=cbs_complete \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln vk500 \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

# =====================
# Import CBS VK100 Data
# =====================
echo "Importing CBS VK100 data (100m grid) - this will take several minutes..."
docker exec geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/cbs_vk100_2023_v1.gpkg \
  -lco SCHEMA=cbs_vk100 \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln vk100 \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

# Create view indexes for better performance
echo "Creating spatial indexes..."
docker exec geodata-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
-- Base map indexes
CREATE INDEX IF NOT EXISTS country_geom_idx ON basemap.country USING GIST (geom);
CREATE INDEX IF NOT EXISTS railways_geom_idx ON basemap.railways USING GIST (geom);
CREATE INDEX IF NOT EXISTS highways_geom_idx ON basemap.highways USING GIST (geom);
CREATE INDEX IF NOT EXISTS main_roads_geom_idx ON basemap.main_roads USING GIST (geom);
CREATE INDEX IF NOT EXISTS built_up_geom_idx ON basemap.built_up USING GIST (geom);
CREATE INDEX IF NOT EXISTS forests_geom_idx ON basemap.forests USING GIST (geom);
CREATE INDEX IF NOT EXISTS heathland_geom_idx ON basemap.heathland USING GIST (geom);
CREATE INDEX IF NOT EXISTS sand_geom_idx ON basemap.sand USING GIST (geom);
CREATE INDEX IF NOT EXISTS water_geom_idx ON basemap.water USING GIST (geom);
CREATE INDEX IF NOT EXISTS industrial_geom_idx ON basemap.industrial USING GIST (geom);

-- VK500 indexes
CREATE INDEX IF NOT EXISTS vk500_geom_idx ON cbs_complete.vk500 USING GIST (geom);
CREATE INDEX IF NOT EXISTS vk500_inwoners_idx ON cbs_complete.vk500 (aantal_inwoners);

-- VK100 indexes
CREATE INDEX IF NOT EXISTS vk100_geom_idx ON cbs_vk100.vk100 USING GIST (geom);
CREATE INDEX IF NOT EXISTS vk100_inwoners_idx ON cbs_vk100.vk100 (aantal_inwoners);
'"

# Verify data import
echo "Verifying data import..."
docker exec geodata-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c \"
SELECT 'Base map layers:' AS dataset;
SELECT table_name, COUNT(*) 
FROM (
  SELECT 'country' AS table_name FROM basemap.country UNION ALL
  SELECT 'railways' FROM basemap.railways UNION ALL
  SELECT 'highways' FROM basemap.highways UNION ALL
  SELECT 'main_roads' FROM basemap.main_roads UNION ALL
  SELECT 'built_up' FROM basemap.built_up UNION ALL
  SELECT 'forests' FROM basemap.forests UNION ALL
  SELECT 'heathland' FROM basemap.heathland UNION ALL
  SELECT 'sand' FROM basemap.sand UNION ALL
  SELECT 'water' FROM basemap.water UNION ALL
  SELECT 'industrial' FROM basemap.industrial
) AS x
GROUP BY table_name
ORDER BY table_name;

SELECT 'VK500 count: ' || COUNT(*) AS count FROM cbs_complete.vk500;
SELECT 'VK100 count: ' || COUNT(*) AS count FROM cbs_vk100.vk100;
\""

# Clean up
echo "Cleaning up..."
docker rm -f geodata-importer

echo "Data import completed successfully!"
echo "Now run './create-views.sh' to set up visualization views."
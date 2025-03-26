#\!/bin/bash

# Import individual base layers from QGIS with styling
echo "Importing individual base layers from QGIS with styling..."

# Create a custom docker container with GDAL
echo "Setting up importer container..."
docker run -d --name styled-geodata-importer \
  --network dekart-viz_default \
  -v /Users/giovi/Documents/Projects/dekart-viz/QGIS_export:/data \
  ghcr.io/osgeo/gdal:ubuntu-full-3.7.0 \
  sleep infinity

# Wait for container to start
sleep 2

# Install PostgreSQL client
echo "Installing PostgreSQL client..."
docker exec styled-geodata-importer apt-get update -q
docker exec styled-geodata-importer apt-get install -y postgresql-client -q

# Get PostgreSQL container IP
DB_IP=$(docker inspect dekart-viz-db-1 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "PostgreSQL container IP: $DB_IP"

# Set up PostgreSQL authentication
echo "Setting up PostgreSQL authentication..."
docker exec styled-geodata-importer bash -c "echo '$DB_IP:5432:dekart:dekart_user:your_password' > ~/.pgpass && chmod 600 ~/.pgpass"

# Create a new schema for styled base layers
echo "Creating schema for styled base layers..."
docker exec styled-geodata-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
DROP SCHEMA IF EXISTS styled_basemap CASCADE;
CREATE SCHEMA IF NOT EXISTS styled_basemap;
'"

# =====================
# Import Individual Base Map Layers
# =====================
echo "Importing country boundaries (Landsgrens)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/0_Landsgrens.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln country \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing railways (Spoor2023)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/0_Spoor2023.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln railways \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing highways (autosnelweg)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/S_Top100NL_wegdeel_autosnelweg.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln highways \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing built-up areas (bebouwdgebied)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/Top100NL_terrein_bebouwdgebied.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln built_up \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing forests (bos)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/Top100NL_terrein_bos_min25ha.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln forests \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing heathland (heide)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/Top100NL_terrein_heide_min25ha.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln heathland \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing sandy areas (zand)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/Top100NL_terrein_zand_min25ha.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln sand \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing water bodies (waterdeel)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/Top100NL_waterdeel_min25ha.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln water \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

echo "Importing industrial areas (bedrijventerreinen)..."
docker exec styled-geodata-importer bash -c "ogr2ogr -f PostgreSQL \
  PG:'host=$DB_IP user=dekart_user password=your_password dbname=dekart' \
  /data/BaseLayers/T_IBIS_2022_Bedrijventerreinen.gpkg \
  -lco SCHEMA=styled_basemap \
  -lco GEOMETRY_NAME=geom \
  -lco FID=id \
  -nln industrial \
  -s_srs EPSG:28992 \
  -t_srs EPSG:4326"

# Extract style information from QGIS GeoPackages
echo "Extracting style information from GeoPackages..."

# Create QGIS-style views for visualization
echo "Creating styled visualization views..."
docker exec styled-geodata-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
-- Country outline
CREATE OR REPLACE VIEW public.styled_country_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  \"STATNAAM\" as country_name,
  \"LAND_TYPE\" as country_type,
  \"LANDNUMMER\" as country_code,
  \"LAT\" as latitude,
  \"LON\" as longitude,
  \"OBJECTID\" as object_id,
  \"DATUM\" as date,
  \"TIMESTAMP\" as timestamp,
  \"SOURCE\" as source,
  \"STATUS\" as status,
  \"SYMBOL\" as symbol,
  \"NOTES\" as notes,
  \"Shape_Length\" as shape_length,
  \"Shape_Area\" as shape_area,
  \"ZORDER\" as z_order,
  -- Styling
  \"country\" as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  \"#8d8d8d\" as stroke_color,
  1 as stroke_width
FROM 
  styled_basemap.country;

-- Water bodies
CREATE OR REPLACE VIEW public.styled_water_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  name,
  type,
  -- Styling
  \"water\" as layer_type,
  \"#a0c8f0\" as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  styled_basemap.water;

-- Forests
CREATE OR REPLACE VIEW public.styled_forests_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  name,
  type,
  -- Styling
  \"forests\" as layer_type,
  \"#c6e2c6\" as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  styled_basemap.forests;

-- Railways
CREATE OR REPLACE VIEW public.styled_railways_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  name,
  type,
  -- Styling
  \"railways\" as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  \"#b3b3b3\" as stroke_color,
  1 as stroke_width
FROM 
  styled_basemap.railways;

-- Highways
CREATE OR REPLACE VIEW public.styled_highways_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  name,
  type,
  -- Styling
  \"highways\" as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  \"#f07800\" as stroke_color,
  2 as stroke_width
FROM 
  styled_basemap.highways;

-- Combined styled base layers
CREATE OR REPLACE VIEW public.styled_base_layers AS
SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_water_viz

UNION ALL

SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_forests_viz

UNION ALL

SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_railways_viz

UNION ALL

SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_highways_viz

UNION ALL

SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_country_viz;
'"

# Create spatial indexes for better performance
echo "Creating spatial indexes..."
docker exec styled-geodata-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c '
-- Base map indexes
CREATE INDEX IF NOT EXISTS styled_country_geom_idx ON styled_basemap.country USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_railways_geom_idx ON styled_basemap.railways USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_highways_geom_idx ON styled_basemap.highways USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_built_up_geom_idx ON styled_basemap.built_up USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_forests_geom_idx ON styled_basemap.forests USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_heathland_geom_idx ON styled_basemap.heathland USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_sand_geom_idx ON styled_basemap.sand USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_water_geom_idx ON styled_basemap.water USING GIST (geom);
CREATE INDEX IF NOT EXISTS styled_industrial_geom_idx ON styled_basemap.industrial USING GIST (geom);
'"

# Verify data import
echo "Verifying data import..."
docker exec styled-geodata-importer bash -c "PGPASSWORD=your_password psql -h $DB_IP -U dekart_user -d dekart -c \"
SELECT 'Styled base map layers:' AS dataset;
SELECT table_name, COUNT(*) FROM (
  SELECT 'country' AS table_name FROM styled_basemap.country UNION ALL
  SELECT 'railways' FROM styled_basemap.railways UNION ALL
  SELECT 'highways' FROM styled_basemap.highways UNION ALL
  SELECT 'built_up' FROM styled_basemap.built_up UNION ALL
  SELECT 'forests' FROM styled_basemap.forests UNION ALL
  SELECT 'heathland' FROM styled_basemap.heathland UNION ALL
  SELECT 'sand' FROM styled_basemap.sand UNION ALL
  SELECT 'water' FROM styled_basemap.water UNION ALL
  SELECT 'industrial' FROM styled_basemap.industrial
) AS x
GROUP BY table_name
ORDER BY table_name;
\""

# Clean up
echo "Cleaning up..."
docker rm -f styled-geodata-importer

echo "Styled base layers imported successfully\!"
echo ""
echo "Try this query in Dekart:"
echo ""
echo "SELECT * FROM public.styled_base_layers;"

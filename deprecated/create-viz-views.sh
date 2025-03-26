#!/bin/bash

# Create visualization-friendly views in PostgreSQL
echo "Creating visualization-friendly views..."

# Create GeoJSON view for polygon visualization
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Create or replace polygon GeoJSON view
DROP VIEW IF EXISTS cbs.vk500_geojson;
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
DROP VIEW IF EXISTS cbs.vk500_points;
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
"

echo "Views created successfully!"
echo ""
echo "You can now use these queries for visualization:"
echo ""
echo "1. For polygon visualization (use 'geometry' field as GeoJSON):"
echo "   SELECT * FROM cbs.vk500_geojson WHERE population > 0 LIMIT 500;"
echo ""
echo "2. For point visualization (use 'longitude' and 'latitude' fields):"
echo "   SELECT * FROM cbs.vk500_points WHERE population > 0 LIMIT 500;"
echo ""
echo "For both views, you can use fields like population, urbanization_level, avg_household_income, etc. for styling."
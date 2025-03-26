-- Convert polygons to GeoJSON format for better compatibility
SELECT 
  id,
  ST_AsGeoJSON(geom) AS geometry,
  aantal_inwoners AS population,
  stedelijkheid AS urbanization_level
FROM 
  cbs.vk500
WHERE 
  aantal_inwoners > 0
LIMIT 200;
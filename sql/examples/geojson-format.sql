-- Format as GeoJSON explicitly
SELECT 
  id,
  ST_AsGeoJSON(geom) AS geom,
  aantal_inwoners 
FROM 
  netherlands.vk500
LIMIT 100;
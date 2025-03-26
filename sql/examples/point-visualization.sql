-- Convert polygons to points for simpler visualization
SELECT 
  id,
  ST_X(ST_Centroid(geom)) AS longitude,
  ST_Y(ST_Centroid(geom)) AS latitude,
  aantal_inwoners AS population,
  stedelijkheid AS urbanization_level
FROM 
  cbs.vk500
WHERE 
  aantal_inwoners > 0
LIMIT 500;
-- Extract centroid coordinates for point-based visualization
SELECT 
  id,
  ST_X(ST_Centroid(geom)) AS longitude,
  ST_Y(ST_Centroid(geom)) AS latitude,
  geom,
  aantal_inwoners AS population,
  gemiddeld_inkomen_huishouden AS income
FROM 
  netherlands.vk500
WHERE
  aantal_inwoners > 0
LIMIT 200;
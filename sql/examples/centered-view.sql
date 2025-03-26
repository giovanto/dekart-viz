-- This query includes the center coordinates of the Netherlands
SELECT 
  id,
  geom,
  aantal_inwoners,
  -- Add center point of Netherlands for map centering
  5.2913 AS center_lon,
  52.1326 AS center_lat,
  7 AS zoom_level
FROM 
  netherlands.vk500
WHERE ST_Intersects(
  geom, 
  ST_MakeEnvelope(4.5, 51.8, 6.0, 52.5, 4326)  -- Amsterdam region
)
LIMIT 100;
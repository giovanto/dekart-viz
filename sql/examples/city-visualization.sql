-- Create simple city points visualization
SELECT 
  1 AS id,
  ST_SetSRID(ST_MakePoint(4.9, 52.37), 4326) AS geom,
  'Amsterdam' AS city,
  873000 AS population
UNION ALL
SELECT 
  2 AS id,
  ST_SetSRID(ST_MakePoint(4.47, 51.92), 4326) AS geom,
  'Rotterdam' AS city,
  651000 AS population
UNION ALL
SELECT 
  3 AS id,
  ST_SetSRID(ST_MakePoint(5.12, 52.09), 4326) AS geom,
  'Utrecht' AS city,
  361000 AS population
UNION ALL
SELECT 
  4 AS id,
  ST_SetSRID(ST_MakePoint(4.30, 52.08), 4326) AS geom,
  'The Hague' AS city,
  545000 AS population
UNION ALL
SELECT 
  5 AS id,
  ST_SetSRID(ST_MakePoint(5.47, 51.44), 4326) AS geom,
  'Eindhoven' AS city,
  234000 AS population;
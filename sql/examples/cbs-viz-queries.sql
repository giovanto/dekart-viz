-- Basic visualization query
-- Use this first to verify the data displays correctly
SELECT 
  id,
  geom,
  aantal_inwoners AS population
FROM 
  cbs.vk500
WHERE 
  aantal_inwoners > 0
LIMIT 200;

-- Population density visualization
-- Use this to see where people live in the Netherlands
-- SELECT 
--   id,
--   geom,
--   aantal_inwoners AS population,
--   ST_Area(geom::geography) / 1000000 AS area_sq_km,
--   (aantal_inwoners / (ST_Area(geom::geography) / 1000000)) AS population_density
-- FROM 
--   cbs.vk500
-- WHERE 
--   aantal_inwoners > 0
-- ORDER BY 
--   population DESC
-- LIMIT 500;

-- Urbanization visualization
-- Use this to see urban vs. rural areas
-- SELECT 
--   id,
--   geom,
--   stedelijkheid AS urbanization_level,
--   aantal_inwoners AS population
-- FROM 
--   cbs.vk500
-- WHERE 
--   stedelijkheid IS NOT NULL
--   AND aantal_inwoners > 0
-- ORDER BY 
--   stedelijkheid
-- LIMIT 500;

-- Income distribution visualization
-- Use this to see wealth distribution
-- SELECT 
--   id,
--   geom,
--   gemiddeld_inkomen_huishouden AS avg_household_income,
--   aantal_inwoners AS population
-- FROM 
--   cbs.vk500
-- WHERE 
--   gemiddeld_inkomen_huishouden > 0
--   AND aantal_inwoners > 0
-- ORDER BY 
--   gemiddeld_inkomen_huishouden DESC
-- LIMIT 500;

-- Housing value visualization
-- Use this to see housing prices distribution
-- SELECT 
--   id,
--   geom,
--   gemiddelde_woz_waarde_woning AS avg_home_value,
--   aantal_inwoners AS population
-- FROM 
--   cbs.vk500
-- WHERE 
--   gemiddelde_woz_waarde_woning > 0
--   AND aantal_inwoners > 0
-- ORDER BY 
--   gemiddelde_woz_waarde_woning DESC
-- LIMIT 500;
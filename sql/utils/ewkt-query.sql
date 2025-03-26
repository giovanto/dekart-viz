-- Query with EWKT format that includes SRID information
SELECT 
  id,
  ST_AsEWKT(geom) AS geometry,  -- Includes SRID information
  aantal_inwoners AS population,
  aantal_woningen AS housing_units,
  gemiddeld_inkomen_huishouden AS avg_income,
  stedelijkheid AS urbanization,
  gemiddelde_woz_waarde_woning AS housing_value
FROM 
  netherlands.vk500
WHERE 
  aantal_inwoners > 0
  AND stedelijkheid IS NOT NULL
ORDER BY population DESC
LIMIT 200;
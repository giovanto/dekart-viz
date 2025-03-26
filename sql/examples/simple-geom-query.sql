-- Simple query that should work with Kepler.gl
SELECT 
  id,
  geom,  -- Use the raw geometry column
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
LIMIT 1000;
-- Query for Kepler.gl visualization with GeoJSON formatting
SELECT 
  id,
  -- Format geometry as GeoJSON
  ST_AsGeoJSON(geom) AS geometry,
  -- Include key attributes
  aantal_inwoners AS population,
  aantal_woningen AS housing_units,
  gemiddeld_inkomen_huishouden AS avg_income,
  stedelijkheid AS urbanization,
  gemiddelde_woz_waarde_woning AS housing_value,
  dichtstbijzijnde_treinstation_afstand_in_km AS train_station_distance
FROM 
  netherlands.vk500
WHERE 
  aantal_inwoners > 0
LIMIT 2000;
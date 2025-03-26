-- Create larger polygons by aggregating nearby grid cells
SELECT 
  row_number() OVER () AS id,
  ST_Union(geom) AS geom,
  SUM(aantal_inwoners) AS population,
  AVG(gemiddeld_inkomen_huishouden) AS avg_income
FROM (
  SELECT 
    geom,
    aantal_inwoners,
    gemiddeld_inkomen_huishouden,
    -- Create grouping based on rounding coordinates (clustering)
    ROUND(ST_X(ST_Centroid(geom))::numeric, 1) AS x_group,
    ROUND(ST_Y(ST_Centroid(geom))::numeric, 1) AS y_group
  FROM 
    netherlands.vk500
  WHERE
    aantal_inwoners > 0
  LIMIT 1000
) sub
GROUP BY 
  x_group, y_group
LIMIT 50;
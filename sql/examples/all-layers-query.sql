-- Example queries for all available layers in Dekart-Viz

-- 1. Base map layers (original)
-- Display all base map layers with styling
SELECT * FROM public.all_base_layers;

-- 2. Styled base map layers (individual QGIS exports)
-- Display all styled base map layers
SELECT * FROM public.styled_base_layers;

-- 3. VK500 data (500m grid) - populated areas
-- Display 500m grid cells with population > 0
SELECT * FROM public.vk500_viz 
WHERE aantal_inwoners > 0 
LIMIT 500;

-- 4. VK100 data (100m grid) - populated areas
-- Display 100m grid cells with population > 0
SELECT * FROM public.vk100_viz 
WHERE aantal_inwoners > 0 
LIMIT 500;

-- 5. Combined view: Styled base map + VK500 data
-- Display styled base map with 500m grid population data
SELECT * FROM public.styled_netherlands_viz;

-- 6. Amsterdam area with 100m grid data (create custom view)
-- This creates a temporary view for Amsterdam with VK100 data
WITH amsterdam_bbox AS (
  SELECT ST_MakeEnvelope(4.82, 52.32, 4.95, 52.42, 4326) AS bbox
)
SELECT * FROM public.styled_base_layers

UNION ALL

SELECT
  v.id::text,
  v.geometry,
  'amsterdam_vk100' AS layer_type,
  '#ff0000' AS fill_color,
  0.7 AS fill_opacity,
  NULL AS stroke_color,
  0 AS stroke_width
FROM
  public.vk100_viz v,
  amsterdam_bbox a
WHERE
  ST_Intersects(
    ST_GeomFromGeoJSON(v.geometry::text),
    a.bbox
  )
  AND v.aantal_inwoners > 0
LIMIT 500;

-- 7. Population density visualization with color scale
-- Display VK500 data with color scale based on population density
SELECT
  id::text,
  geometry,
  'population_density' AS layer_type,
  -- Create a color scale based on population density
  CASE 
    WHEN aantal_inwoners > 1000 THEN '#7a0177' -- Very high density
    WHEN aantal_inwoners > 500 THEN '#c51b8a' -- High density
    WHEN aantal_inwoners > 250 THEN '#f768a1' -- Medium-high density
    WHEN aantal_inwoners > 100 THEN '#fa9fb5' -- Medium density
    WHEN aantal_inwoners > 50 THEN '#fcc5c0' -- Low-medium density
    WHEN aantal_inwoners > 0 THEN '#feebe2' -- Low density
    ELSE '#f5f5f5' -- No population
  END AS fill_color,
  0.8 AS fill_opacity,
  NULL AS stroke_color,
  0 AS stroke_width,
  aantal_inwoners,
  aantal_mannen,
  aantal_vrouwen
FROM
  public.vk500_viz
WHERE
  aantal_inwoners > 0
LIMIT 1000;

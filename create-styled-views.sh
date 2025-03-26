#\!/bin/bash

# Create styled visualization views based on the actual database schema
echo "Creating styled visualization views..."

# Create visualization views with proper styling
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Country outline
CREATE OR REPLACE VIEW public.styled_country_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  statnaam,
  statcode,
  -- Styling
  'country' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#8d8d8d' as stroke_color,
  1 as stroke_width
FROM 
  styled_basemap.country;

-- Water bodies
CREATE OR REPLACE VIEW public.styled_water_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  nederlandse_naam as name,
  type_water as type,
  -- Styling
  'water' as layer_type,
  '#a0c8f0' as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  styled_basemap.water;

-- Forests
CREATE OR REPLACE VIEW public.styled_forests_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  -- Styling
  'forests' as layer_type,
  '#c6e2c6' as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  styled_basemap.forests;

-- Railways
CREATE OR REPLACE VIEW public.styled_railways_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  type,
  -- Styling
  'railways' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#b3b3b3' as stroke_color,
  1 as stroke_width
FROM 
  styled_basemap.railways;

-- Highways
CREATE OR REPLACE VIEW public.styled_highways_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  -- Styling
  'highways' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#f07800' as stroke_color,
  2 as stroke_width
FROM 
  styled_basemap.highways;

-- Combined styled base layers
CREATE OR REPLACE VIEW public.styled_base_layers AS
-- Water (bottom layer)
SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_water_viz

UNION ALL

-- Forests
SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_forests_viz

UNION ALL

-- Railways
SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_railways_viz

UNION ALL

-- Highways
SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_highways_viz

UNION ALL

-- Country (top layer)
SELECT 
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM 
  public.styled_country_viz;
"

echo "Testing the views..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
SELECT 'Styled base layers count: ' || COUNT(*) FROM public.styled_base_layers;
"

echo "Styled visualization views created successfully\!"
echo ""
echo "Try this query in Dekart:"
echo ""
echo "SELECT * FROM public.styled_base_layers;"

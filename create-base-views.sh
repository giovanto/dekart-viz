#!/bin/bash

# Create visualization views for base map layers
echo "Creating base map visualization views..."

# Create base layer views
echo "Creating base layer views..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Country outline
CREATE OR REPLACE VIEW public.country_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'country' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#8d8d8d' as stroke_color,
  1 as stroke_width
FROM 
  basemap.country;

-- Water bodies
CREATE OR REPLACE VIEW public.water_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'water' as layer_type,
  '#a0c8f0' as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  basemap.water;

-- Forests
CREATE OR REPLACE VIEW public.forests_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'forests' as layer_type,
  '#c6e2c6' as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  basemap.forests;

-- Railways
CREATE OR REPLACE VIEW public.railways_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'railways' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#b3b3b3' as stroke_color,
  1 as stroke_width
FROM 
  basemap.railways;

-- Highways
CREATE OR REPLACE VIEW public.highways_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'highways' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#f07800' as stroke_color,
  2 as stroke_width
FROM 
  basemap.highways;
"

# Create combined base layer view
echo "Creating combined base layer view..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
CREATE OR REPLACE VIEW public.base_layers AS
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
  public.water_viz

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
  public.forests_viz

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
  public.railways_viz

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
  public.highways_viz

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
  public.country_viz;
"

# Create combined view with VK500 data
echo "Creating combined view with VK500 data..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
CREATE OR REPLACE VIEW public.netherlands_viz AS
-- First add base layers
SELECT * FROM public.base_layers

UNION ALL

-- Then add VK500 data
SELECT
  id::text,
  geometry,
  layer_type,
  fill_color,
  fill_opacity,
  stroke_color,
  stroke_width
FROM
  public.vk500_viz
WHERE
  aantal_inwoners > 0
LIMIT 500;
"

echo "Testing base layer views..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
SELECT 'Base layers count: ' || COUNT(*) FROM public.base_layers;
"

echo "Base map views created successfully!"
echo ""
echo "Try these queries in Dekart:"
echo ""
echo "1. Base map only:"
echo "   SELECT * FROM public.base_layers;"
echo ""
echo "2. Netherlands visualization (base map + VK500 data):"
echo "   SELECT * FROM public.netherlands_viz;"
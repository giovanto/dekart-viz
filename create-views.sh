#!/bin/bash

# Create visualization views for Kepler.gl with correct GeoJSON formatting and styling
echo "Creating visualization views for Kepler.gl..."

# Base map views with styling
echo "Creating base map views with styling..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Built-up areas (light grey)
CREATE OR REPLACE VIEW public.built_up_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'built_up' as layer_type,
  '#e0e0e0' as fill_color,
  0.6 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  basemap.built_up;

-- Forests (green)
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

-- Heathland (light purple)
CREATE OR REPLACE VIEW public.heathland_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'heathland' as layer_type,
  '#e6c9e6' as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  basemap.heathland;

-- Sandy areas (beige)
CREATE OR REPLACE VIEW public.sand_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'sand' as layer_type,
  '#f5e8c8' as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  basemap.sand;

-- Industrial areas (light brown)
CREATE OR REPLACE VIEW public.industrial_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'industrial' as layer_type,
  '#dbd0c0' as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM 
  basemap.industrial;

-- Country outline (grey border)
CREATE OR REPLACE VIEW public.country_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'country' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#8d8d8d' as stroke_color,
  1 as stroke_width,
  statnaam
FROM 
  basemap.country;

-- Main roads (light orange)
CREATE OR REPLACE VIEW public.main_roads_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'main_roads' as layer_type,
  NULL as fill_color,
  0 as fill_opacity,
  '#f0a173' as stroke_color,
  1.5 as stroke_width
FROM 
  basemap.main_roads;

-- Water (blue)
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

-- Railways (grey)
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

-- Highways (orange)
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

# Combined base map view
echo "Creating combined base map view..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Create a view combining all base layers with proper stacking order
CREATE OR REPLACE VIEW public.all_base_layers AS
-- Natural features (bottom layers)
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

SELECT 
  id::text, 
  geometry, 
  layer_type, 
  fill_color, 
  fill_opacity, 
  stroke_color, 
  stroke_width 
FROM 
  public.sand_viz

UNION ALL

SELECT 
  id::text, 
  geometry, 
  layer_type, 
  fill_color, 
  fill_opacity, 
  stroke_color, 
  stroke_width 
FROM 
  public.heathland_viz

UNION ALL

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

-- Human features (middle layers)
SELECT 
  id::text, 
  geometry, 
  layer_type, 
  fill_color, 
  fill_opacity, 
  stroke_color, 
  stroke_width 
FROM 
  public.industrial_viz

UNION ALL

SELECT 
  id::text, 
  geometry, 
  layer_type, 
  fill_color, 
  fill_opacity, 
  stroke_color, 
  stroke_width 
FROM 
  public.built_up_viz

UNION ALL

-- Transportation (top layers)
SELECT 
  id::text, 
  geometry, 
  layer_type, 
  fill_color, 
  fill_opacity, 
  stroke_color, 
  stroke_width 
FROM 
  public.main_roads_viz

UNION ALL

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

-- Country boundary (topmost layer)
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

# CBS Data views
echo "Creating VK500 visualization view..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Create VK500 visualization view with proper GeoJSON formatting
CREATE OR REPLACE VIEW public.vk500_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'vk500' as layer_type,
  CASE WHEN aantal_inwoners > 0 THEN '#ff7800' ELSE '#aaaaaa' END as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width,
  crs28992res500m,
  aantal_inwoners,
  aantal_mannen,
  aantal_vrouwen,
  aantal_inwoners_0_tot_15_jaar,
  aantal_inwoners_15_tot_25_jaar,
  aantal_inwoners_25_tot_45_jaar,
  aantal_inwoners_45_tot_65_jaar,
  aantal_inwoners_65_jaar_en_ouder,
  aantal_geboorten,
  percentage_geb_nederland_herkomst_nederland,
  percentage_geb_nederland_herkomst_overig_europa,
  percentage_geb_nederland_herkomst_buiten_europa,
  percentage_geb_buiten_nederland_herkomst_europa,
  percentage_geb_buiten_nederland_herkmst_buiten_europa,
  aantal_part_huishoudens,
  aantal_eenpersoonshuishoudens,
  aantal_meerpersoonshuishoudens_zonder_kind,
  aantal_eenouderhuishoudens,
  aantal_tweeouderhuishoudens,
  gemiddelde_huishoudensgrootte,
  aantal_woningen,
  aantal_woningen_bouwjaar_voor_1945,
  aantal_woningen_bouwjaar_45_tot_65,
  aantal_woningen_bouwjaar_65_tot_75,
  aantal_woningen_bouwjaar_75_tot_85,
  aantal_woningen_bouwjaar_85_tot_95,
  aantal_woningen_bouwjaar_95_tot_05,
  aantal_woningen_bouwjaar_05_tot_15,
  aantal_woningen_bouwjaar_15_en_later,
  aantal_meergezins_woningen,
  percentage_koopwoningen,
  percentage_huurwoningen,
  aantal_huurwoningen_in_bezit_woningcorporaties,
  aantal_niet_bewoonde_woningen,
  gemiddelde_woz_waarde_woning,
  gemiddeld_gasverbruik_woning,
  gemiddeld_elektriciteitsverbruik_woning,
  gemiddeld_inkomen_huishouden,
  percentage_laag_inkomen_huishouden,
  percentage_hoog_inkomen_huishouden,
  aantal_personen_met_uitkering_onder_aowlft,
  dichtstbijzijnde_grote_supermarkt_afstand_in_km,
  grote_supermarkt_aantal_binnen_1_km,
  grote_supermarkt_aantal_binnen_3_km,
  grote_supermarkt_aantal_binnen_5_km,
  dichtstbijzijnde_winkels_ov_dagel_levensm_afst_in_km,
  winkels_ov_dagel_levensm_aantal_binnen_1_km,
  winkels_ov_dagel_levensm_aantal_binnen_3_km,
  winkels_ov_dagel_levensm_aantal_binnen_5_km,
  dichtstbijzijnde_warenhuis_afstand_in_km,
  warenhuis_aantal_binnen_5_km,
  warenhuis_aantal_binnen_10_km,
  warenhuis_aantal_binnen_20_km,
  dichtstbijzijnde_cafe_afstand_in_km,
  cafe_aantal_binnen_1_km,
  cafe_aantal_binnen_3_km,
  cafe_aantal_binnen_5_km,
  dichtstbijzijnde_cafetaria_afstand_in_km,
  cafetaria_aantal_binnen_1_km,
  cafetaria_aantal_binnen_3_km,
  cafetaria_aantal_binnen_5_km,
  dichtstbijzijnde_hotel_afstand_in_km,
  hotel_aantal_binnen_5_km,
  hotel_aantal_binnen_10_km,
  hotel_aantal_binnen_20_km,
  dichtstbijzijnde_restaurant_afstand_in_km,
  restaurant_aantal_binnen_1_km,
  restaurant_aantal_binnen_3_km,
  restaurant_aantal_binnen_5_km,
  dichtstbijzijnde_buitenschoolse_opvang_afstand_in_km,
  buitenschoolse_opvang_aantal_binnen_1_km,
  buitenschoolse_opvang_aantal_binnen_3_km,
  buitenschoolse_opvang_aantal_binnen_5_km,
  dichtstbijzijnde_kinderdagverblijf_afstand_in_km,
  kinderdagverblijf_aantal_binnen_1_km,
  kinderdagverblijf_aantal_binnen_3_km,
  kinderdagverblijf_aantal_binnen_5_km,
  dichtstbijzijnde_brandweerkazerne_afstand_in_km,
  dichtstbijzijnde_oprit_hoofdverkeersweg_afstand_in_km,
  dichtstbijzijnde_overstapstation_afstand_in_km,
  dichtstbijzijnde_treinstation_afstand_in_km,
  dichtstbijzijnde_attractiepark_afstand_in_km,
  attractiepark_aantal_binnen_10_km,
  attractiepark_aantal_binnen_20_km,
  attractiepark_aantal_binnen_50_km,
  dichtstbijzijnde_bioscoop_afstand_in_km,
  bioscoop_aantal_binnen_5_km,
  bioscoop_aantal_binnen_10_km,
  bioscoop_aantal_binnen_20_km,
  dichtstbijzijnde_museum_afstand_in_km,
  museum_aantal_binnen_5_km,
  museum_aantal_binnen_10_km,
  museum_aantal_binnen_20_km,
  dichtstbijzijnde_theater_afstand_in_km,
  theater_aantal_binnen_5_km,
  theater_aantal_binnen_10_km,
  theater_aantal_binnen_20_km,
  dichtstbijzijnde_bibliotheek_afstand_in_km,
  dichtstbijzijnde_kunstijsbaan_afstand_in_km,
  dichtstbijzijnde_poppodium_afstand_in_km,
  dichtstbijzijnde_sauna_afstand_in_km,
  dichtstbijzijnde_zonnebank_afstand_in_km,
  dichtstbijzijnde_zwembad_afstand_in_km,
  dichtstbijzijnde_basisonderwijs_afstand_in_km,
  basisonderwijs_aantal_binnen_1_km,
  basisonderwijs_aantal_binnen_3_km,
  basisonderwijs_aantal_binnen_5_km,
  dichtstbijzijnde_havo_vwo_afstand_in_km,
  havo_vwo_aantal_binnen_3_km,
  havo_vwo_aantal_binnen_5_km,
  havo_vwo_aantal_binnen_10_km,
  dichtstbijzijnde_vmbo_afstand_in_km,
  vmbo_aantal_binnen_3_km,
  vmbo_aantal_binnen_5_km,
  vmbo_aantal_binnen_10_km,
  dichtstbijzijnde_voortgezet_onderwijs_afstand_in_km,
  voortgezet_onderwijs_aantal_binnen_3_km,
  voortgezet_onderwijs_aantal_binnen_5_km,
  voortgezet_onderwijs_aantal_binnen_10_km,
  dichtstbijzijnde_huisartsenpraktijk_afstand_in_km,
  huisartsenpraktijk_aantal_binnen_1_km,
  huisartsenpraktijk_aantal_binnen_3_km,
  huisartsenpraktijk_aantal_binnen_5_km,
  dichtstbijzijnde_ziekenh_excl_buitenpoli_afst_in_km,
  ziekenhuis_excl_buitenpoli_aantal_binnen_5_km,
  ziekenhuis_excl_buitenpoli_aantal_binnen_10_km,
  ziekenhuis_excl_buitenpoli_aantal_binnen_20_km,
  dichtstbijzijnde_ziekenh_incl_buitenpoli_afst_in_km,
  ziekenhuis_incl_buitenpoli_aantal_binnen_5_km,
  ziekenhuis_incl_buitenpoli_aantal_binnen_10_km,
  ziekenhuis_incl_buitenpoli_aantal_binnen_20_km,
  dichtstbijzijnde_apotheek_afstand_in_km,
  dichtstbijzijnde_huisartsenpost_afstand_in_km,
  omgevingsadressendichtheid,
  stedelijkheid
FROM 
  cbs_complete.vk500;
"

echo "Creating VK100 visualization view..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Create VK100 visualization view with proper GeoJSON formatting
CREATE OR REPLACE VIEW public.vk100_viz AS
SELECT 
  id,
  ST_AsGeoJSON(geom)::jsonb AS geometry,
  'vk100' as layer_type,
  CASE WHEN aantal_inwoners > 0 THEN '#ff0000' ELSE '#cccccc' END as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width,
  crs28992res100m,
  aantal_inwoners,
  aantal_mannen,
  aantal_vrouwen,
  aantal_inwoners_0_tot_15_jaar,
  aantal_inwoners_15_tot_25_jaar,
  aantal_inwoners_25_tot_45_jaar,
  aantal_inwoners_45_tot_65_jaar,
  aantal_inwoners_65_jaar_en_ouder,
  stedelijkheid
FROM 
  cbs_vk100.vk100;
"

# Create combined visualization examples
echo "Creating example combined views..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Create Amsterdam area view (combining base map with VK100 data)
CREATE OR REPLACE VIEW public.amsterdam_area AS
-- First add base layers within Amsterdam area
SELECT * FROM public.all_base_layers
UNION ALL
-- Then add VK100 data for Amsterdam
SELECT
  id::text,
  geometry,
  'amsterdam_vk100' as layer_type,
  CASE WHEN aantal_inwoners > 0 THEN '#ff0000' ELSE '#cccccc' END as fill_color,
  0.7 as fill_opacity,
  NULL as stroke_color,
  0 as stroke_width
FROM
  public.vk100_viz
WHERE 
  ST_Intersects(
    geom,
    ST_MakeEnvelope(4.82, 52.32, 4.95, 52.42, 4326)
  )
  AND aantal_inwoners > 0
LIMIT 1000;
"

echo "Testing the views..."
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
SELECT 'VK500 view count: ' || COUNT(*) FROM public.vk500_viz;
SELECT 'VK100 view count: ' || COUNT(*) FROM public.vk100_viz;
SELECT 'Base layers view count: ' || COUNT(*) FROM public.all_base_layers;
"

echo "Views created successfully!"
echo ""
echo "You can now use these queries in Dekart:"
echo ""
echo "1. Base map only:"
echo "   SELECT * FROM public.all_base_layers;"
echo ""
echo "2. VK500 data (with population):"
echo "   SELECT * FROM public.vk500_viz WHERE aantal_inwoners > 0 LIMIT 500;"
echo ""
echo "3. VK100 data (with population):"
echo "   SELECT * FROM public.vk100_viz WHERE aantal_inwoners > 0 LIMIT 500;"
echo ""
echo "4. Amsterdam area with detailed 100m grid:"
echo "   SELECT * FROM public.amsterdam_area;"
echo ""
echo "5. Custom combination (base map + VK500 data):"
echo "   SELECT * FROM public.all_base_layers"
echo "   UNION ALL"
echo "   SELECT "
echo "     id::text,"
echo "     geometry,"
echo "     layer_type,"
echo "     fill_color,"
echo "     fill_opacity,"
echo "     stroke_color,"
echo "     stroke_width"
echo "   FROM"
echo "     public.vk500_viz"
echo "   WHERE"
echo "     aantal_inwoners > 0"
echo "   LIMIT 500;"
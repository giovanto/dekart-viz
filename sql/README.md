# SQL Examples for Dekart-Viz

This directory contains SQL examples for use with Dekart-Viz platform.

## Overview

The SQL examples are organized into categories:

- **Examples**: Common visualization queries for Kepler.gl
- **Utils**: Utility queries for geospatial operations

## Example Queries

### Base Map Layers

```sql
-- Display all base map layers with styling
SELECT * FROM public.all_base_layers;

-- Display all styled base map layers (from individual QGIS exports)
SELECT * FROM public.styled_base_layers;
```

### CBS Grid Data

```sql
-- VK500 data (500m grid) - populated areas
SELECT * FROM public.vk500_viz 
WHERE aantal_inwoners > 0 
LIMIT 500;

-- VK100 data (100m grid) - populated areas
SELECT * FROM public.vk100_viz 
WHERE aantal_inwoners > 0 
LIMIT 500;
```

### Combined Visualizations

```sql
-- Combined view: Styled base map + VK500 data
SELECT * FROM public.styled_netherlands_viz;
```

## Key Files

- **all-layers-query.sql**: Examples for all layer types with detailed options
- **kepler-geojson-query.sql**: Specific format for Kepler.gl visualization
- **cbs-viz-queries.sql**: Visualizations using CBS data
- **city-visualization.sql**: City-specific visualizations

## Tips for Using SQL with Kepler.gl

1. **GeoJSON Format**: Always use `ST_AsGeoJSON(geom)::jsonb AS geometry` to format geometries correctly

2. **Styling in SQL**: Include styling parameters in your queries:
   ```sql
   SELECT 
     id,
     ST_AsGeoJSON(geom)::jsonb AS geometry,
     'type_name' as layer_type,
     '#hexcolor' as fill_color,
     0.7 as fill_opacity,
     '#hexcolor' as stroke_color,
     1 as stroke_width
   FROM your_table;
   ```

3. **Performance**: Always use:
   - `LIMIT` clause to restrict result size
   - `WHERE` conditions to filter data
   - Spatial indexes for faster queries

4. **Common Issues**:
   - If visualization doesn't appear, check the geometry format
   - Kepler.gl requires proper GeoJSON format with the `::jsonb` cast
   - Large datasets may slow down the browser
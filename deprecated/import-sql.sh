#!/bin/bash

# Import sample GeoJSON directly using SQL
echo "Importing sample GeoJSON using SQL..."

# Run SQL to create the table and import the data
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Create the table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.dutch_cities (
    id SERIAL PRIMARY KEY,
    name TEXT,
    description TEXT,
    geom GEOMETRY(Point, 4326)
);

-- Clear existing data
TRUNCATE public.dutch_cities;

-- Insert Amsterdam
INSERT INTO public.dutch_cities (name, description, geom)
VALUES ('Amsterdam', 'Capital of the Netherlands', 
        ST_SetSRID(ST_MakePoint(4.9041, 52.3676), 4326));

-- Insert Rotterdam
INSERT INTO public.dutch_cities (name, description, geom)
VALUES ('Rotterdam', 'Major port city in the Netherlands', 
        ST_SetSRID(ST_MakePoint(4.4777, 51.9244), 4326));

-- Insert Utrecht
INSERT INTO public.dutch_cities (name, description, geom)
VALUES ('Utrecht', 'Historic city in the Netherlands', 
        ST_SetSRID(ST_MakePoint(5.1214, 52.0907), 4326));

-- Create spatial index
CREATE INDEX IF NOT EXISTS dutch_cities_geom_idx ON public.dutch_cities USING GIST (geom);
"

echo "Import completed! Data is now available in the PostgreSQL database."
echo "You can now create queries in Dekart using this data."
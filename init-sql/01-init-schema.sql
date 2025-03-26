-- Initialize database with PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create public schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS public;

-- Create a sample points table
CREATE TABLE IF NOT EXISTS public.sample_points (
    id SERIAL PRIMARY KEY,
    name TEXT,
    description TEXT,
    geom GEOMETRY(Point, 4326)
);

-- Insert some sample points
INSERT INTO public.sample_points (name, description, geom)
VALUES 
    ('Point 1', 'Sample point in Amsterdam', ST_SetSRID(ST_MakePoint(4.9041, 52.3676), 4326)),
    ('Point 2', 'Sample point in Rotterdam', ST_SetSRID(ST_MakePoint(4.4777, 51.9244), 4326)),
    ('Point 3', 'Sample point in Utrecht', ST_SetSRID(ST_MakePoint(5.1214, 52.0907), 4326));

-- Create index on geometry column
CREATE INDEX IF NOT EXISTS sample_points_geom_idx ON public.sample_points USING GIST (geom);

-- Create a view with sample points
CREATE OR REPLACE VIEW public.sample_points_view AS
SELECT 
    id,
    name,
    description,
    geom,
    ST_X(geom) AS longitude,
    ST_Y(geom) AS latitude
FROM public.sample_points;
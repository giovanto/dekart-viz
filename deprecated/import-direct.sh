#!/bin/bash

# This script creates a sample dataset in PostgreSQL for testing
echo "Creating sample Netherlands dataset in PostgreSQL..."

# Create netherlands schema and tables
docker exec dekart-viz-db-1 psql -U dekart_user -d dekart -c "
-- Create schema
CREATE SCHEMA IF NOT EXISTS netherlands;

-- Create table for VK500 grid data
DROP TABLE IF EXISTS netherlands.vk500;
CREATE TABLE netherlands.vk500 (
    id SERIAL PRIMARY KEY,
    grid_id VARCHAR(10),
    aantal_inwoners INTEGER,
    aantal_woningen INTEGER,
    gemiddeld_inkomen_huishouden NUMERIC(10,2),
    percentage_laag_inkomen_huishouden NUMERIC(5,2),
    percentage_hoog_inkomen_huishouden NUMERIC(5,2),
    gemiddelde_woz_waarde_woning INTEGER,
    dichtstbijzijnde_treinstation_afstand_in_km NUMERIC(5,2),
    stedelijkheid INTEGER,
    geom GEOMETRY(POLYGON, 4326)
);

-- Add some sample city data (Amsterdam, Rotterdam, Utrecht, The Hague)
INSERT INTO netherlands.vk500 (grid_id, aantal_inwoners, aantal_woningen, gemiddeld_inkomen_huishouden, 
                              percentage_laag_inkomen_huishouden, percentage_hoog_inkomen_huishouden,
                              gemiddelde_woz_waarde_woning, dichtstbijzijnde_treinstation_afstand_in_km,
                              stedelijkheid, geom)
VALUES 
-- Amsterdam center
('AMDM01', 15243, 8125, 42300.50, 22.5, 31.2, 485000, 0.8, 1,
  ST_Transform(ST_GeomFromText('POLYGON((121000 487000, 121500 487000, 121500 487500, 121000 487500, 121000 487000))', 28992), 4326)),

-- Amsterdam canal belt
('AMDM02', 8720, 4850, 51200.75, 18.3, 42.1, 612000, 1.2, 1,
  ST_Transform(ST_GeomFromText('POLYGON((120500 486500, 121000 486500, 121000 487000, 120500 487000, 120500 486500))', 28992), 4326)),

-- Rotterdam center
('RDAM01', 12450, 7100, 38750.25, 25.8, 28.7, 398000, 0.5, 1,
  ST_Transform(ST_GeomFromText('POLYGON((92000 436500, 92500 436500, 92500 437000, 92000 437000, 92000 436500))', 28992), 4326)),

-- Rotterdam port area
('RDAM02', 3250, 1850, 42100.50, 20.2, 32.8, 340000, 2.8, 2,
  ST_Transform(ST_GeomFromText('POLYGON((91500 436000, 92000 436000, 92000 436500, 91500 436500, 91500 436000))', 28992), 4326)),

-- Utrecht center
('UTRCH01', 10800, 5950, 45300.75, 19.6, 35.4, 425000, 0.7, 1,
  ST_Transform(ST_GeomFromText('POLYGON((136000 455500, 136500 455500, 136500 456000, 136000 456000, 136000 455500))', 28992), 4326)),

-- The Hague center
('SGRAV01', 11250, 6300, 43900.25, 21.4, 33.8, 440000, 0.6, 1,
  ST_Transform(ST_GeomFromText('POLYGON((81500 454500, 82000 454500, 82000 455000, 81500 455000, 81500 454500))', 28992), 4326)),

-- Rural area (Veluwe)
('VELUW01', 850, 320, 48500.50, 15.2, 38.5, 380000, 12.6, 5,
  ST_Transform(ST_GeomFromText('POLYGON((180000 465000, 180500 465000, 180500 465500, 180000 465500, 180000 465000))', 28992), 4326)),

-- Small town (Zwolle area)
('ZWOLL01', 3850, 1650, 41200.25, 18.7, 30.2, 310000, 3.8, 3,
  ST_Transform(ST_GeomFromText('POLYGON((202000 502000, 202500 502000, 202500 502500, 202000 502500, 202000 502000))', 28992), 4326)),

-- Eindhoven area
('EINDH01', 9200, 4350, 42800.75, 19.4, 32.5, 350000, 1.2, 2,
  ST_Transform(ST_GeomFromText('POLYGON((160000 382000, 160500 382000, 160500 382500, 160000 382500, 160000 382000))', 28992), 4326)),

-- Maastricht area
('MAAST01', 7800, 4100, 40500.50, 22.3, 29.8, 320000, 1.8, 2,
  ST_Transform(ST_GeomFromText('POLYGON((176000 317000, 176500 317000, 176500 317500, 176000 317500, 176000 317000))', 28992), 4326));

-- Create spatial index
CREATE INDEX vk500_geom_idx ON netherlands.vk500 USING GIST (geom);

-- Create additional indexes
CREATE INDEX vk500_inwoners_idx ON netherlands.vk500 (aantal_inwoners);
CREATE INDEX vk500_woningen_idx ON netherlands.vk500 (aantal_woningen);
CREATE INDEX vk500_inkomen_idx ON netherlands.vk500 (gemiddeld_inkomen_huishouden);

-- Output count
SELECT COUNT(*) FROM netherlands.vk500;
"

echo "Import completed! Sample data is now available in the PostgreSQL database."
echo "You can now create queries in Dekart using: SELECT * FROM netherlands.vk500;"
#!/bin/bash

# Check if arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <geodata_file> <schema_name> <table_name>"
    echo "Example: $0 ./data/my-data.geojson public my_geojson_data"
    exit 1
fi

GEODATA_FILE=$1
SCHEMA_NAME=$2
TABLE_NAME=$3

# Check if file exists
if [ ! -f "$GEODATA_FILE" ]; then
    echo "Error: File $GEODATA_FILE does not exist"
    exit 1
fi

# Get file extension to determine import type
FILE_EXT=${GEODATA_FILE##*.}

echo "Importing $GEODATA_FILE into $SCHEMA_NAME.$TABLE_NAME"

if [ "$FILE_EXT" = "geojson" ]; then
    # Import GeoJSON
    echo "Detected GeoJSON file. Importing using ogr2ogr..."
    docker run --rm --network host -v $(pwd):/data osgeo/gdal:alpine-small-latest \
        ogr2ogr -f "PostgreSQL" \
        PG:"host=localhost user=dekart_user password=your_password dbname=dekart" \
        "/data/${GEODATA_FILE#./}" \
        -lco GEOMETRY_NAME=geom \
        -lco FID=id \
        -lco PRECISION=NO \
        -nln ${SCHEMA_NAME}.${TABLE_NAME} \
        -overwrite
elif [ "$FILE_EXT" = "gpkg" ]; then
    # Import GeoPackage
    echo "Detected GeoPackage file. Importing using ogr2ogr..."
    docker run --rm --network host -v $(pwd):/data osgeo/gdal:alpine-small-latest \
        ogr2ogr -f "PostgreSQL" \
        PG:"host=localhost user=dekart_user password=your_password dbname=dekart" \
        "/data/${GEODATA_FILE#./}" \
        -lco GEOMETRY_NAME=geom \
        -lco FID=id \
        -lco PRECISION=NO \
        -nln ${SCHEMA_NAME}.${TABLE_NAME} \
        -overwrite
elif [ "$FILE_EXT" = "csv" ]; then
    # For CSV files, we'll use PostgreSQL's COPY command
    echo "Detected CSV file. Importing using PostgreSQL COPY..."
    
    # Create a temporary table definition file
    TMP_SQL=$(mktemp)
    
    # Create table with basic schema - adjust as needed
    echo "CREATE SCHEMA IF NOT EXISTS ${SCHEMA_NAME};" > $TMP_SQL
    echo "DROP TABLE IF EXISTS ${SCHEMA_NAME}.${TABLE_NAME};" >> $TMP_SQL
    echo "CREATE TABLE ${SCHEMA_NAME}.${TABLE_NAME} (" >> $TMP_SQL
    
    # Read the first line of CSV to get headers
    HEADERS=$(head -1 "$GEODATA_FILE")
    IFS=',' read -ra COLUMNS <<< "$HEADERS"
    
    # Add columns to table definition
    for i in "${!COLUMNS[@]}"; do
        COLUMN=$(echo "${COLUMNS[$i]}" | tr -d '"' | tr -d "'" | tr ' ' '_')
        if [ $i -eq 0 ]; then
            echo "    $COLUMN text" >> $TMP_SQL
        else
            echo "    ,$COLUMN text" >> $TMP_SQL
        fi
    done
    
    echo ");" >> $TMP_SQL
    echo "COPY ${SCHEMA_NAME}.${TABLE_NAME} FROM '/data/${GEODATA_FILE#./}' DELIMITER ',' CSV HEADER;" >> $TMP_SQL
    
    # Execute SQL
    docker-compose exec -T db psql -U dekart_user -d dekart -f /dev/stdin < $TMP_SQL
    
    rm $TMP_SQL
else
    echo "Unsupported file format: $FILE_EXT. Supported formats are: geojson, gpkg, csv"
    exit 1
fi

echo "Import completed! Data is now available in the PostgreSQL database."
echo "You can now create queries in Dekart using this data."
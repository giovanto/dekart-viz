# Dekart-Viz

A self-hosted geospatial visualization platform based on [Dekart](https://github.com/dekart-xyz/dekart) and [Kepler.gl](https://github.com/keplergl/kepler.gl).

**Status: Operational** - All components have been tested and verified working correctly.

## Architecture

This project implements a local geospatial visualization platform with the following components:

- **PostgreSQL with PostGIS**: Database for storing geospatial data
- **MinIO**: S3-compatible object storage for caching query results (replacing AWS S3)
- **Dekart**: Backend service that connects to PostgreSQL and provides a web interface
- **Kepler.gl**: Visualization library integrated with Dekart

## Key Features

- **Self-contained setup**: All components run locally in Docker containers
- **PostGIS integration**: Support for advanced geospatial queries
- **Local S3-compatible storage**: Uses MinIO instead of AWS S3
- **Kepler.gl visualization**: Powerful WebGL-based geospatial visualization
- **Import tooling**: Easy import of GeoJSON, GeoPackage, and CSV files

## Prerequisites

- Docker and Docker Compose
- A Mapbox API token (already configured in the docker-compose.yml)

## Getting Started

1. Start the services:
   ```bash
   ./start-dekart-viz.sh
   ```

2. Access the platform:
   - Dekart web interface: http://localhost:8081
   - MinIO console: http://localhost:9001 (login: minio / minio123)

## Importing Geospatial Data

The platform includes several scripts for importing geospatial data:

### General Import Tool

Use this script to import GeoJSON, GeoPackage, or CSV files:

```bash
./import-geodata.sh ./path/to/data.geojson public my_table_name
```

Example:
```bash
./import-geodata.sh ./data/sample.geojson public sample_data
```

### CBS VK500 Grid Dataset

For the Dutch 500x500m grid dataset:

1. Import the dataset and create visualization-friendly views in one step:
```bash
./import-cbs-data.sh
```

2. Use these views for visualization in Dekart:
   - For polygon visualization: `SELECT * FROM cbs.vk500_geojson WHERE population > 0 LIMIT 500;`
   - For point visualization: `SELECT * FROM cbs.vk500_points WHERE population > 0 LIMIT 500;`

## Usage

1. Navigate to http://localhost:8081
2. Create a new report
3. Write SQL queries to select data from your imported tables
4. Visualize the data on the map using Kepler.gl's powerful features

## Visualization Tips

### Polygon Visualization (GeoJSON)

When visualizing polygon data:

1. Use queries that include the `geometry` field in GeoJSON format:
   ```sql
   SELECT * FROM cbs.vk500_geojson WHERE population > 0 LIMIT 500;
   ```

2. In Kepler.gl:
   - Set layer type to "Geojson"
   - Use "geometry" as the geometry field
   - For "Fill Color", use fields like "population", "avg_household_income", etc.
   - Adjust opacity to around 70-80%
   - Optionally add height using the same field for 3D visualization

### Point Visualization

When visualizing point data:

1. Use queries that include longitude and latitude fields:
   ```sql
   SELECT * FROM cbs.vk500_points WHERE population > 0 LIMIT 500;
   ```

2. In Kepler.gl:
   - Set layer type to "Point"
   - Use "longitude" and "latitude" columns
   - For "Color", use fields like "population", "urbanization_level", etc.
   - For "Radius", use the same field or another numeric field
   - Optionally enable 3D by setting "Height" based on a numeric field

### Performance Tips

- Always use `LIMIT` in your queries to avoid overloading the browser
- Start with a small number (100-500) and increase if performance allows
- For slower machines, prefer point visualization over polygon visualization
- Use `WHERE` clauses to filter out uninteresting data (e.g., zero population)

## Default Credentials

- **PostgreSQL**:
  - Username: dekart_user
  - Password: your_password
  - Database: dekart
  - Port: 5432

- **MinIO**:
  - Access Key: minio
  - Secret Key: minio123
  - Console URL: http://localhost:9001

## License

This project is licensed under the MIT License.
# Dekart-Viz

A self-hosted geospatial visualization platform based on [Dekart](https://github.com/dekart-xyz/dekart) and [Kepler.gl](https://github.com/keplergl/kepler.gl).

## Architecture

This project implements a local geospatial visualization platform with the following components:

- **PostgreSQL with PostGIS**: Database for storing geospatial data
- **MinIO**: S3-compatible object storage for caching query results
- **Dekart**: Backend service that connects to PostgreSQL and provides a web interface
- **Kepler.gl**: Visualization library integrated with Dekart

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

Use the provided script to import GeoJSON, GeoPackage, or CSV files:

```bash
./import-geodata.sh ./path/to/data.geojson public my_table_name
```

Example:
```bash
./import-geodata.sh ./data/sample.geojson public sample_data
```

## Usage

1. Navigate to http://localhost:8081
2. Create a new report
3. Write SQL queries to select data from your imported tables
4. Visualize the data on the map using Kepler.gl's powerful features

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
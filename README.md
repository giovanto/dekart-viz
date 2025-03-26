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
- **Dutch CBS datasets**: Pre-loaded with 500m and 100m grid data
- **Base maps**: Dutch geography base layers imported from QGIS

## Prerequisites

- Docker and Docker Compose
- A Mapbox API token (already configured in the docker-compose.yml)

## Getting Started

1. Start the services:
   ```bash
   ./start-dekart-viz.sh
   ```

2. Import the data (only needed first time):
   ```bash
   ./import-data.sh  # Import all data sources
   ./create-views.sh  # Create visualization views
   ```

3. For styled base layers from QGIS (optional):
   ```bash
   ./import-styled-base-layers.sh  # Import individual base layers from QGIS
   ./create-styled-views.sh  # Create styled visualization views
   ```

4. Access the platform:
   - Dekart web interface: http://localhost:8081
   - MinIO console: http://localhost:9001 (login: minio / minio123)

## Available Data

The platform has the following datasets pre-loaded:

### CBS Grid Data

1. **VK500 (500m grid)**: Netherlands 500m×500m grid with demographic data
   - 151,108 grid cells
   - Full dataset with demographic information, housing, income, etc.
   - Access via: `public.vk500_viz`

2. **VK100 (100m grid)**: Netherlands 100m×100m grid with detailed demographic data
   - 390,703 grid cells
   - Higher resolution with detailed demographic information
   - Access via: `public.vk100_viz`

### Base Map Layers

Available in two versions:

1. **Combined from SB_Base_Layers.gpkg**:
   - Country boundaries, water bodies, forests, railways, highways, etc.
   - Access via: `public.all_base_layers`

2. **Individual layers from QGIS**:
   - Country boundaries, water bodies, forests, railways, highways, etc.
   - Access via: `public.styled_base_layers`

## Usage Examples

See the provided SQL examples in the `sql/examples` folder:

1. **Basic Map Layers**:
   ```sql
   SELECT * FROM public.all_base_layers;
   -- or
   SELECT * FROM public.styled_base_layers;
   ```

2. **VK500 data** (with population > 0):
   ```sql
   SELECT * FROM public.vk500_viz WHERE aantal_inwoners > 0 LIMIT 500;
   ```

3. **VK100 data** (with population > 0):
   ```sql
   SELECT * FROM public.vk100_viz WHERE aantal_inwoners > 0 LIMIT 500;
   ```

4. **Combined visualization** (base map with VK500 data):
   ```sql
   SELECT * FROM public.styled_netherlands_viz;
   ```

5. **Advanced Examples**: Check `sql/examples/all-layers-query.sql` for more examples, including:
   - Amsterdam area with 100m grid data
   - Population density with color scale
   - Custom combined visualizations

## Visualization Tips

### Working with GeoJSON Data

The views created for visualization provide GeoJSON-formatted geometry that works correctly with Kepler.gl. When creating a new visualization:

1. Run your SQL query
2. In layer configuration:
   - Set layer type to "GeoJSON"
   - Select the "geometry" field for the geometry
   - Configure styling as needed (color, size, etc.)

### Performance Considerations

- Always use `LIMIT` in your queries to avoid overloading the browser
- Start with a small number (100-500) and increase if performance allows
- The VK100 dataset (100m grid) is very large (390,703 cells), so it's recommended to filter strictly
- Use `WHERE aantal_inwoners > 0` to show only populated areas

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

## Project Structure

- **Docker Setup**: `docker-compose.yml`
- **Core Scripts**:
  - `start-dekart-viz.sh`: Start the platform
  - `import-data.sh`: Import all data from CBS and QGIS
  - `create-views.sh`: Create visualization views
  - `import-styled-base-layers.sh`: Import individual base layers from QGIS
  - `create-styled-views.sh`: Create styled visualization views
- **SQL Examples**: `sql/examples/` directory

## License

This project is licensed under the MIT License.
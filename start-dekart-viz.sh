#!/bin/bash

# Start the Dekart-Viz platform
echo "Starting Dekart-Viz platform..."

# Start all services with Docker Compose
echo "Starting Docker services..."
docker compose up -d

# Wait for services to be available
echo "Waiting for services to be available..."
for i in {1..30}; do
  if docker exec dekart-viz-db-1 pg_isready -U dekart_user -d dekart &>/dev/null; then
    echo "Database is ready!"
    break
  fi
  echo "Waiting for database to be ready... ($i/30)"
  sleep 2
done

echo "Services started successfully!"
echo ""
echo "Web interfaces:"
echo "- Dekart web interface: http://localhost:8081"
echo "- MinIO console: http://localhost:9001 (login: minio / minio123)"
echo ""
echo "For data import, run:"
echo "./import-data.sh"
echo ""
echo "For visualization, use these queries in Dekart:"
echo "- VK500 data: SELECT * FROM public.vk500_viz WHERE aantal_inwoners > 0 LIMIT 500;"
echo "- VK100 data: SELECT * FROM public.vk100_viz WHERE aantal_inwoners > 0 LIMIT 500;"
echo "- Base map: SELECT * FROM public.all_base_layers;"
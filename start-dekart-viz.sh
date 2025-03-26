#!/bin/bash

# Start Dekart Visualization Platform
echo "Starting Dekart Visualization Platform..."
docker compose up -d

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

echo "Services started. You can access:"
echo "- Dekart at http://localhost:8081"
echo "- MinIO Console at http://localhost:9001 (login: minio / minio123)"
echo "- PostgreSQL at localhost:5432 (login: dekart_user / your_password)"
echo ""
echo "To import geodata, use the import-geodata.sh script."
#!/bin/bash

# Fix ittools port conflict (change to 8081)
sed -i 's/"8082:80"/"8081:80"/' ittools/docker-compose.yml

# Bind services to localhost only
sed -i 's/"3001:3001"/"127.0.0.1:3001:3001"/' uptime-kuma/docker-compose.yml
sed -i 's/"9090:9090"/"127.0.0.1:9090:9090"/' monitoring/docker-compose.yml
sed -i 's/"9100:9100"/"127.0.0.1:9100:9100"/' monitoring/docker-compose.yml
sed -i 's/"8082:8080"/"127.0.0.1:8082:8080"/' monitoring/docker-compose.yml
sed -i 's/"3000:3000"/"127.0.0.1:3000:3000"/' monitoring/docker-compose.yml
sed -i 's/"8888:80"/"127.0.0.1:8888:80"/' dashboard/docker-compose.yml
sed -i 's/"8081:80"/"127.0.0.1:8081:80"/' ittools/docker-compose.yml
sed -i 's/"8088:80"/"127.0.0.1:8088:80"/' excalidraw/docker-compose.yml
sed -i 's/"9000:9000"/"127.0.0.1:9000:9000"/' portainer/docker-compose.yml
sed -i 's/"9443:9443"/"127.0.0.1:9443:9443"/' portainer/docker-compose.yml

echo "✅ All compose files updated!"
echo "Review changes with: git diff"

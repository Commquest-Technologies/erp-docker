#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Setting up ERP Docker Environment${NC}"

# Create required directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p /var/lib/traefik/certs
mkdir -p /var/lib/portainer
mkdir -p /opt/docker/secrets

# Set proper permissions
chmod 600 /var/lib/traefik/certs
chmod 700 /var/lib/portainer

# Create docker network
echo -e "${YELLOW}Creating Docker network...${NC}"
docker network create --driver=overlay --attachable traefik-public

# Set node labels
echo -e "${YELLOW}Setting node labels...${NC}"
MANAGER_NODE=$(docker node ls --filter role=manager --format '{{.ID}}' | head -n1)
docker node update --label-add traefik-public.traefik-public-certificates=true $MANAGER_NODE
docker node update --label-add portainer.portainer-data=true $MANAGER_NODE

echo -e "${GREEN}Basic setup completed!${NC}"
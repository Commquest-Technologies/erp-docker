#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo -e "${YELLOW}Please copy .env.example to .env and update the values${NC}"
    exit 1
fi

# Load environment variables
source .env

# Export the Traefik password hash for deployment
export HASHED_PASSWORD=$(cat /opt/docker/secrets/traefik_password)

echo -e "${YELLOW}Deploying Traefik...${NC}"
docker stack deploy -c compose/traefik.yml traefik

echo -e "${YELLOW}Waiting for Traefik to start...${NC}"
sleep 30

echo -e "${YELLOW}Deploying Portainer...${NC}"
docker stack deploy -c compose/portainer.yml portainer

echo -e "${GREEN}Deployment completed!${NC}"
echo -e "${YELLOW}Please ensure DNS records are configured for:${NC}"
echo "- $TRAEFIK_DOMAIN"
echo "- $PORTAINER_DOMAIN"
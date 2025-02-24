#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo -e "${YELLOW}Please create the .env file with required environment variables${NC}"
    exit 1
fi

# Load environment variables
source .env

# Check if required variables are set
if [ -z "$EMAIL" ]; then
    echo -e "${RED}Error: EMAIL variable is not set in .env file${NC}"
    exit 1
fi

if [ -z "$TRAEFIK_DOMAIN" ]; then
    echo -e "${RED}Error: TRAEFIK_DOMAIN variable is not set in .env file${NC}"
    exit 1
fi

if [ -z "$PORTAINER_DOMAIN" ]; then
    echo -e "${RED}Error: PORTAINER_DOMAIN variable is not set in .env file${NC}"
    exit 1
fi

# Export variables for Docker Compose
export HASHED_PASSWORD=$(cat /opt/docker/secrets/traefik_password)
export EMAIL
export TRAEFIK_DOMAIN
export PORTAINER_DOMAIN
export TZ=${TZ:-Africa/Johannesburg}
export LOG_LEVEL=${LOG_LEVEL:-INFO}
export CERTS_PATH=${CERTS_PATH:-/var/lib/traefik/certs}
export PORTAINER_DATA_PATH=${PORTAINER_DATA_PATH:-/var/lib/portainer}

# Display variables for debugging (mask sensitive data)
echo -e "${YELLOW}Using the following environment variables:${NC}"
echo "TRAEFIK_DOMAIN: $TRAEFIK_DOMAIN"
echo "EMAIL: $EMAIL"
echo "TZ: $TZ"
echo "LOG_LEVEL: $LOG_LEVEL"
echo "HASHED_PASSWORD: [MASKED]"

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

echo -e "\n${YELLOW}Checking service status:${NC}"
docker service ls
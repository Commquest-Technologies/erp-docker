#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Generating secrets for Traefik and Portainer...${NC}"

# Prompt for Traefik admin password
read -sp "Enter Traefik admin password: " TRAEFIK_PASSWORD
echo

# Generate Traefik password hash
echo -e "${YELLOW}Generating Traefik password hash...${NC}"
htpasswd -nb admin "$TRAEFIK_PASSWORD" > /opt/docker/secrets/traefik_password

# Generate Portainer password
echo -e "${YELLOW}Generating Portainer password...${NC}"
openssl rand -base64 32 > /opt/docker/secrets/portainer_password

# Create Docker secrets
echo -e "${YELLOW}Creating Docker secrets...${NC}"
cat /opt/docker/secrets/traefik_password | docker secret create traefik_passwd -
cat /opt/docker/secrets/portainer_password | docker secret create portainer-pass -

echo -e "${GREEN}Secrets generated and stored in /opt/docker/secrets/${NC}"
echo -e "${YELLOW}Portainer password saved to: /opt/docker/secrets/portainer_password${NC}"
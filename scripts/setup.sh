#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Setting up ERP Docker Environment${NC}"

# Function to check if command succeeded
check_command() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1${NC}"
        exit 1
    fi
}

# Check if script is run with sudo
if [ ! -d "/opt" ]; then
    echo -e "${YELLOW}Creating directories with sudo...${NC}"
    
    # Create base directories
    sudo mkdir -p /var/lib/traefik/certs
    check_command "Failed to create traefik directory"
    
    sudo mkdir -p /var/lib/portainer
    check_command "Failed to create portainer directory"
    
    sudo mkdir -p /opt/docker/secrets
    check_command "Failed to create secrets directory"

    # Set proper ownership
    sudo chown -R ubuntu:ubuntu /var/lib/traefik
    sudo chown -R ubuntu:ubuntu /var/lib/portainer
    sudo chown -R ubuntu:ubuntu /opt/docker

    # Set proper permissions
    sudo chmod 600 /var/lib/traefik/certs
    sudo chmod 700 /var/lib/portainer
    sudo chmod 700 /opt/docker/secrets
fi

# Create docker network (no sudo needed as user is in docker group)
echo -e "${YELLOW}Creating Docker network...${NC}"
if ! docker network ls | grep -q "traefik-public"; then
    docker network create --driver=overlay --attachable traefik-public
    check_command "Failed to create Docker network"
fi

# Set node labels
echo -e "${YELLOW}Setting node labels...${NC}"
MANAGER_NODE=$(docker node ls --filter role=manager --format '{{.ID}}' | head -n1)
check_command "Failed to get manager node ID"

docker node update --label-add traefik-public.traefik-public-certificates=true $MANAGER_NODE
check_command "Failed to add traefik label"

docker node update --label-add portainer.portainer-data=true $MANAGER_NODE
check_command "Failed to add portainer label"

echo -e "${GREEN}Basic setup completed!${NC}"
echo -e "${YELLOW}Created directories:${NC}"
echo "- /var/lib/traefik/certs"
echo "- /var/lib/portainer"
echo "- /opt/docker/secrets"
echo -e "${YELLOW}Verify permissions:${NC}"
ls -la /var/lib/traefik/certs
ls -la /var/lib/portainer
ls -la /opt/docker/secrets
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

# Create directories with proper error handling
echo -e "${YELLOW}Creating directories...${NC}"

# First create parent directories with standard permissions
echo -e "${YELLOW}Creating parent directories...${NC}"
sudo mkdir -p /var/lib/traefik
sudo mkdir -p /var/lib/portainer
sudo mkdir -p /opt/docker

# Set parent directory ownership
sudo chown ubuntu:ubuntu /var/lib/traefik
sudo chown ubuntu:ubuntu /var/lib/portainer
sudo chown ubuntu:ubuntu /opt/docker

# Create subdirectories
echo -e "${YELLOW}Creating subdirectories...${NC}"
mkdir -p /var/lib/traefik/certs
mkdir -p /opt/docker/secrets

# Set directory permissions (more permissive for parent, restricted for sensitive subdirectories)
echo -e "${YELLOW}Setting directory permissions...${NC}"
sudo chmod 755 /var/lib/traefik
sudo chmod 700 /var/lib/traefik/certs
sudo chmod 700 /var/lib/portainer
sudo chmod 755 /opt/docker
sudo chmod 700 /opt/docker/secrets

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

# Verify setup
echo -e "${GREEN}Basic setup completed! Verifying setup...${NC}"

echo -e "${YELLOW}Directory Permissions:${NC}"
echo -e "\nPermissions for /var/lib/traefik:"
ls -la /var/lib/traefik
echo -e "\nPermissions for /var/lib/traefik/certs:"
ls -la /var/lib/traefik/certs
echo -e "\nPermissions for /var/lib/portainer:"
ls -la /var/lib/portainer
echo -e "\nPermissions for /opt/docker:"
ls -la /opt/docker
echo -e "\nPermissions for /opt/docker/secrets:"
ls -la /opt/docker/secrets

echo -e "\n${YELLOW}Docker Network:${NC}"
docker network ls | grep traefik-public

echo -e "\n${YELLOW}Node Labels:${NC}"
docker node inspect $MANAGER_NODE --format '{{ .Spec.Labels }}'

echo -e "\n${GREEN}Setup completed successfully!${NC}"
echo -e "${YELLOW}You can now proceed with generating secrets and deploying the stacks.${NC}"
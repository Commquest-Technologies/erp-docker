#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Generating secrets for Traefik and Portainer...${NC}"

# Check if required directories exist
if [ ! -d "/opt/docker/secrets" ]; then
    echo -e "${RED}Error: /opt/docker/secrets directory not found${NC}"
    echo "Please run setup.sh first"
    exit 1
fi

# Prompt for Traefik admin password with confirmation
while true; do
    echo -e "${YELLOW}Enter Traefik admin password:${NC}"
    read -s TRAEFIK_PASSWORD
    echo
    echo -e "${YELLOW}Confirm Traefik admin password:${NC}"
    read -s TRAEFIK_PASSWORD_CONFIRM
    echo
    
    if [ "$TRAEFIK_PASSWORD" = "$TRAEFIK_PASSWORD_CONFIRM" ]; then
        break
    else
        echo -e "${RED}Passwords do not match. Please try again.${NC}"
    fi
done

# Generate Traefik password hash
echo -e "${YELLOW}Generating Traefik password hash...${NC}"
htpasswd -nb admin "$TRAEFIK_PASSWORD" > /opt/docker/secrets/traefik_password
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to generate Traefik password hash${NC}"
    exit 1
fi

# Generate Portainer password
echo -e "${YELLOW}Generating Portainer password...${NC}"
openssl rand -base64 32 > /opt/docker/secrets/portainer_password
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to generate Portainer password${NC}"
    exit 1
fi

# Create Docker secrets
echo -e "${YELLOW}Creating Docker secrets...${NC}"

# Remove existing secrets if they exist
for secret in traefik_passwd portainer-pass; do
    if docker secret ls | grep -q $secret; then
        echo -e "${YELLOW}Removing existing secret: $secret${NC}"
        docker secret rm $secret
    fi
done

# Create new secrets
cat /opt/docker/secrets/traefik_password | docker secret create traefik_passwd -
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create Traefik secret${NC}"
    exit 1
fi

cat /opt/docker/secrets/portainer_password | docker secret create portainer-pass -
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create Portainer secret${NC}"
    exit 1
fi

# Save passwords to a secure file for reference
echo -e "${YELLOW}Saving credentials to /opt/docker/secrets/credentials.txt${NC}"
echo "Traefik Dashboard:" > /opt/docker/secrets/credentials.txt
echo "Username: admin" >> /opt/docker/secrets/credentials.txt
echo "Password: $TRAEFIK_PASSWORD" >> /opt/docker/secrets/credentials.txt
echo "" >> /opt/docker/secrets/credentials.txt
echo "Portainer Initial Password:" >> /opt/docker/secrets/credentials.txt
cat /opt/docker/secrets/portainer_password >> /opt/docker/secrets/credentials.txt

# Set restrictive permissions on credentials file
chmod 600 /opt/docker/secrets/credentials.txt

echo -e "\n${GREEN}Secrets generated successfully!${NC}"
echo -e "${YELLOW}Credentials have been saved to: /opt/docker/secrets/credentials.txt${NC}"
echo -e "${YELLOW}Please save these credentials securely and then delete the credentials.txt file${NC}"

# Verify secrets
echo -e "\n${YELLOW}Verifying Docker secrets:${NC}"
docker secret ls

echo -e "\n${GREEN}You can now proceed with deploying the stacks${NC}"
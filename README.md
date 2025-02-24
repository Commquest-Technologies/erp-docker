# ERP Docker Infrastructure

This repository contains Docker Swarm configurations for deploying Traefik, Portainer, MariaDB, and ERPNext in a production environment.

## Prerequisites

- Ubuntu 24.04 or later
- Docker Swarm initialized
- Domain name with ability to add DNS records
- Git installed

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/erp-docker.git
cd erp-docker
```

2. Copy and configure environment file:
```bash
cp compose/.env.example .env
nano .env
```

3. Run the setup scripts:
```bash
chmod +x scripts/*.sh
./scripts/setup.sh
./scripts/generate-secrets.sh
./scripts/deploy.sh
```

## Directory Structure

- `compose/` - Docker compose files
- `scripts/` - Setup and deployment scripts
- `secrets/` - Directory for storing secrets (not committed to git)

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and update the following:

- `TRAEFIK_DOMAIN` - Domain for Traefik dashboard
- `PORTAINER_DOMAIN` - Domain for Portainer
- `EMAIL` - Email for Let's Encrypt certificates
- `TZ` - Timezone (default: Africa/Johannesburg)

### Secrets

Secrets are automatically generated and stored in `/opt/docker/secrets/`:
- `traefik_password` - Traefik dashboard login
- `portainer_password` - Portainer initial admin password

## Post-Installation

1. Configure DNS records for your domains
2. Access Traefik dashboard: https://traefik.yourdomain.com
3. Access Portainer: https://portainer.yourdomain.com

## Security

- All passwords are stored as Docker secrets
- HTTPS is enforced with automatic Let's Encrypt certificates
- Regular security updates are recommended

## Maintenance

### Password Rotation
```bash
./scripts/generate-secrets.sh
```

### Updates
```bash
git pull
./scripts/deploy.sh
```

## Support

For issues and feature requests, please use the GitHub issue tracker.

## License

MIT License - see LICENSE file for details
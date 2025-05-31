#!/bin/bash

# Script to set up the AI macOS Agent with Open-WebUI and Portainer
# This script orchestrates the entire setup process

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found"
  echo "Please copy .env.example to .env and edit it with your settings"
  exit 1
fi

# Base directory
BASE_DIR="$(pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}    AI macOS Agent - Setup Script    ${NC}"
echo -e "${BLUE}  with Open-WebUI and Portainer       ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check if Docker/Orbstack is installed
if ! command -v docker &> /dev/null; then
    echo "Docker/Orbstack is not installed or not in PATH"
    echo "Please install Docker or Orbstack first"
    exit 1
fi

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "mkcert is not installed"
    echo "Please install mkcert first: brew install mkcert"
    exit 1
fi

# Check if Ollama is running
if ! curl -s "http://localhost:${OLLAMA_PORT}/api/tags" &> /dev/null; then
    echo "Ollama is not running on port ${OLLAMA_PORT}"
    echo "Please start Ollama first"
    exit 1
fi

echo -e "${GREEN}All prerequisites are met!${NC}"
echo ""

# Display /etc/hosts requirement
echo -e "${YELLOW}Important: Please add these lines to your /etc/hosts file:${NC}"
echo -e "${BLUE}127.0.0.1   home.arpa${NC}"
echo -e "${BLUE}127.0.0.1   luma.home.arpa${NC}"
echo -e "${BLUE}127.0.0.1   n8n.home.arpa${NC}"
echo -e "${BLUE}127.0.0.1   agent.home.arpa${NC}"
echo -e "${BLUE}127.0.0.1   traefik.home.arpa${NC}"
echo -e "${BLUE}127.0.0.1   chat.home.arpa${NC}"
echo -e "${BLUE}127.0.0.1   portainer.home.arpa${NC}"
echo ""
echo -e "You can do this by running:"
echo -e "${GREEN}sudo nano /etc/hosts${NC}"
echo ""
read -p "Press Enter to continue after updating /etc/hosts..."

# Create directory structure
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p "$BASE_DIR/config/traefik/dynamic"
mkdir -p "$BASE_DIR/config/traefik/certs"
mkdir -p "$BASE_DIR/data/astroluma"
mkdir -p "$BASE_DIR/data/n8n"
mkdir -p "$BASE_DIR/data/postgres"
mkdir -p "$BASE_DIR/data/agent-zero"
mkdir -p "$BASE_DIR/data/open-webui"
mkdir -p "$BASE_DIR/data/portainer"
mkdir -p "$BASE_DIR/shared/documents"
mkdir -p "$BASE_DIR/shared/data"

echo -e "${GREEN}Directory structure created!${NC}"
echo ""

# Create Docker network
echo -e "${YELLOW}Creating Docker network...${NC}"
if ! docker network ls | grep -q "traefik_network"; then
    docker network create traefik_network
    echo -e "${GREEN}Docker network 'traefik_network' created!${NC}"
else
    echo -e "${GREEN}Docker network 'traefik_network' already exists!${NC}"
fi
echo ""

# Fix SSL certificates for Safari
echo -e "${YELLOW}Setting up SSL certificates for Safari compatibility...${NC}"
echo "This will ensure certificates are properly trusted by Safari"

# Reinstall mkcert CA
mkcert -install

# Get the mkcert CA location
CA_PATH=$(mkcert -CAROOT)
echo "CA Root directory: $CA_PATH"

# Import the CA into the System keychain
echo "Importing CA into System keychain..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CA_PATH/rootCA.pem" 2>/dev/null || true

# Generate SSL certificates
mkdir -p "$BASE_DIR/config/traefik/certs"
cd "$BASE_DIR/config/traefik/certs"
mkcert "${DOMAIN}" "*.${DOMAIN}"

# Trust the specific certificate
echo "Adding certificate to System keychain..."
sudo security add-trusted-cert -d -r trustAsRoot -k /Library/Keychains/System.keychain "${DOMAIN}+1.pem" 2>/dev/null || true

cd "$BASE_DIR"
echo -e "${GREEN}SSL certificates configured for Safari!${NC}"
echo ""

# Configure Traefik (using existing config)
echo -e "${YELLOW}Traefik configuration already exists - keeping current setup${NC}"
echo ""

# Start services
echo -e "${YELLOW}Starting all services...${NC}"
echo "This may take a few minutes..."

cd "$BASE_DIR"
docker-compose -f docker-compose/traefik.yml --env-file .env up -d
docker-compose -f docker-compose/astroluma.yml --env-file .env up -d
docker-compose -f docker-compose/n8n.yml --env-file .env up -d
docker-compose -f docker-compose/agent-zero.yml --env-file .env up -d
docker-compose -f docker-compose/open-webui.yml --env-file .env up -d
docker-compose -f docker-compose/portainer.yml --env-file .env up -d

echo -e "${GREEN}All services started!${NC}"
echo ""

# Validate services
echo -e "${YELLOW}Validating services...${NC}"
echo "Please wait a moment for all services to initialize..."
sleep 20

# Check if containers are running
containers=("traefik" "astroluma" "n8n" "postgres" "agent-zero" "open-webui" "portainer")
failed_containers=0

for container in "${containers[@]}"; do
    echo -e "Checking container ${YELLOW}$container${NC}..."
    
    if docker ps | grep -q "$container"; then
        echo -e "${GREEN}✓ Container $container is running${NC}"
    else
        echo -e "${RED}✗ Container $container is not running${NC}"
        failed_containers=$((failed_containers+1))
    fi
done

# Final instructions
echo ""
echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}      Installation Complete!                       ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
echo -e "${GREEN}Your AI Workbench is ready! Access these services:${NC}"
echo ""
echo -e "🤖 ${YELLOW}AI Chat Interface:${NC}"
echo -e "   Open-WebUI: ${GREEN}https://chat.${DOMAIN}${NC}"
echo ""
echo -e "🔧 ${YELLOW}AI Tools & Automation:${NC}"
echo -e "   Agent Zero: ${GREEN}https://agent.${DOMAIN}${NC}"
echo -e "   n8n Workflows: ${GREEN}https://n8n.${DOMAIN}${NC}"
echo -e "   Astroluma: ${GREEN}https://luma.${DOMAIN}${NC}"
echo ""
echo -e "🐳 ${YELLOW}Container Management:${NC}"
echo -e "   Portainer: ${GREEN}https://portainer.${DOMAIN}${NC}"
echo -e "   Traefik Dashboard: ${GREEN}https://traefik.${DOMAIN}${NC}"
echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo -e "• Open-WebUI connects automatically to your local Ollama"
echo -e "• First login to Open-WebUI will create an admin account"
echo -e "• Portainer first setup requires creating an admin password"
echo -e "• All services share the /shared directory for file exchange"
echo ""
if [ $failed_containers -eq 0 ]; then
    echo -e "${GREEN}All containers are running successfully!${NC}"
else
    echo -e "${RED}Some containers failed to start. Check logs with:${NC}"
    echo -e "docker logs <container_name>"
fi
echo ""
echo -e "Thank you for using the AI macOS Agent!"
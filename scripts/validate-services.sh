#!/bin/bash

# Script to validate all services in the AI macOS Agent
# Updated to include Open-WebUI and Portainer

# Load environment variables
if [ -f ../.env ]; then
  source ../.env
else
  echo "Error: .env file not found"
  echo "Please copy .env.example to .env and edit it with your settings"
  exit 1
fi

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a URL is accessible
check_url() {
    local url=$1
    local name=$2
    echo -e "Testing ${YELLOW}$name${NC} at ${YELLOW}$url${NC}..."
    
    # Try to access the URL with curl
    if curl -s -k -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|301\|302"; then
        echo -e "${GREEN}✓ $name is accessible${NC}"
        return 0
    else
        echo -e "${RED}✗ $name is not accessible${NC}"
        return 1
    fi
}

# Function to check if a container is running
check_container() {
    local container=$1
    echo -e "Checking container ${YELLOW}$container${NC}..."
    
    if docker ps | grep -q "$container"; then
        echo -e "${GREEN}✓ Container $container is running${NC}"
        return 0
    else
        echo -e "${RED}✗ Container $container is not running${NC}"
        return 1
    fi
}

# Main validation process
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}    AI Workbench - Service Validation    ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if Docker/Orbstack is running
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker/Orbstack is not installed or not in PATH${NC}"
    exit 1
fi

# Check if the traefik network exists
if ! docker network ls | grep -q "traefik_network"; then
    echo -e "${RED}Traefik network does not exist. Please run setup script first.${NC}"
    exit 1
fi

# Check containers
containers=("traefik" "astroluma" "n8n" "postgres" "agent-zero" "open-webui" "portainer")
failed_containers=0

echo -e "${YELLOW}Checking all containers...${NC}"
for container in "${containers[@]}"; do
    if ! check_container "$container"; then
        failed_containers=$((failed_containers+1))
    fi
done
echo ""

# Check URLs
urls=(
    "https://chat.${DOMAIN}|Open-WebUI (AI Chat)"
    "https://portainer.${DOMAIN}|Portainer (Container Management)"
    "https://luma.${DOMAIN}|Astroluma Dashboard"
    "https://n8n.${DOMAIN}|n8n Workflow Automation"
    "https://agent.${DOMAIN}|Agent Zero"
    "https://traefik.${DOMAIN}|Traefik Dashboard"
)
failed_urls=0

echo -e "${YELLOW}Testing all service URLs...${NC}"
for url_pair in "${urls[@]}"; do
    IFS='|' read -r url name <<< "$url_pair"
    if ! check_url "$url" "$name"; then
        failed_urls=$((failed_urls+1))
    fi
done
echo ""

# Check Ollama connection
echo -e "${YELLOW}Testing backend services...${NC}"
echo -e "Testing ${YELLOW}Ollama connection${NC}..."
if curl -s "http://localhost:${OLLAMA_PORT}/api/tags" | grep -q "models"; then
    echo -e "${GREEN}✓ Ollama API is accessible${NC}"
else
    echo -e "${RED}✗ Ollama API is not accessible${NC}"
    failed_urls=$((failed_urls+1))
fi

# Check shared volumes
echo -e "Checking ${YELLOW}shared volumes${NC}..."
BASE_DIR="$(cd .. && pwd)"
if [ -d "$BASE_DIR/shared" ]; then
    echo -e "${GREEN}✓ Shared volumes directory exists${NC}"
else
    echo -e "${RED}✗ Shared volumes directory does not exist${NC}"
    failed_urls=$((failed_urls+1))
fi
echo ""

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}           Validation Summary             ${NC}"
echo -e "${BLUE}=========================================${NC}"

if [ $failed_containers -eq 0 ] && [ $failed_urls -eq 0 ]; then
    echo -e "${GREEN}🎉 All services are running correctly!${NC}"
    echo ""
    echo -e "${GREEN}Your AI Workbench is fully operational:${NC}"
    echo ""
    echo -e "🤖 ${YELLOW}AI Chat Interface:${NC}"
    echo -e "   Open-WebUI: ${GREEN}https://chat.${DOMAIN}${NC}"
    echo ""
    echo -e "🔧 ${YELLOW}AI Tools & Automation:${NC}"
    echo -e "   Agent Zero: ${GREEN}https://agent.${DOMAIN}${NC}"
    echo -e "   n8n Workflows: ${GREEN}https://n8n.${DOMAIN}${NC}"
    echo -e "   Astroluma: ${GREEN}https://luma.${DOMAIN}${NC}"
    echo ""
    echo -e "🐳 ${YELLOW}Management Interfaces:${NC}"
    echo -e "   Portainer: ${GREEN}https://portainer.${DOMAIN}${NC}"
    echo -e "   Traefik Dashboard: ${GREEN}https://traefik.${DOMAIN}${NC}"
else
    echo -e "${RED}⚠️  Some services are not running correctly.${NC}"
    echo ""
    echo -e "${RED}Issues found:${NC}"
    echo -e "• Failed containers: $failed_containers"
    echo -e "• Failed URLs: $failed_urls"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "• Check container logs: ${GREEN}docker logs <container_name>${NC}"
    echo -e "• Restart services: ${GREEN}docker-compose restart${NC}"
    echo -e "• Check /etc/hosts entries for *.home.arpa domains"
    echo -e "• Verify SSL certificates are trusted in keychain"
fi
echo ""
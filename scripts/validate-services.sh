#!/bin/bash

# Script to validate all services in the AI macOS Agent
# This script checks if all services are running correctly

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
echo "Starting validation of all services..."
echo "======================================="

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
containers=("traefik" "astroluma" "n8n" "postgres" "agent-zero")
failed_containers=0

for container in "${containers[@]}"; do
    if ! check_container "$container"; then
        failed_containers=$((failed_containers+1))
    fi
done

# Check URLs
urls=(
    "https://dashboard.${DOMAIN}|Astroluma Dashboard"
    "https://n8n.${DOMAIN}|n8n Workflow Automation"
    "https://agent.${DOMAIN}|Agent Zero"
    "https://traefik.${DOMAIN}|Traefik Dashboard"
)
failed_urls=0

for url_pair in "${urls[@]}"; do
    IFS='|' read -r url name <<< "$url_pair"
    if ! check_url "$url" "$name"; then
        failed_urls=$((failed_urls+1))
    fi
done

# Check Ollama connection
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

# Summary
echo ""
echo "======================================="
echo "Validation Summary:"
echo "======================================="

if [ $failed_containers -eq 0 ] && [ $failed_urls -eq 0 ]; then
    echo -e "${GREEN}All services are running correctly!${NC}"
    echo ""
    echo "You can access the services at:"
    echo "- Astroluma Dashboard: https://dashboard.${DOMAIN}"
    echo "- n8n Workflow Automation: https://n8n.${DOMAIN}"
    echo "- Agent Zero: https://agent.${DOMAIN}"
    echo "- Traefik Dashboard: https://traefik.${DOMAIN}"
else
    echo -e "${RED}Some services are not running correctly.${NC}"
    echo "Failed containers: $failed_containers"
    echo "Failed URLs: $failed_urls"
    echo ""
    echo "Please check the logs for more information:"
    echo "docker logs traefik"
    echo "docker logs astroluma"
    echo "docker logs n8n"
    echo "docker logs agent-zero"
fi

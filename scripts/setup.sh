#!/bin/bash

# Script to set up the AI macOS Agent
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
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}      Self-Hosted > AI macOS Agent - Setup Script       ${NC}"
echo -e "${BLUE}====================================================${NC}"
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
    echo "Please start Ollama first: ollama serve"
    exit 1
fi

echo -e "${GREEN}All prerequisites are met!${NC}"
echo ""

# Create directory structure
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p "$BASE_DIR/config/traefik/dynamic"
mkdir -p "$BASE_DIR/config/traefik/certs"
mkdir -p "$BASE_DIR/data/astroluma"
mkdir -p "$BASE_DIR/data/n8n"
mkdir -p "$BASE_DIR/data/postgres"
mkdir -p "$BASE_DIR/data/agent-zero"
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

# Generate SSL certificates
echo -e "${YELLOW}Generating SSL certificates...${NC}"
mkdir -p "$BASE_DIR/config/traefik/certs"
cd "$BASE_DIR/config/traefik/certs"
mkcert -install
mkcert "${DOMAIN}" "*.${DOMAIN}"
cd "$BASE_DIR"
echo -e "${GREEN}SSL certificates generated!${NC}"
echo ""

# Configure Traefik
echo -e "${YELLOW}Configuring Traefik...${NC}"
cat > "$BASE_DIR/config/traefik/traefik.yml" << EOF
# Traefik Static Configuration
api:
  dashboard: true
  insecure: false

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    directory: "/etc/traefik/dynamic"
    watch: true

log:
  level: "INFO"

accessLog: {}
EOF

cat > "$BASE_DIR/config/traefik/dynamic/tls.yml" << EOF
tls:
  certificates:
    - certFile: "/certs/${DOMAIN}+1.pem"
      keyFile: "/certs/${DOMAIN}+1-key.pem"
  stores:
    default:
      defaultCertificate:
        certFile: "/certs/${DOMAIN}+1.pem"
        keyFile: "/certs/${DOMAIN}+1-key.pem"
EOF

echo -e "${GREEN}Traefik configured!${NC}"
echo ""

# Start services
echo -e "${YELLOW}Starting services...${NC}"
echo "This may take a few minutes..."

cd "$BASE_DIR"
docker-compose -f docker-compose/traefik.yml up -d
docker-compose -f docker-compose/astroluma.yml up -d
docker-compose -f docker-compose/n8n.yml up -d
docker-compose -f docker-compose/agent-zero.yml up -d

echo -e "${GREEN}All services started!${NC}"
echo ""

# Validate services
echo -e "${YELLOW}Validating services...${NC}"
echo "Please wait a moment for all services to initialize..."
sleep 10

# Check if containers are running
containers=("traefik" "astroluma" "n8n" "postgres" "agent-zero")
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
    echo -e "Testing ${YELLOW}$name${NC} at ${YELLOW}$url${NC}..."
    
    # Try to access the URL with curl
    if curl -s -k -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|301\|302"; then
        echo -e "${GREEN}✓ $name is accessible${NC}"
    else
        echo -e "${RED}✗ $name is not accessible${NC}"
        failed_urls=$((failed_urls+1))
    fi
done

echo ""

# Final instructions
echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}      Installation Complete!                       ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
echo -e "You can access the services at:"
echo -e "- Astroluma Dashboard: ${GREEN}https://dashboard.${DOMAIN}${NC}"
echo -e "- n8n Workflow Automation: ${GREEN}https://n8n.${DOMAIN}${NC}"
echo -e "- Agent Zero: ${GREEN}https://agent.${DOMAIN}${NC}"
echo -e "- Traefik Dashboard: ${GREEN}https://traefik.${DOMAIN}${NC}"
echo ""
echo -e "Please refer to the user guide for detailed instructions:"
echo -e "${GREEN}$BASE_DIR/docs/user_guide.md${NC}"
echo ""
echo -e "Thank you for using the Self-Hosted AI Toolkit!"

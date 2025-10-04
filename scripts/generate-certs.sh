#!/bin/bash

# Script to generate SSL certificates for local domains using mkcert
# This script should be run on the host machine, not in a container

# Load environment variables
set -a
source ./.env
set +a

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "mkcert is not installed. Please install it first:"
    echo "brew install mkcert"
    exit 1
fi

# Create certificates directory if it doesn't exist
CERT_DIR="./config/traefik/certs"
mkdir -p "$CERT_DIR"

# Build the domain list from environment variables
DOMAINS=(
    "${AGENT_SUBDOMAIN}.${DOMAIN}"
    "${CHAT_SUBDOMAIN}.${DOMAIN}"
    "${LUMA_SUBDOMAIN}.${DOMAIN}"
    "${N8N_SUBDOMAIN}.${DOMAIN}"
    "${PORTAINER_SUBDOMAIN}.${DOMAIN}"
    "${TRAEFIK_SUBDOMAIN}.${DOMAIN}"
)

# Change to certificates directory
cd "$CERT_DIR"

# Generate certificates for all domains
echo "Generating certificates for domains: ${DOMAINS[*]}"
mkcert "${DOMAINS[@]}"

# Update Traefik TLS configuration
cat > ./config/traefik/dynamic/tls.yml << EOF
tls:
  certificates:
    - certFile: "/certs/${DOMAINS[0]}+$(( ${#DOMAINS[@]} - 1 )).pem"
      keyFile: "/certs/${DOMAINS[0]}+$(( ${#DOMAINS[@]} - 1 ))-key.pem"
  stores:
    default:
      defaultCertificate:
        certFile: "/certs/${DOMAINS[0]}+$(( ${#DOMAINS[@]} - 1 )).pem"
        keyFile: "/certs/${DOMAINS[0]}+$(( ${#DOMAINS[@]} - 1 ))-key.pem"
EOF

echo "Certificates generated and Traefik configuration updated"
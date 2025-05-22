#!/bin/bash

# Script to generate SSL certificates for local domains using mkcert
# This script should be run on the host machine, not in a container

# Load environment variables
if [ -f ../.env ]; then
  source ../.env
else
  echo "Error: .env file not found"
  echo "Please copy .env.example to .env and edit it with your settings"
  exit 1
fi

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "mkcert is not installed. Please install it first:"
    echo "brew install mkcert"
    exit 1
fi

# Create certificates directory if it doesn't exist
CERT_DIR="../config/traefik/certs"
mkdir -p "$CERT_DIR"

# Change to the certificates directory
cd "$CERT_DIR"

# Generate certificates for domain and all subdomains
echo "Generating certificates for ${DOMAIN} and *.${DOMAIN}..."
mkcert -install
mkcert "${DOMAIN}" "*.${DOMAIN}"

# Verify certificates were created
if [ -f "${DOMAIN}+1.pem" ] && [ -f "${DOMAIN}+1-key.pem" ]; then
    echo "Certificates successfully generated at:"
    echo "$CERT_DIR/${DOMAIN}+1.pem"
    echo "$CERT_DIR/${DOMAIN}+1-key.pem"
else
    echo "Certificate generation failed!"
    exit 1
fi

echo "SSL certificate setup complete!"

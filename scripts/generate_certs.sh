#!/bin/bash

# Script to generate SSL certificates for local domains using mkcert
# This script should be run on the host machine, not in a container

# Check if mkcert is installed
if ! command -v mkcert &> /dev/null; then
    echo "mkcert is not installed. Please install it first:"
    echo "brew install mkcert"
    exit 1
fi

# Create certificates directory if it doesn't exist
CERT_DIR="$(pwd)/traefik/certs"
mkdir -p "$CERT_DIR"

# Change to the certificates directory
cd "$CERT_DIR"

# Generate certificates for mac.local and all subdomains
echo "Generating certificates for mac.local and *.mac.local..."
mkcert -install
mkcert mac.local "*.mac.local"

# Verify certificates were created
if [ -f "mac.local+1.pem" ] && [ -f "mac.local+1-key.pem" ]; then
    echo "Certificates successfully generated at:"
    echo "$CERT_DIR/mac.local+1.pem"
    echo "$CERT_DIR/mac.local+1-key.pem"
else
    echo "Certificate generation failed!"
    exit 1
fi

echo "SSL certificate setup complete!"

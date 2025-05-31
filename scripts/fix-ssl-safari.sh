#!/bin/bash

# Script to fix SSL certificate issues with Safari on macOS
# This ensures mkcert certificates are properly trusted

# Load environment variables
if [ -f ../.env ]; then
  source ../.env
else
  echo "Error: .env file not found"
  echo "Please copy .env.example to .env and edit it with your settings"
  exit 1
fi

echo "Fixing SSL certificate trust for Safari..."

# Reinstall mkcert CA
echo "Reinstalling mkcert CA..."
mkcert -install

# Get the mkcert CA location
CA_PATH=$(mkcert -CAROOT)
echo "CA Root directory: $CA_PATH"

# Import the CA into the System keychain
echo "Importing CA into System keychain..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CA_PATH/rootCA.pem"

# Import the CA into the user keychain  
echo "Importing CA into user keychain..."
security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/login.keychain "$CA_PATH/rootCA.pem"

# Clear certificate directory and regenerate
CERT_DIR="../config/traefik/certs"
echo "Regenerating certificates..."
rm -rf "$CERT_DIR"
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Generate new certificates
mkcert "${DOMAIN}" "*.${DOMAIN}"

# Verify certificates exist
if [ -f "${DOMAIN}+1.pem" ] && [ -f "${DOMAIN}+1-key.pem" ]; then
    echo "✓ Certificates regenerated successfully"
else
    echo "✗ Certificate generation failed!"
    exit 1
fi

# Trust the specific certificate
echo "Adding certificate to System keychain..."
sudo security add-trusted-cert -d -r trustAsRoot -k /Library/Keychains/System.keychain "${DOMAIN}+1.pem"

echo ""
echo "SSL certificate fix complete!"
echo ""
echo "Please:"
echo "1. Restart Safari completely"
echo "2. Clear Safari's cache (Cmd+Option+E)"
echo "3. Visit https://${DOMAIN} - it should now be trusted"
echo ""
echo "If you still see warnings, try:"
echo "- Keychain Access → Certificates → find '${DOMAIN}' → Get Info → Trust → Always Trust"
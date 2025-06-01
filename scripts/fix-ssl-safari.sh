#!/bin/bash

# Script to fix SSL certificate issues with Safari on macOS
# This ensures mkcert certificates are properly trusted

# Load environment variables
if [ -f ../.env ]; then
  set -a
  source ../.env
  set +a
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

# Build the domain list from environment variables
DOMAINS=(
    "${AGENT_SUBDOMAIN}.${DOMAIN}"
    "${CHAT_SUBDOMAIN}.${DOMAIN}"
    "${LUMA_SUBDOMAIN}.${DOMAIN}"
    "${N8N_SUBDOMAIN}.${DOMAIN}"
    "${PORTAINER_SUBDOMAIN}.${DOMAIN}"
    "${TRAEFIK_SUBDOMAIN}.${DOMAIN}"
)

# Generate certificates for all domains
echo "Generating certificates for domains: ${DOMAINS[*]}"
mkcert "${DOMAINS[@]}"

# Update Traefik TLS configuration
cat > ../dynamic/tls.yml << EOF
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

# Trust the specific certificate
echo "Adding certificates to System keychain..."
sudo security add-trusted-cert -d -r trustAsRoot -k /Library/Keychains/System.keychain "${DOMAINS[0]}+$(( ${#DOMAINS[@]} - 1 )).pem"

echo ""
echo "SSL certificate fix complete!"
echo ""
echo "Please:"
echo "1. Restart Safari completely"
echo "2. Clear Safari's cache (Cmd+Option+E)"
echo "3. Visit your domains:"
for domain in "${DOMAINS[@]}"; do
    echo "   - https://$domain"
done
echo ""
echo "If you still see warnings, try:"
echo "- Open Keychain Access"
echo "- Go to Certificates"
echo "- Find and select your certificates"
echo "- Get Info → Trust → Always Trust"
#!/bin/bash

# Script to set up shared volumes for local file access
# This script creates the necessary directory structure for shared data

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

# Base directory
BASE_DIR="$(cd .. && pwd)"

# Create shared directory structure
echo "Creating shared directory structure..."
mkdir -p "$BASE_DIR/shared/documents"
mkdir -p "$BASE_DIR/shared/data"

# Create specific data directories for each service
mkdir -p "$BASE_DIR/data/astroluma"
mkdir -p "$BASE_DIR/data/n8n"
mkdir -p "$BASE_DIR/data/postgres"
mkdir -p "$BASE_DIR/data/mongodb"
mkdir -p "$BASE_DIR/data/agent-zero"
mkdir -p "$BASE_DIR/data/open-webui"
mkdir -p "$BASE_DIR/data/portainer"

# Set appropriate permissions
echo "Setting permissions..."
chmod -R 755 "$BASE_DIR/shared"
chmod -R 755 "$BASE_DIR/data"

echo "Shared volumes setup complete!"
echo ""
echo "Service-specific data directories:"
echo "- Astroluma: $BASE_DIR/data/astroluma"
echo "- n8n: $BASE_DIR/data/n8n"
echo "- PostgreSQL: $BASE_DIR/data/postgres"
echo "- MongoDB: $BASE_DIR/data/mongodb"
echo "- Agent Zero: $BASE_DIR/data/agent-zero"
echo "- Open WebUI: $BASE_DIR/data/open-webui"
echo "- Portainer: $BASE_DIR/data/portainer"
echo ""
echo "Shared directories accessible to all services:"
echo "- Documents: $BASE_DIR/shared/documents"
echo "- Data: $BASE_DIR/shared/data"
echo ""
echo "These directories will be mounted in the containers as:"
echo "- n8n: /data/shared"
echo "- Agent Zero: /a0/shared"
echo "- Open WebUI: /data/shared"
echo "- Astroluma: /app/shared"

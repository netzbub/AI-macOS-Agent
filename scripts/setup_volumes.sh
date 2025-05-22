#!/bin/bash

# Script to set up shared volumes for local file access
# This script creates the necessary directory structure for shared data

# Base directory
BASE_DIR="$(pwd)"

# Create shared directory structure
echo "Creating shared directory structure..."
mkdir -p "$BASE_DIR/shared/documents"
mkdir -p "$BASE_DIR/shared/data"

# Create specific data directories for each service
mkdir -p "$BASE_DIR/agent-zero/data"
mkdir -p "$BASE_DIR/self-hosted-ai-starter-kit/data/n8n"
mkdir -p "$BASE_DIR/self-hosted-ai-starter-kit/data/postgres"
mkdir -p "$BASE_DIR/astroluma/data"
mkdir -p "$BASE_DIR/traefik/config/dynamic"

# Set appropriate permissions
echo "Setting permissions..."
chmod -R 755 "$BASE_DIR/shared"
chmod -R 755 "$BASE_DIR/agent-zero/data"
chmod -R 755 "$BASE_DIR/self-hosted-ai-starter-kit/data"
chmod -R 755 "$BASE_DIR/astroluma/data"

echo "Shared volumes setup complete!"
echo ""
echo "You can now place files in the following directories:"
echo "- $BASE_DIR/shared/documents: For documents accessible to all services"
echo "- $BASE_DIR/shared/data: For data files accessible to all services"
echo ""
echo "These directories will be mounted in the containers as:"
echo "- n8n: /data/shared"
echo "- Agent-Zero: /a0/shared"

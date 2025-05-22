#!/bin/bash

# Script to set up shared volumes for local file access
# This script creates the necessary directory structure for shared data

# Load environment variables
if [ -f ../.env ]; then
  source ../.env
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
mkdir -p "$BASE_DIR/data/agent-zero"

# Set appropriate permissions
echo "Setting permissions..."
chmod -R 755 "$BASE_DIR/shared"
chmod -R 755 "$BASE_DIR/data"

echo "Shared volumes setup complete!"
echo ""
echo "You can now place files in the following directories:"
echo "- $BASE_DIR/shared/documents: For documents accessible to all services"
echo "- $BASE_DIR/shared/data: For data files accessible to all services"
echo ""
echo "These directories will be mounted in the containers as:"
echo "- n8n: /data/shared"
echo "- Agent-Zero: /a0/shared"

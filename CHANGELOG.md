# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-05-21

### Added
- Initial release of AI macOS Agent
- Integration of n8n workflow automation with 400+ nodes
- Integration of Agent Zero AI assistant
- Astroluma dashboard for central service management
- Traefik reverse proxy with SSL certificate support
- Shared volume configuration for local file access
- Synology NAS backup solution optimized for limited resources
- Complete documentation and setup scripts

### Changed
- Consolidated environment variables into a single .env file
- Optimized container configurations for macOS

### Removed
- Removed redundant components (Supabase, Flowise, Qdrant) to reduce complexity

## [1.0.1] - 2025-05-25

### Added
- Added quote
- Added picture
- Added environment variables in the .env file

### Changed
- Changed local domain names
- Optimized TLS-Support
- Optimized container configurations for macOS
- Optimized astroluma.yml
- Shortened Code of Conduct
- Revised setup.sh, validate-services.sh and Readme.md7  V

## [1.0.2] - 2025-05-26

### Changed
- Edited .env.example
- Edited astroluma.yml
- Edited n8n.yml

## [1.0.3] - 2025-05-27

### Changed
- Edited .env.example - port conflicts
- Edited agent-zero.yml - port conflicts

## [1.0.6] - 2025-10-05

### Added
- Integration of Open WebUI for chat interface with Ollama models
- Integration of Prometheus for monitoring with Traefik metrics scraping
- Integration of Portainer for Docker container management
- Memory limits for all services to optimize resource usage
- Additional service configurations and environment variables

### Changed
- Updated setup.sh to include new services and validations
- Updated README.md with new services and URLs
- Updated docker-compose files with deploy limits and configurations
- Consolidated and cleaned up scripts (removed obsolete ones)
- Fixed Prometheus scraping configuration for SSL and scheme
- Updated /etc/hosts requirements for new domains

### Removed
- Obsolete scripts: generate-certs.sh, setup-volumes.sh, validate-services.sh, setup-n8n.sh
- Deprecated version fields in docker-compose files
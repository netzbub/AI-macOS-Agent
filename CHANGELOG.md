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
- Revised setup.sh, validate-services.sh and Readme.md

## [1.0.2] - 2025-05-26

### Changed
- Edited .env.example
- Edited astroluma.yml
- Edited n8n.yml

## [1.0.3] - 2025-05-27

### Changed
- Edited .env.example - port conflicts
- Edited agent-zero.yml - port conflicts

## [1.0.4] - 2025-05-31

### Added
- MongoDB integration for improved data persistence
- Prometheus metrics in Traefik
- JSON logging for better traceability
- Health check endpoints for all services
- Additional security settings in Traefik

### Changed
- Comprehensive revision of all scripts for better environment variable usage:
  - setup.sh: Improved service initialization
  - validate-services.sh: Enhanced validation checks
  - generate-certs.sh: Optimized SSL certificate generation
  - fix-ssl-safari.sh: Improved SSL compatibility
  - setup-n8n.sh: Enhanced Ollama integration
  - setup-volumes.sh: New service directories
  - backup-synology.sh: Improved backup configuration
- Updated Traefik configuration with:
  - Permanent HTTPS redirection
  - Wildcard certificates for subdomains
  - Enhanced TLS settings
  - Network isolation
- Optimized directory structure for all services
- Enhanced backup exclusions and configurable retention periods

### Security
- Strengthened TLS configuration
- Improved certificate management
- Network isolation for services
- Disabled unnecessary features
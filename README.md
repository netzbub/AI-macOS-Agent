# AI macOS Agent - V 1.0.5

A comprehensive toolkit for running AI services locally on macOS in a containerized environment, combining the power of n8n workflow automation, Agent Zero AI assitant and Ollama running different LLMs inside Open WebUI.

## *"Good artists copy, great artists steal."*  
(Pablo Picasso)  

![Feininger](https://github.com/netzbub/AI-macOS-Agent/blob/main/docs/images/feininger.jpg)  
Lyonel Feininger

### Table of Contents
- [AI macOS Agent](#ai-macos-agent)
  - [*"Good artists copy, great artists steal."*](#good-artists-copy-great-artists-steal)
    - [Table of Contents](#table-of-contents)
    - [Inspiration](#inspiration)
    - [Overview](#overview)
    - [Features](#features)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Configuration](#configuration)
    - [Directory Structure](#directory-structure)
    - [Usage](#usage)
    - [Accessing Services](#accessing-services)
    - [Working with Local Files](#working-with-local-files)
    - [Backup to Synology NAS](#backup-to-synology-nas)
    - [Maintenance](#maintenance)
    - [Updating Services](#updating-services)
    - [Checking Logs](#checking-logs)
    - [License](#license)
    - [Acknowledgments](#acknowledgments)
    
### Inspiration

The following repositories inspired me to build my own local **AI macOS Agent** - up to now a first sketch on the wall and it will have to be improved over time.

- [Original Local AI Starter Kit](https://github.com/n8n-io/self-hosted-ai-starter-kit) by the n8n team
- [Original self-hosted-ai-starter-kit-3](https://github.com/tuyenhm68/self-hosted-ai-starter-kit-3) by tuyenhm68
- [Original agent-zero](https://github.com/frdel/agent-zero) by Jan Tomášek and his contributors

### Overview

This project integrates three powerful AI frameworks:
- **n8n**: Workflow automation with 400+ integrations and AI components
- **Agent Zero**: AI agents with terminal and web interfaces
- **Open WebUI**: as frontend for **Ollama** and various locally hosted LLMs

All services are accessible through a central Astroluma dashboard and secured with local SSL certificates.

### Features

- **Central Dashboard**: Astroluma for managing all services
- **Workflow Automation**: n8n with 400+ integrations and AI components
- **AI Agents**: Agent Zero for terminal and web-based AI assistance
- **Local LLM Integration**: Direct connection to locally installed Ollama
- **Open WebUI**: Use different LLMs in your browser, free and privacy-focused
- **SSL Security**: Local domains secured with mkcert certificates
- **Reverse Proxy**: Traefik for routing and SSL termination with enhanced security
- **Monitoring**: Prometheus metrics and JSON logging
- **Backup Solution**: Optimized for Synology NAS with configurable retention

### Prerequisites

- macOS (tested on macOS 15.5)
- [Homebrew](https://brew.sh/)
- [Docker/Orbstack](https://orbstack.dev/)
- [Ollama](https://ollama.ai/) - installed locally
- [mkcert](https://github.com/FiloSottile/mkcert)

**Be very (!) careful** with choosing a TLD for your local network. The most recommended two ways, that will not conflict with existing local or public domains and with public DNS, are either to use [.home.arpa](https://home.arpa). The second recommended way is to use a subdomain of a domain, that you 'own' like [sub.mydomain.com](https://sub.mydomain.com). Be aware, that mkcert only supports sub.mydomain.com but will not work with next.sub.mydomain.com.

Add to /etc/hosts:
```bash
127.0.0.1   ${DOMAIN}
127.0.0.1   ${LUMA_SUBDOMAIN}.${DOMAIN}
127.0.0.1   ${N8N_SUBDOMAIN}.${DOMAIN}
127.0.0.1   ${AGENT_SUBDOMAIN}.${DOMAIN}
127.0.0.1   ${TRAEFIK_SUBDOMAIN}.${DOMAIN}
127.0.0.1   ${CHAT_SUBDOMAIN}.${DOMAIN}
127.0.0.1   ${PORTAINER_SUBDOMAIN}.${DOMAIN}
```

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/netzbub/ai-macos-agent.git
   cd ai-macos-agent
   ```

2. Copy and configure environment file:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. Making the scripts executable:
   ```bash
   chmod +x scripts/setup.sh
   chmod +x ./scripts/generate-certs.sh
   ```

3. Run the setup script:
   ```bash
   ./scripts/setup.sh
   ```

   
### Configuration

Key settings in `.env`:

```bash
# Domain Configuration
DOMAIN=your.domain
LUMA_SUBDOMAIN=luma
N8N_SUBDOMAIN=n8n
AGENT_SUBDOMAIN=agent
TRAEFIK_SUBDOMAIN=traefik
CHAT_SUBDOMAIN=chat
PORTAINER_SUBDOMAIN=portainer

# Network Settings
TRAEFIK_NETWORK=traefik_network

# Service Ports
N8N_PORT=5678
ASTROLUMA_PORT=8000
AGENT_ZERO_PORT=80
TRAEFIK_PORT=8080
MONGODB_PORT=27017

# Ollama Integration
OLLAMA_HOST=host.docker.internal
OLLAMA_PORT=11434
OLLAMA_MODEL=llama2

# Memory Limits
N8N_MEMORY_LIMIT=8G
AGENT_MEMORY_LIMIT=8G
ASTROLUMA_MEMORY_LIMIT=2G
MONGODB_MEMORY_LIMIT=4G

# Backup Configuration
BACKUP_KEEP_DAILY=7
BACKUP_KEEP_WEEKLY=4
BACKUP_KEEP_MONTHLY=6
```

### Directory Structure

```
.
├── config/
│   └── traefik/
│       ├── dynamic/
│       ├── certs/
│       └── traefik.yml
├── data/
│   ├── agent-zero/
│   ├── astroluma/
│   ├── mongodb/
│   ├── n8n/
│   ├── open-webui/
│   ├── portainer/
│   └── postgres/
├── docker-compose/
│   ├── agent-zero.yml
│   ├── astroluma.yml
│   ├── n8n.yml
│   ├── open-webui.yml
│   ├── portainer.yml
│   └── traefik.yml
├── scripts/
│   ├── backup-synology.sh
│   ├── fix-ssl-safari.sh
│   ├── generate-certs.sh
│   ├── setup-n8n.sh
│   ├── setup-volumes.sh
│   ├── setup.sh
│   └── validate-services.sh
└── shared/
    ├── data/
    └── documents/
```

### Usage

### Accessing Services

All services are accessible through your browser using the following URLs:

- **Agent Zero**: https://agent.home.arpa
- **n8n Workflow Automation**: https://n8n.home.arpa
- **Open WebUI (Ollama)** - https://chat.home.arpa
- **Astroluma** - https://luma.home.arpa
- **Portainer** - https://portainer.home.arpa
- **Traefik Dashboard**: https://traefik.home.arpa


### Working with Local Files

Place files you want to access from the services in the `shared` directory:
- Files will be available in n8n at `/data/shared`
- Files will be available in Agent Zero at `/a0/shared`

### Backup to Synology NAS

Configure the backup script with your Synology details:
```bash
nano scripts/backup-synology.sh
# Update NAS_USER, NAS_IP, and other parameters
```

Run the backup manually or set up a cron job:
```bash
chmod +x scripts/backup-synology.sh
./scripts/backup-synology.sh
```

### Maintenance

### Updating Services

```bash
cd docker-compose
docker-compose -f agent-zero.yml -f astroluma.yml -f n8n.yml -f open.webui -f portainer -f traefik.yml pull
docker-compose -f agent-zero.yml -f astroluma.yml -f n8n.yml -f open.webui -f portainer -f traefik.yml up -d
```

### Checking Logs

```bash
docker logs agent-zero
docker logs astroluma
docker logs n8n
docker logs open-webui
docker logs portainer
docker logs traefik
```

### License

This project combines components with different licenses:
- n8n starter kit: [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
- Agent Zero: [MIT License](https://opensource.org/licenses/MIT)
- Open WebUI: [Open WebUI License](https://github.com/open-webui/open-webui/blob/main/LICENSE)

The integration code in this repository is licensed under the MIT License.

### Acknowledgments

- [Agent Zero](https://github.com/frdel/agent-zero)
- [Astroluma](https://github.com/astroluma/astroluma)
- [n8n Self-hosted AI Starter Kit 3](https://github.com/tuyenhm68/self-hosted-ai-starter-kit-3)
- [Ollama](https://ollama.ai/)
- [Portainer](https://www.portainer.io)
- [Traefik](https://traefik.io/)

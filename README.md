# AI macOS Agent

A comprehensive toolkit for running AI services locally on macOS in  a containerized environment, combining the power of n8n workflow automation and Agent Zero AI assistants.

### Good artists copy, great artists steal.  
Pablo Picasso

#### Important Links

The following repositories inspired me to build my own local **AI macOS Agent** - up to now a first sketch on the wall and it will have to be improved over time.

- [Original Local AI Starter Kit](https://github.com/n8n-io/self-hosted-ai-starter-kit) by the n8n team
- [Original self-hosted-ai-starter-kit-3](https://github.com/tuyenhm68/self-hosted-ai-starter-kit-3) by tuyenhm68
- [Original agent-zero](https://github.com/frdel/agent-zero) by Jan Tomášek and his contributors

## About me

I am definitely not someone, who's core competence is coding.

But I would like to have much more of these skills, be it in the zsh shell or be it with docker compose, Ansible or whatever helps me to set up my own server or like now setting up different local AI services, starting with 'simple' Ollama installation + some LLMs in the background. 

But because of the limitations of these local LLMs by their *knowledge cutoff* and not being able of having researches on the web nor being able to analyze and make use of my private or business files, I was looking for possibilities to get beyond these limitations.

The installation scripts and docker-compose files are based on the before mentioned and linked projects and then in close cooperation created with awesome help of

- [manus.im](https://manus.im)

I am deeply thankful to the creators and contributors of the above mentioned repositories and as well to the creators of manus.im.

If there is something wrong with my use of your code or the licenses - please get in contact with me and let me know.


## Overview

This project integrates two powerful AI frameworks:
- **Self-hosted AI Starter Kit 3**: Provides n8n workflow automation with 400+ integrations and AI components
- **Agent Zero**: Offers AI agents with terminal and web interfaces

All services are accessible through a central Astroluma dashboard and secured with local SSL certificates.

## Features

- **Central Dashboard**: Astroluma for managing all services
- **Workflow Automation**: n8n with 400+ integrations and AI components
- **AI Agents**: Agent Zero for terminal and web-based AI assistance
- **Local LLM Integration**: Direct connection to locally installed Ollama
- **SSL Security**: Local domains secured with mkcert certificates
- **Reverse Proxy**: Traefik for routing and SSL termination
- **Backup Solution**: Optimized for Synology NAS with limited resources

## Prerequisites

- macOS (tested on macOS 15.5)
- [Homebrew](https://brew.sh/)
- [Docker/Orbstack](https://orbstack.dev/)
- [Ollama](https://ollama.ai/) (installed locally, not in container)
- [mkcert](https://github.com/FiloSottile/mkcert) (`brew install mkcert`)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/self-hosted-ai-toolkit.git
   cd self-hosted-ai-toolkit
   ```

2. Copy the example environment file and edit it:
   ```bash
   cp .env.example .env
   # Edit .env with your preferred settings
   ```

3. Run the setup script:
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

4. Access the services:
   - Dashboard: https://dashboard.mac.local
   - n8n: https://n8n.mac.local
   - Agent Zero: https://agent.mac.local
   - Traefik: https://traefik.mac.local

## Configuration

The central `.env` file contains all configuration options:

```
# General Settings
DOMAIN=mac.local

# n8n Settings
N8N_ENCRYPTION_KEY=your-encryption-key
POSTGRES_PASSWORD=your-postgres-password

# Ollama Integration
OLLAMA_HOST=host.docker.internal
OLLAMA_PORT=11434
```

## Directory Structure

```
├── config/
│   ├── traefik/
│   │   ├── traefik.yml
│   │   └── dynamic/
│   │       └── tls.yml
├── docker-compose/
│   ├── traefik.yml
│   ├── astroluma.yml
│   ├── n8n.yml
│   └── agent-zero.yml
├── docs/
│   └── user_guide.md
└── scripts/
    ├── setup.sh
    ├── generate-certs.sh
    ├── setup-volumes.sh
    ├── validate-services.sh
    └── backup-synology.sh
```

## Usage

### Accessing Services

All services are accessible through your browser using the following URLs:
- **Astroluma Dashboard**: https://dashboard.mac.local
- **n8n Workflow Automation**: https://n8n.mac.local
- **Agent Zero**: https://agent.mac.local
- **Traefik Dashboard**: https://traefik.mac.local

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

## Maintenance

### Updating Services

```bash
cd docker-compose
docker-compose -f traefik.yml -f astroluma.yml -f n8n.yml -f agent-zero.yml pull
docker-compose -f traefik.yml -f astroluma.yml -f n8n.yml -f agent-zero.yml up -d
```

### Checking Logs

```bash
docker logs traefik
docker logs astroluma
docker logs n8n
docker logs agent-zero
```

## Troubleshooting

See the [User Guide](docs/user_guide.md) for detailed troubleshooting steps.

## License

This project combines components with different licenses:
- n8n starter kit: [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
- Agent Zero: [MIT License](https://opensource.org/licenses/MIT)

The integration code in this repository is licensed under the MIT License.

## Acknowledgments

- [n8n Self-hosted AI Starter Kit 3](https://github.com/tuyenhm68/self-hosted-ai-starter-kit-3)
- [Agent Zero](https://github.com/frdel/agent-zero)
- [Astroluma](https://github.com/astroluma/astroluma)
- [Traefik](https://traefik.io/)
- [Ollama](https://ollama.ai/)

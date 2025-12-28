# Raspberry Pi 5 Home Lab

Complete self-hosted homelab setup with AI, cloud storage, monitoring, and smart home integration.

## 🌐 Access

**Local Network:** `http://YOUR_LOCAL_IP`  
**Tailscale VPN:** `http://YOUR_TAILSCALE_IP`  
**Tailscale Hostname:** `http://hostname.YOUR_TAILNET.ts.net`

> use ip on deployment

---

## 📋 Services

### 🎯 Main Dashboard
- **Homarr**: Port 7777
  - Auto-discovering dashboard for all services
  - Start here for quick access to everything

### 🤖 AI & Productivity
- **Open WebUI**: Port 3002
  - Chat with Claude Sonnet 4.5, GPT-4, and other models via LiteLLM proxy
  - Supports multiple AI providers (Anthropic, OpenAI, etc.)
- **Nextcloud**: Port 8091
  - Personal cloud storage, file sharing, calendar, contacts
  - PostgreSQL backend for performance
- **Vaultwarden**: Port 8090
  - Self-hosted password manager (Bitwarden-compatible)
  - Encrypted vault storage
- **Excalidraw**: Port 8088
  - Collaborative whiteboard for diagrams

### 🏠 Smart Home & Network
- **Home Assistant**: Port 8123
  - Smart home automation and control hub
  - Local control, no cloud dependencies
- **Pi-hole**: Port 8053 (web), Port 53 (DNS)
  - Network-wide ad blocking and DNS server
  - Blocks ads across all devices on network

### 📊 Monitoring & Management
- **Portainer**: Port 9000
  - Docker container management with web UI
  - Easy container orchestration
- **Grafana**: Port 3000
  - Metrics visualization and custom dashboards
  - Integrated with Prometheus
- **Uptime Kuma**: Port 3001
  - Beautiful uptime monitoring
  - Status page for all services
- **Prometheus**: Port 9090
  - Time-series metrics database
  - Scrapes metrics from all services
- **cAdvisor**: Port 8082
  - Real-time container resource usage
  - CPU, memory, network stats per container
- **Node Exporter**: Port 9100
  - System-level metrics for Prometheus

### 🔧 Utilities
- **IT-Tools**: Port 8081
  - Collection of developer utilities (base64, JSON formatter, etc.)

### 🔄 Backend Services (No Web UI)
- **LiteLLM** - Multi-provider AI model proxy with unified API
- **PostgreSQL** - Relational database for Nextcloud and other services
- **Watchtower** - Auto-updates Docker containers daily
- **Redis** - In-memory cache for Outline (when enabled)

---

## 🔌 Port Reference

| Service | Port | Type | Purpose |
|---------|------|------|---------|
| **SSH** | 22 | TCP | Remote shell access |
| **DNS** | 53 | TCP/UDP | Pi-hole DNS server |
| **Grafana** | 3000 | TCP | Monitoring dashboards |
| **Uptime Kuma** | 3001 | TCP | Service uptime monitoring |
| **Open WebUI** | 3002 | TCP | AI chat interface |
| **LiteLLM** | 4000 | TCP | AI proxy (internal only) |
| **PostgreSQL** | 5432 | TCP | Database (internal only) |
| **Homarr** | 7777 | TCP | Main dashboard |
| **IT-Tools** | 8081 | TCP | Developer utilities |
| **cAdvisor** | 8082 | TCP | Container stats |
| **Pi-hole Web** | 8053 | TCP | Admin interface |
| **Excalidraw** | 8088 | TCP | Whiteboard |
| **Vaultwarden** | 8090 | TCP | Password manager |
| **Nextcloud** | 8091 | TCP | Cloud storage |
| **Portainer** | 9000 | TCP | Docker management |
| **Prometheus** | 9090 | TCP | Metrics database |
| **Node Exporter** | 9100 | TCP | System metrics |
| **Home Assistant** | 8123 | TCP | Smart home hub |

---

## 🔒 Security

### Network Security
- **UFW Firewall**: Only SSH (22) and DNS (53) exposed to internet
- **Tailscale VPN**: Zero-trust mesh network for secure remote access
- **fail2ban**: SSH brute-force protection
- **SSH Key Authentication**: Password authentication disabled

### Service Isolation
- All web services blocked from internet by firewall
- Accessible only via:
  - Local network (trusted)
  - Tailscale VPN (authenticated)
- Docker network isolation for inter-service communication

### Secret Management
- Sensitive configs in `.env` files (gitignored)
- API keys never committed to repository
- Deploy keys for read-only GitHub access

---

## 🛠️ Tech Stack

- **Hardware**: Raspberry Pi 5 with NVMe SSD
- **OS**: Raspberry Pi OS (Debian-based)
- **Containerization**: Docker & Docker Compose
- **VPN**: Tailscale (WireGuard-based)
- **Reverse Proxy**: Nginx Proxy Manager (optional)
- **Monitoring**: Prometheus + Grafana + cAdvisor
- **Database**: PostgreSQL 16
- **AI Integration**: LiteLLM proxy supporting multiple providers

---

## 📁 Repository Structure

```
/opt/docker/
├── excalidraw/         # Whiteboard application
├── homeassistant/      # Smart home automation
├── homarr/             # Main dashboard
├── ittools/            # Developer utilities
├── monitoring/         # Grafana + Prometheus + cAdvisor + Node Exporter
├── nextcloud/          # Personal cloud storage
├── nginx-proxy-manager/  # Reverse proxy with Let's Encrypt
├── open-webui/         # AI chat UI + LiteLLM proxy
├── pihole/             # DNS and ad blocking
├── portainer/          # Docker management UI
├── postgresql/         # Shared database
├── uptime-kuma/        # Service monitoring
├── vaultwarden/        # Password manager
└── watchtower/         # Auto-updater for containers
```

Each service directory contains:
- `docker-compose.yml` - Service definition
- `.env` - Environment variables (gitignored)
- `data/` or `config/` - Persistent storage (gitignored)

---

## 🚀 Quick Start

### Prerequisites
- Raspberry Pi 5 (or similar Linux server)
- Docker and Docker Compose installed
- Static IP address configured
- (Optional) Tailscale account for remote access

### Deployment

1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/pi5-opt.git /opt/docker
cd /opt/docker
```

2. **Create environment files**
```bash
# Example for PostgreSQL
echo "POSTGRES_PASSWORD=your_secure_password" > postgresql/.env

# Example for Pi-hole
echo "TZ=America/Los_Angeles" > pihole/.env
echo "HOLE_PASSWORD=your_pihole_password" >> pihole/.env

# Example for Open WebUI (AI keys)
echo "ANTHROPIC_API_KEY=sk-ant-xxxxx" > open-webui/.env
echo "OPENAI_API_KEY=sk-xxxxx" >> open-webui/.env
```

3. **Create Docker network**
```bash
docker network create services-network
```

4. **Start services**
```bash
# Start core services first
cd postgresql && docker compose up -d && cd ..
cd pihole && docker compose up -d && cd ..

# Start remaining services
for dir in */; do
    if [ -f "$dir/docker-compose.yml" ]; then
        cd "$dir" && docker compose up -d && cd ..
    fi
done
```

5. **Configure Pi-hole DNS**
- Access Pi-hole at `http://YOUR_IP:8053/admin`
- Settings → DNS → Select upstream providers (Cloudflare, Quad9)
- Set device DNS to your Pi's IP address

6. **Access Homarr dashboard**
- Navigate to `http://YOUR_IP:7777`
- Add your services manually or enable Docker integration

---

## 🔧 Useful Commands

### Docker Management
```bash
# View running containers
docker ps

# View logs
docker compose logs -f SERVICE_NAME

# Restart service
docker compose restart

# Update all images
cd /opt/docker
for dir in */; do cd "$dir" && docker compose pull && docker compose up -d && cd ..; done
```

### System Maintenance
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Check firewall
sudo ufw status

# Monitor fail2ban
sudo fail2ban-client status sshd

# Tailscale status
tailscale status
```

---

## 🐛 Troubleshooting

### Service won't start
```bash
cd /opt/docker/SERVICE_NAME
docker compose logs
```

### Port already in use
```bash
sudo netstat -tulpn | grep :PORT
```

### Pi-hole not blocking ads
1. Verify DNS is set to Pi's IP
2. Check Pi-hole is running: `docker ps | grep pihole`
3. Review query log in admin panel

### Can't access via Tailscale
```bash
# Ensure Tailscale is running on both devices
tailscale status
```

---

## 📝 Features & Highlights

### AI Integration
- Multi-model support via LiteLLM proxy
- Single interface for Claude, GPT-4, Gemini, and more
- Self-hosted AI chat with no vendor lock-in
- Perfect for future voice assistant projects

### Complete Observability
- Real-time metrics with Prometheus
- Custom Grafana dashboards
- Container-level resource monitoring
- Service uptime tracking

### Privacy-Focused
- All data stored locally
- No cloud dependencies for core services
- Network-wide ad blocking
- Self-hosted password management

### Automation
- Watchtower keeps containers updated
- Home Assistant for smart home automation
- Zero-touch container updates

---

## 🎯 Future Roadmap

- [ ] Automated backup system with Duplicati
- [ ] Outline wiki for documentation
- [ ] Code-server for remote development
- [ ] Voice assistant with wake word detection
- [ ] Reverse proxy with automatic HTTPS
- [ ] Metrics alerting with Alertmanager

---

## 📄 License

This configuration is provided as-is for educational and personal use.

---

## 🙏 Acknowledgments

Built with open-source software:
- Docker & Docker Compose
- Tailscale
- Pi-hole
- Home Assistant
- Nextcloud
- And many more amazing projects!

---

**Platform:** Raspberry Pi 5  
**Storage:** NVMe SSD  
**OS:** Raspberry Pi OS  
**Created:** December 2025



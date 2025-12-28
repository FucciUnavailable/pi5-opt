```bash
cd /opt/docker
vim README.md
```

**Paste this:**

```markdown
# Raspberry Pi 5 Home Lab Setup

## Quick Access URLs
Replace `PI_IP` with your Pi's static IP address

### Main Services
- **Portainer** (Docker Management): http://PI_IP:9000
- **Pi-hole** (Ad Blocking): http://PI_IP/admin
- **Home Assistant**: http://PI_IP:8123
- **Grafana** (Monitoring): http://PI_IP:3000
- **Uptime Kuma** (Status Monitor): http://PI_IP:3001

### Utilities
- **IT-Tools**: http://PI_IP:8080
- **Excalidraw**: http://PI_IP:8088

### Monitoring Stack (Backend)
- **Prometheus**: http://PI_IP:9090
- **cAdvisor**: http://PI_IP:8082
- **Node Exporter**: http://PI_IP:9100

---

## Port Reference

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| SSH | 22 | TCP | Remote access |
| DNS (Pi-hole) | 53 | TCP/UDP | DNS queries |
| Pi-hole Web | 80 | TCP | Admin interface |
| Portainer | 9000 | TCP | Container management |
| IT-Tools | 8080 | TCP | Utility tools |
| Excalidraw | 8088 | TCP | Drawing board |
| Home Assistant | 8123 | TCP | Smart home |
| Uptime Kuma | 3001 | TCP | Service monitoring |
| Grafana | 3000 | TCP | Dashboards |
| Prometheus | 9090 | TCP | Metrics storage |
| cAdvisor | 8082 | TCP | Container stats |
| Node Exporter | 9100 | TCP | System metrics |
| WireGuard VPN | 51820 | UDP | VPN tunnel |

---

## Directory Structure
```
/opt/docker/
├── portainer/
├── pihole/
├── homeassistant/
├── it-tools/
├── excalidraw/
├── uptime-kuma/
├── monitoring/
│   ├── docker-compose.yml
│   └── prometheus.yml
└── wireguard/
```

---

## Useful Aliases
```bash
d          # docker
dc         # docker compose
dcu        # docker compose up -d
dcd        # docker compose down
dcr        # docker compose restart
dcl        # docker compose logs -f
dps        # docker ps
opt        # cd /opt/docker
ll         # ls -alh
update     # sudo apt update && upgrade
```

---

## Quick Commands

### View all running containers
```bash
dps
```

### Restart a service
```bash
cd /opt/docker/SERVICE_NAME
dcr
```

### View logs
```bash
cd /opt/docker/SERVICE_NAME
dcl
```

### Update all containers
```bash
cd /opt/docker/SERVICE_NAME
docker compose pull
dcu
```

---

## Default Credentials

**Portainer**: Set during first login  
**Pi-hole**: Check `/opt/docker/pihole/.env` or container logs  
**Grafana**: admin / (check `/opt/docker/monitoring/.env`)  
**Uptime Kuma**: Set during first login  

---

## Grafana Dashboards

**Node Exporter (Pi Stats)**: Dashboard ID 1860  
**Docker Monitoring**: Dashboard ID 193  

---

## Security

- **Firewall**: UFW enabled
- **Fail2ban**: Protecting SSH
- **Pi-hole**: Blocking malicious domains
- **WireGuard**: Secure remote access

---

## Backup Important Files

```bash
# Backup docker compose files
tar -czf ~/docker-backup-$(date +%Y%m%d).tar.gz /opt/docker/*/docker-compose.yml

# Backup .env files (contains passwords!)
tar -czf ~/env-backup-$(date +%Y%m%d).tar.gz /opt/docker/*/.env
```

---

## System Info

**Model**: Raspberry Pi 5  
**Storage**: NVMe SSD (boots from SSD)  
**OS**: Raspberry Pi OS  
**Docker**: Installed  
**Static IP**: [Your IP here]  

---

## Notes

- All services auto-restart on reboot
- Passwords stored in .env files (never commit to git!)
- Monitor system health in Grafana
- Check service status in Uptime Kuma
```


# Nginx Proxy Manager with Advanced Features

A comprehensive Docker-based solution using **Nginx Proxy Manager** with advanced security features including:

- **🌐 Nginx Proxy Manager** with intuitive web interface
- **🛡️ Advanced Fail2Ban Integration** for comprehensive protection
- **🔒 Automatic SSL/TLS** with Let's Encrypt integration
- **⚡ High Performance** configuration with health checks
- **📊 Monitoring & Logging** capabilities
- **🔧 Fully Automated Setup** with Docker Compose

## ✨ Features

### 🎛️ Web Interface Management
- **Easy Configuration**: Intuitive web UI for managing proxy hosts
- **SSL Certificate Management**: Automatic Let's Encrypt certificate generation
- **Real-time Monitoring**: Live view of proxy hosts and their status
- **Access Lists**: Built-in access control and authentication

### 🛡️ **UNIVERSAL SECURITY PROTECTION**
**🔥 ALL PROXY HOSTS ARE AUTOMATICALLY PROTECTED:**
- **✅ Every reverse proxy host** gets DDoS protection
- **✅ Every reverse proxy host** gets HTTP flood detection  
- **✅ Every reverse proxy host** gets bot/scanner blocking
- **✅ Every reverse proxy host** gets security headers
- **✅ Every reverse proxy host** gets rate limiting
- **✅ Admin interface** gets additional specialized protection

### 🚨 **Advanced Threat Detection**
- **DDoS Protection**: HTTP floods (>100 req/sec), Connection floods (>1000 active)
- **Slow DoS Detection**: Slowloris and timeout-based attacks
- **Bot/Scanner Blocking**: Automated vulnerability scanners
- **Brute Force Protection**: Login attempt monitoring
- **Directory Traversal**: Protection against path-based attacks

### 📱 **Optional Telegram Notifications**
- **Real-time Security Alerts**: Instant notifications for all attacks
- **IP Ban Notifications**: Details on banned IPs with attack info
- **Attack Pattern Analysis**: Context about detected threats
- **System Status**: Service start/stop notifications

### 📊 **Independent Prometheus + Flexible Grafana**  
- **🔍 Prometheus Metrics Hub**: Runs independently, collects all security data
- **📊 Multiple Grafana Options**: Single, multi-instance, or external connections
- **🌐 Universal Integration**: Connect any monitoring tool to Prometheus
- **🛡️ Resilient Architecture**: Metrics collection never stops, even if dashboards fail
- **🎯 Role-Based Dashboards**: Security team, executives, DevOps - different views

### 🚀 Performance & Reliability
- **Health Checks**: Automatic service monitoring and recovery
- **Database Backend**: MariaDB for configuration persistence
- **Automatic Startup**: Services start in correct order with dependencies
- **Modular Design**: Enable only the features you need

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <repository>
cd acs-gates
```

### 2. Configure Environment
```bash
# Copy example configuration
cp .env.example .env

# Edit with your settings (IMPORTANT: Change default passwords!)
nano .env
```

### 3. Start Services
```bash
# Option 1: Use the startup script (recommended)
./start-npm.sh

# Option 2: Use Docker Compose directly
docker compose up -d --wait
```

### 4. Access Web Interface
- **Admin Panel**: http://localhost:81
- **Default Login**: 
  - Email: `admin@example.com`
  - Password: `changeme`
- **⚠️ IMPORTANT**: Change these credentials immediately!

## 📋 Configuration

### 🔧 Environment Variables (.env)
Key settings to customize:

```bash
# Basic Configuration
TIMEZONE=UTC

# Database Security (CHANGE THESE!)
NPM_DB_ROOT_PASSWORD=changeme_root_password_here
NPM_DB_PASSWORD=changeme_npm_password_here

# Optional Features - Enable/Disable
ENABLE_TELEGRAM_NOTIFICATIONS=true  # Set to false to disable alerts
ENABLE_PROMETHEUS=true              # Independent metrics collection  
ENABLE_GRAFANA=true                 # Main dashboard (requires Prometheus)
ENABLE_MULTI_GRAFANA=false          # Additional team-specific dashboards

# Telegram (only if ENABLE_TELEGRAM_NOTIFICATIONS=true)
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id

# Prometheus (only if ENABLE_PROMETHEUS=true)
PROMETHEUS_PORT=9090                # Metrics collection endpoint

# Grafana (only if ENABLE_GRAFANA=true)
GRAFANA_ADMIN_PASSWORD=changeme_grafana_password
GRAFANA_PORT=3000

# Multi-Grafana (only if ENABLE_MULTI_GRAFANA=true)
GRAFANA_SECURITY_PASSWORD=changeme_security_password    # Port 3001
GRAFANA_EXEC_PASSWORD=changeme_executive_password       # Port 3002
```

### 🛡️ **AUTOMATIC SECURITY FOR ALL HOSTS**

**🔥 Every proxy host you add gets these protections automatically:**

| Protection Type | What It Does | Coverage |
|----------------|--------------|----------|
| **DDoS Protection** | Blocks HTTP floods (>100 req/sec) | 🟢 ALL HOSTS |
| **Connection Limiting** | Prevents connection floods (>1000) | 🟢 ALL HOSTS |
| **Bot Detection** | Blocks malicious crawlers/scanners | 🟢 ALL HOSTS |
| **Rate Limiting** | Prevents request spam | 🟢 ALL HOSTS |
| **Security Headers** | OWASP recommended headers | 🟢 ALL HOSTS |
| **Slow DoS Protection** | Blocks Slowloris attacks | 🟢 ALL HOSTS |
| **Real IP Detection** | Bans actual users behind CDN/proxy | 🟢 ALL HOSTS |
| **Admin Protection** | Extra protection for NPM interface | 🟡 ADMIN ONLY |

### 🌐 **Cloudflare Integration**

**✅ NPM Built-in Cloudflare Support:**
- **Automatic Real IP Detection**: NPM automatically handles `CF-Connecting-IP` headers
- **No Manual Configuration**: Works out-of-the-box with Cloudflare proxy
- **Accurate Client IPs**: Bans and rate limits apply to real users, not Cloudflare servers
- **SSL Compatibility**: Full SSL mode works seamlessly with Let's Encrypt
- **Admin Interface**: Can be proxied through Cloudflare with proper DNS settings

**⚠️ Important:** NPM manages nginx internally. Custom nginx.conf files will cause conflicts and are automatically backed up by the startup script.

### 🔒 Security Jails Configuration
Advanced Fail2Ban jails automatically active:
- `nginx-ddos`: DDoS attack detection (ALL PROXY HOSTS)
- `nginx-http-flood`: HTTP flood detection (ALL PROXY HOSTS)
- `nginx-slow-dos`: Slow DoS attack detection (ALL PROXY HOSTS)  
- `npm-admin`: Admin interface protection (NPM ONLY)
- `npm-general-forceful-browsing`: Directory traversal protection (ALL HOSTS)
- `npm-proxy-manager`: General proxy abuse protection (ALL HOSTS)

## 📖 Usage Guide

### 🌐 Adding Proxy Hosts

1. **Access Admin Panel**: `http://YOUR_VPS_IP:81` or `https://admin.yourdomain.com` (if configured)
2. **Navigate**: Proxy Hosts → Add Proxy Host
3. **Configure**:
   - Domain: `app.example.com`
   - Forward Hostname/IP: `backend-service` or `internal-ip`
   - Forward Port: `8080`
4. **SSL**: Enable "Request a new SSL Certificate" 
5. **Advanced**: Add custom nginx directives for enhanced security

### 🔐 **Admin Interface Setup with Cloudflare**

**For secure admin access behind Cloudflare:**

1. **Create DNS Record** (DNS-only, gray cloud):
   ```
   admin.yourdomain.com → YOUR_VPS_IP
   ```

2. **Add Admin Proxy Host** in NPM:
   - **Domain**: `admin.yourdomain.com`
   - **Forward to**: `127.0.0.1:81` 
   - **SSL**: ✅ Request new SSL certificate
   - **Advanced Tab**:
   ```nginx
   location / {
       # Strict rate limiting for admin
       limit_req zone=npm burst=5 nodelay;
       proxy_set_header X-Admin-Access "true";
   }
   ```

3. **Access**: `https://admin.yourdomain.com` (standard HTTPS port)

**🛡️ SECURITY AUTO-APPLIED**: Every host you add automatically gets:
- ✅ DDoS protection
- ✅ Bot blocking  
- ✅ Rate limiting
- ✅ Security headers
- ✅ Fail2Ban monitoring
- ✅ Telegram alerts (if enabled)
- ✅ Grafana monitoring (if enabled)

### 🔒 SSL Certificate Management

**Automatic (Recommended)**:
- ✅ Check "Request a new SSL Certificate" when creating proxy host
- ✅ Certificates auto-renew before expiration

**Manual**:
- Upload custom certificates through the web interface
- Supports wildcard certificates

### 👥 Access Control

1. **Create Access Lists**: Users → Access Lists
2. **Add Users**: Define usernames and passwords
3. **Apply to Proxy Hosts**: Select access list when configuring hosts

## 📊 **Monitoring & Multi-Dashboard Setup**

### 🔍 **Independent Prometheus Architecture**

**Prometheus runs standalone and never stops collecting metrics, even if dashboards fail:**

```bash
# Prometheus always available at:
http://localhost:9090

# Raw metrics queries examples:
http://localhost:9090/metrics                          # All metrics
rate(nginx_http_requests_total[1m])                    # Request rate
f2b_banned_total                                       # Banned IPs
nginx_connections_active                               # Active connections
```

### 📊 **Multiple Grafana Options**

#### **Option 1: Single Grafana (Default)**
```bash
ENABLE_PROMETHEUS=true
ENABLE_GRAFANA=true
# Result: http://localhost:3000
```

#### **Option 2: Multi-Team Dashboards**
```bash  
ENABLE_PROMETHEUS=true
ENABLE_GRAFANA=true         # Main dashboard (port 3000)
ENABLE_MULTI_GRAFANA=true   # Additional dashboards
# Result: 
# - DevOps: http://localhost:3000
# - Security: http://localhost:3001  
# - Executive: http://localhost:3002
```

#### **Option 3: External Integration**
```bash
# Your Prometheus available for external tools:
ENABLE_PROMETHEUS=true
ENABLE_GRAFANA=false        # Use external Grafana instead

# External Grafana datasource config:
# Type: Prometheus
# URL: http://your-server-ip:9090
```

### 📈 Health Monitoring
```bash
# Check all services
docker compose ps

# Check Prometheus metrics
curl http://localhost:9090/-/healthy

# View service logs
docker compose logs -f nginx-proxy-manager
docker compose logs -f prometheus
docker compose logs -f fail2ban

# Check Fail2Ban status
docker compose exec fail2ban fail2ban-client status
```

### 🔍 Log Files
- **Access Logs**: `./nginx/logs/access.log`
- **Error Logs**: `./nginx/logs/error.log` 
- **NPM Logs**: `docker compose logs nginx-proxy-manager`
- **Database Logs**: `docker compose logs npm-db`

### 🛠️ Maintenance Commands
```bash
# Update all images
docker compose pull && docker compose up -d

# Restart services
docker compose restart

# Stop all services
docker compose down

# View real-time logs
docker compose logs -f
```

## 🛡️ **COMPREHENSIVE SECURITY FEATURES**

### 🚨 **Telegram Alert Examples**
When attacks occur, you'll receive instant notifications like:

```
🚨 **SECURITY ALERT - IP BANNED**

🔴 **IP Address:** `203.0.113.42`
🏷️ **Jail:** nginx-ddos  
⚡ **Failures:** 25 requests in 60s
🕐 **Ban Time:** 7200s (2 hours)
📅 **Time:** 2024-01-15 10:30:45
🎯 **Target:** app.example.com (ALL YOUR HOSTS PROTECTED)
```

### 📊 **Grafana Dashboard Features**
Access real-time monitoring at `http://localhost:3000`:

- **🔥 Attack Detection**: Live graphs showing HTTP floods, DDoS attempts
- **📈 Traffic Analysis**: Request rates, response codes, connection counts  
- **🚫 Banned IPs**: Real-time list of blocked attackers
- **⚠️ Automated Alerts**: Notifications when thresholds exceeded
- **📊 Historical Data**: Long-term attack pattern analysis

### 🛡️ **Multi-Layer Protection**
**Every proxy host gets ALL these protections:**

| Layer | Protection | Trigger | Ban Time |
|-------|------------|---------|----------|
| **1** | DDoS Detection | >20 req/min | 2 hours |
| **2** | HTTP Flood | >50 req/5min | 1 hour |  
| **3** | Slow DoS | Timeouts/slow requests | 2 hours |
| **4** | Bot/Scanner | Vulnerability scans | 1 hour |
| **5** | Brute Force | Login attempts | 2 hours |
| **6** | Admin Protection | NPM interface abuse | 2 hours |

### 🔐 **Automatic Security Headers**
Applied to ALL proxy hosts:
- `X-Frame-Options: SAMEORIGIN` - Prevents clickjacking
- `X-XSS-Protection: 1; mode=block` - XSS protection
- `X-Content-Type-Options: nosniff` - MIME type sniffing protection  
- `Strict-Transport-Security` - Forces HTTPS (when SSL enabled)
- `Referrer-Policy: no-referrer-when-downgrade` - Privacy protection

## 🚨 Troubleshooting

### ❌ Common Issues

**NPM Proxy Host Creation Fails (500/400 errors)**:
```bash
# Check for nginx config conflicts
docker compose logs nginx-proxy-manager --tail=50

# Common cause: Custom nginx.conf conflicts with NPM
# Solution: Restart script automatically backs up conflicting files
./start-npm.sh
```

**Cloudflare SSL Handshake Failures**:
- Set Cloudflare SSL mode to **"Full"** or **"Full (strict)"** 
- NOT "Flexible" mode
- Use DNS-only (gray cloud) for admin domains initially

**Database connection errors**:
```bash
# Check database health
docker compose exec npm-db mysqladmin ping -u root -p

# Reset database
docker compose down -v
docker compose up -d
```

**Admin interface not accessible**:
- Access via server IP: `http://YOUR_VPS_IP:81`
- Create admin proxy host for domain access
- Check NPM logs for configuration errors

### 🔧 Debugging Commands
```bash
# Test configuration
docker compose config

# Check service health
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"

# View detailed logs
docker compose logs --tail=100 -f nginx-proxy-manager
```

## 🏢 **Enterprise Integration Examples**

### **Connect Corporate Grafana**
```bash
# Add datasource in your company's Grafana:
Name: NPM Security Metrics
Type: Prometheus  
URL: http://your-npm-server:9090
Access: Server
```

### **Connect Grafana Cloud**
```bash
# Add remote_write to monitoring/prometheus/prometheus.yml:
remote_write:
  - url: "https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push"
    basic_auth:
      username: "your_user_id" 
      password: "your_api_key"
```

### **Custom Monitoring Tools**
```python
# Python example - connect any tool to Prometheus
import requests

# Get current banned IPs
response = requests.get('http://your-server:9090/api/v1/query?query=f2b_banned_total')
banned_ips = response.json()

# Get HTTP request rate  
response = requests.get('http://your-server:9090/api/v1/query?query=rate(nginx_http_requests_total[1m])')
request_rate = response.json()
```

## 📁 File Structure
```
Nginx Proxy Manager/
├── docker-compose.yml              # Main configuration
├── docker-compose.override.yml     # Multi-Grafana instances
├── .env.example                   # Environment template  
├── start-npm.sh                  # Startup script
├── fail2ban/
│   ├── jail.local                # Fail2Ban configuration
│   ├── filter.d/                 # Custom security filters
│   └── action.d/                 # Telegram notification actions
├── monitoring/
│   ├── prometheus/               # Prometheus configuration
│   │   ├── prometheus.yml        # Main config + scrape targets
│   │   └── ddos_rules.yml       # DDoS/attack detection rules
│   └── grafana/                  # Grafana dashboards & config
│       ├── provisioning/         # Auto-provisioned datasources
│       └── dashboards/           # Security monitoring dashboards
├── nginx/logs/                   # Log directory (auto-created)
├── npm-data/                     # NPM data (auto-created)
├── npm-letsencrypt/              # SSL certificates (auto-created)
└── npm-db/                       # Database data (auto-created)
```

## 🔄 Backup Strategy
```bash
# Backup essential data
tar -czf npm-backup-$(date +%Y%m%d).tar.gz \
  npm-data npm-letsencrypt .env fail2ban

# Database backup
docker compose exec npm-db mysqldump -u root -p npm > npm-db-backup.sql
```

## 🤝 Contributing
1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## 📜 License
This project is licensed under the MIT License.

## 🆘 Support
- 📝 Create an issue for bugs or feature requests
- 📖 Check the troubleshooting section above
- 🔍 Review NPM documentation at https://nginxproxymanager.com/
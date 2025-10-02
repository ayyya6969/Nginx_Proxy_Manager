#!/bin/bash

# Nginx Proxy Manager with Advanced Features
echo "🚀 Starting Nginx Proxy Manager with Advanced Features..."

# Check if .env exists, if not copy from .env.example
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo "📝 Creating .env from .env.example..."
        cp .env.example .env
        echo "⚠️  Please review and update .env file with your settings"
    else
        echo "❌ No .env or .env.example found. Please create .env file first."
        exit 1
    fi
fi

# Create necessary directories
echo "📁 Creating required directories..."
mkdir -p npm-data npm-letsencrypt npm-db fail2ban/filter.d fail2ban/jail.d

# Handle NPM nginx configuration conflicts
echo "🔧 Checking NPM nginx configuration compatibility..."
if [ -f "nginx/nginx.conf" ]; then
    echo "⚠️  Found custom nginx.conf - NPM manages nginx internally"
    echo "📁 Backing up custom nginx.conf to nginx/nginx.conf.backup"
    mv nginx/nginx.conf nginx/nginx.conf.backup 2>/dev/null || true
fi

if [ -d "nginx/conf.d" ]; then
    echo "📁 Backing up custom conf.d to nginx/conf.d.backup"
    mv nginx/conf.d nginx/conf.d.backup 2>/dev/null || true
fi

if [ -d "nginx/ssl" ]; then
    echo "📁 Preserving SSL certificates directory"
    # Keep SSL directory for custom certificates if needed
fi

echo "✅ NPM will use its internal nginx configuration"

# Set proper permissions
echo "🔐 Setting directory permissions..."
chmod 755 npm-data npm-letsencrypt npm-db
chmod 644 .env 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true

# Process environment variables for fail2ban
if [ -f .env ]; then
    echo "📝 Processing environment variables..."
    export $(grep -v '^#' .env | xargs)
    
    # Configure Telegram notifications if enabled
    if [ "${ENABLE_TELEGRAM_NOTIFICATIONS:-false}" = "true" ]; then
        echo "📱 Telegram notifications: ENABLED"

        # Replace telegram token placeholders with actual values from .env
        if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ "${TELEGRAM_BOT_TOKEN}" != "your_bot_token_here" ]; then
            sed -i "s/telegram_token = %(telegram_token)s/telegram_token = ${TELEGRAM_BOT_TOKEN}/" fail2ban/jail.d/custom.local
            sed -i "s/telegram_chat_id = %(telegram_chat_id)s/telegram_chat_id = ${TELEGRAM_CHAT_ID}/" fail2ban/jail.d/custom.local
            echo "✅ Telegram tokens configured from .env"
        else
            echo "⚠️ Telegram tokens not configured in .env - notifications may not work"
        fi
    else
        echo "📱 Telegram notifications: DISABLED"
        # Remove Telegram actions from jail.d/custom.local
        sed -i 's/telegram\[token="[^"]*", chat_id="[^"]*"\]//g' fail2ban/jail.d/custom.local
    fi

    # Configure Cloudflare API blocking if enabled
    if [ "${ENABLE_CLOUDFLARE_BLOCKING:-false}" = "true" ]; then
        echo "☁️  Cloudflare API blocking: ENABLED"
        if [ -n "${CLOUDFLARE_API_TOKEN:-}" ] && [ "${CLOUDFLARE_API_TOKEN}" != "your_cloudflare_api_token_here" ]; then
            # Add Cloudflare action to npm-proxy-host-flood jail
            sed -i "/^\[npm-proxy-host-flood\]/,/^$/s|^action = iptables-multiport.*|action = iptables-multiport[name=npm-flood, port=\"http,https\", protocol=tcp, chain=DOCKER-USER]\n         cloudflare-apiv4[cftoken=\"${CLOUDFLARE_API_TOKEN}\"]|" fail2ban/jail.d/custom.local
            echo "✅ Cloudflare API token configured from .env"
        else
            echo "⚠️ Cloudflare API token not configured in .env"
        fi
    else
        echo "☁️  Cloudflare API blocking: DISABLED (using iptables only)"
        # Ensure no cloudflare action in the jail
        sed -i '/cloudflare-apiv4/d' fail2ban/jail.d/custom.local
    fi
else
    echo "⚠️ No .env file found - using defaults"
fi

# Start services with health checks
echo "🐳 Starting core services with health checks..."
docker compose up -d --wait

# Check if Prometheus is enabled (independent metrics collection)
if [ "${ENABLE_PROMETHEUS:-false}" = "true" ]; then
    echo "🔍 Prometheus metrics: ENABLED - Starting metrics collection..."
    docker compose --profile monitoring up -d prometheus node-exporter nginx-exporter fail2ban-exporter
    echo "🔍 Prometheus available at: http://localhost:${PROMETHEUS_PORT:-9090}"
    
    # Check if Grafana is also enabled
    if [ "${ENABLE_GRAFANA:-false}" = "true" ]; then
        echo "📊 Grafana dashboard: ENABLED - Starting visualization..."
        docker compose --profile grafana up -d
        echo "📊 Grafana available at: http://localhost:${GRAFANA_PORT:-3000}"
    else
        echo "📊 Grafana dashboard: DISABLED (Prometheus still collecting metrics)"
    fi
    
    # Check if multi-Grafana is enabled
    if [ "${ENABLE_MULTI_GRAFANA:-false}" = "true" ]; then
        echo "📊 Multi-Grafana: ENABLED - Starting additional instances..."
        docker compose --profile grafana-multi up -d
        echo "🛡️  Security Grafana: http://localhost:3001"
        echo "👔 Executive Grafana: http://localhost:3002"
    fi
else
    echo "🔍 Prometheus metrics: DISABLED"
    echo "📊 Grafana dashboard: DISABLED (requires Prometheus)"
fi

echo ""
echo "✅ =================== SETUP COMPLETE ==================="
echo "🌐 Nginx Proxy Manager Admin Panel: http://localhost:81"
echo "🔑 Default credentials:"
echo "   Email: admin@example.com"
echo "   Password: changeme"
echo ""
echo "⚠️  IMPORTANT: Change these credentials on first login!"
echo ""
echo "📊 Services Status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "📋 Quick Commands:"
echo "   View logs: docker compose logs -f [service-name]"
echo "   Stop all:  docker compose down"
echo "   Restart:   docker compose restart"
echo "======================================================="
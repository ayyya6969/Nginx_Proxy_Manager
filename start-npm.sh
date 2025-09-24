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
mkdir -p npm-data npm-letsencrypt npm-db nginx/logs fail2ban/filter.d

# Set proper permissions
echo "🔐 Setting directory permissions..."
chmod 755 npm-data npm-letsencrypt npm-db nginx/logs
chmod 644 .env

# Process environment variables for fail2ban
if [ -f .env ]; then
    echo "📝 Processing environment variables..."
    export $(grep -v '^#' .env | xargs)
    
    # Configure Telegram notifications if enabled
    if [ "${ENABLE_TELEGRAM_NOTIFICATIONS:-false}" = "true" ]; then
        echo "📱 Telegram notifications: ENABLED"
        envsubst < fail2ban/jail.local > fail2ban/jail.local.tmp && mv fail2ban/jail.local.tmp fail2ban/jail.local
    else
        echo "📱 Telegram notifications: DISABLED"
        # Remove Telegram actions from jail.local
        sed 's/telegram\[token="[^"]*", chat_id="[^"]*"\]//g' fail2ban/jail.local > fail2ban/jail.local.tmp && mv fail2ban/jail.local.tmp fail2ban/jail.local
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
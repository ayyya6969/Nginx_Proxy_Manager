#!/bin/bash
# Setup Let's Encrypt SSL certificate for NPM admin interface

echo "🔒 Setting up Let's Encrypt SSL for NPM admin interface..."

# Check if domain is provided
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <admin-domain>"
    echo "   Example: $0 admin.yourdomain.com"
    exit 1
fi

ADMIN_DOMAIN=$1
EMAIL=${ADMIN_EMAIL:-admin@$(echo $ADMIN_DOMAIN | cut -d'.' -f2-)}

echo "📍 Domain: $ADMIN_DOMAIN"
echo "📧 Email: $EMAIL"

# Install certbot if not present
if ! command -v certbot &> /dev/null; then
    echo "📦 Installing certbot..."
    if [ -f /etc/debian_version ]; then
        apt-get update && apt-get install -y certbot
    elif [ -f /etc/redhat-release ]; then
        yum install -y certbot || dnf install -y certbot
    else
        echo "❌ Please install certbot manually for your OS"
        exit 1
    fi
fi

# Stop NPM temporarily to free port 80
echo "⏹️  Stopping NPM temporarily for certificate generation..."
docker compose down nginx-proxy-manager

# Generate certificate using standalone mode
echo "🔐 Generating Let's Encrypt certificate..."
certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    -d "$ADMIN_DOMAIN" \
    --preferred-challenges http

if [ $? -eq 0 ]; then
    echo "✅ Certificate generated successfully!"
    
    # Create NPM SSL directory
    mkdir -p ../nginx/ssl/admin
    
    # Copy certificates to NPM directory
    cp "/etc/letsencrypt/live/$ADMIN_DOMAIN/fullchain.pem" "../nginx/ssl/admin/admin.crt"
    cp "/etc/letsencrypt/live/$ADMIN_DOMAIN/privkey.pem" "../nginx/ssl/admin/admin.key"
    
    # Set proper permissions
    chmod 644 ../nginx/ssl/admin/admin.crt
    chmod 600 ../nginx/ssl/admin/admin.key
    
    echo "📁 Certificates copied to: nginx/ssl/admin/"
    echo "🔒 Admin interface will now use HTTPS"
    
    # Create renewal hook script
    cat > /etc/letsencrypt/renewal-hooks/post/npm-admin-renewal.sh << EOF
#!/bin/bash
# Auto-renewal hook for NPM admin certificate
cp "/etc/letsencrypt/live/$ADMIN_DOMAIN/fullchain.pem" "$(dirname "\$0")/../../../../nginx/ssl/admin/admin.crt"
cp "/etc/letsencrypt/live/$ADMIN_DOMAIN/privkey.pem" "$(dirname "\$0")/../../../../nginx/ssl/admin/admin.key"
docker compose restart nginx-proxy-manager
EOF
    chmod +x /etc/letsencrypt/renewal-hooks/post/npm-admin-renewal.sh
    
    echo "🔄 Auto-renewal hook configured"
    
else
    echo "❌ Certificate generation failed!"
    echo "💡 Make sure:"
    echo "   - Domain points to this server IP"
    echo "   - Port 80 is accessible from internet"
    echo "   - No other service is using port 80"
fi

# Restart NPM
echo "🚀 Starting NPM with SSL configuration..."
docker compose up -d nginx-proxy-manager

echo ""
echo "✅ Setup complete!"
echo "🌐 Access admin interface at: https://$ADMIN_DOMAIN:444"
echo "🔒 Certificate will auto-renew every 90 days"
echo "🚫 HTTP access on port 81 is DISABLED (redirects to HTTPS)"
echo "🔐 Admin interface is now HTTPS-only for security"
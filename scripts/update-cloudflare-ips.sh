#!/bin/bash
# Update Cloudflare IP ranges dynamically for NPM

# Fetch current Cloudflare IPv4 ranges
CF_IPV4=$(curl -s https://www.cloudflare.com/ips-v4)
CF_IPV6=$(curl -s https://www.cloudflare.com/ips-v6)

# Generate nginx real_ip config
cat > /etc/nginx/conf.d/cloudflare-real-ip.conf << EOF
# Auto-generated Cloudflare IP ranges - $(date)

# IPv4 ranges
EOF

for ip in $CF_IPV4; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/cloudflare-real-ip.conf
done

echo "" >> /etc/nginx/conf.d/cloudflare-real-ip.conf
echo "# IPv6 ranges" >> /etc/nginx/conf.d/cloudflare-real-ip.conf

for ip in $CF_IPV6; do
    echo "set_real_ip_from $ip;" >> /etc/nginx/conf.d/cloudflare-real-ip.conf
done

cat >> /etc/nginx/conf.d/cloudflare-real-ip.conf << EOF

# Real IP configuration
real_ip_header CF-Connecting-IP;
real_ip_recursive on;
EOF

echo "Cloudflare IP ranges updated: $(date)"
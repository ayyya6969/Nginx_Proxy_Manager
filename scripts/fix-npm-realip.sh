#!/bin/bash
# Fix NPM to use CF-Connecting-IP header for real client IPs
# This script runs on container startup to ensure Cloudflare real IPs are logged

echo "Waiting for NPM to be ready..."
sleep 10

echo "Fixing NPM to use CF-Connecting-IP header..."
docker exec nginx-proxy-manager sed -i 's/real_ip_header X-Real-IP;/real_ip_header CF-Connecting-IP;/' /etc/nginx/nginx.conf

echo "Reloading nginx configuration..."
docker exec nginx-proxy-manager nginx -s reload

echo "Done! NPM now logs real client IPs from Cloudflare."

#!/usr/bin/env python3
"""
Custom Fail2Ban Metrics Exporter for Prometheus
Parses fail2ban logs and exposes metrics on port 9191
"""

import time
import re
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from collections import defaultdict
import threading
import json
from datetime import datetime, timedelta

class Fail2BanMetrics:
    def __init__(self):
        self.banned_ips = defaultdict(int)
        self.jail_stats = defaultdict(lambda: {'banned': 0, 'unbanned': 0})
        self.last_update = time.time()
        
    def parse_fail2ban_logs(self):
        """Parse fail2ban logs to extract metrics"""
        try:
            # Parse fail2ban log file
            log_file = "/var/log/fail2ban.log"
            if not os.path.exists(log_file):
                return
                
            with open(log_file, 'r') as f:
                lines = f.readlines()
                
            # Process recent log entries (last 24 hours)
            cutoff_time = datetime.now() - timedelta(hours=24)
            
            for line in lines[-10000:]:  # Process last 10k lines for performance
                if 'Ban' in line and 'jail' in line:
                    # Parse ban entries
                    ban_match = re.search(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*Ban (\d+\.\d+\.\d+\.\d+).*jail: (\w+)', line)
                    if ban_match:
                        timestamp_str, ip, jail = ban_match.groups()
                        try:
                            log_time = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
                            if log_time > cutoff_time:
                                self.banned_ips[ip] += 1
                                self.jail_stats[jail]['banned'] += 1
                        except ValueError:
                            continue
                            
                elif 'Unban' in line and 'jail' in line:
                    # Parse unban entries
                    unban_match = re.search(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*Unban (\d+\.\d+\.\d+\.\d+).*jail: (\w+)', line)
                    if unban_match:
                        timestamp_str, ip, jail = unban_match.groups()
                        try:
                            log_time = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
                            if log_time > cutoff_time:
                                self.jail_stats[jail]['unbanned'] += 1
                        except ValueError:
                            continue
                            
        except Exception as e:
            print(f"Error parsing logs: {e}")
            
    def get_prometheus_metrics(self):
        """Generate Prometheus format metrics"""
        self.parse_fail2ban_logs()
        
        metrics = []
        metrics.append("# HELP f2b_banned_total Total number of banned IPs")
        metrics.append("# TYPE f2b_banned_total counter")
        
        total_banned = sum(self.banned_ips.values())
        metrics.append(f"f2b_banned_total {total_banned}")
        
        # Per-jail metrics
        metrics.append("# HELP f2b_jail_banned_total Total bans per jail")
        metrics.append("# TYPE f2b_jail_banned_total counter")
        
        for jail, stats in self.jail_stats.items():
            metrics.append(f'f2b_jail_banned_total{{jail="{jail}"}} {stats["banned"]}')
            
        metrics.append("# HELP f2b_jail_unbanned_total Total unbans per jail")
        metrics.append("# TYPE f2b_jail_unbanned_total counter")
        
        for jail, stats in self.jail_stats.items():
            metrics.append(f'f2b_jail_unbanned_total{{jail="{jail}"}} {stats["unbanned"]}')
            
        # Currently banned IPs count
        metrics.append("# HELP f2b_currently_banned Current number of banned IPs")
        metrics.append("# TYPE f2b_currently_banned gauge")
        metrics.append(f"f2b_currently_banned {len(self.banned_ips)}")
        
        # System info
        metrics.append("# HELP f2b_exporter_last_update_seconds Last update timestamp")
        metrics.append("# TYPE f2b_exporter_last_update_seconds gauge")
        metrics.append(f"f2b_exporter_last_update_seconds {int(time.time())}")
        
        return "\n".join(metrics)

class MetricsHandler(BaseHTTPRequestHandler):
    def __init__(self, metrics_collector, *args, **kwargs):
        self.metrics_collector = metrics_collector
        super().__init__(*args, **kwargs)
        
    def do_GET(self):
        if self.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain; charset=utf-8')
            self.end_headers()
            
            metrics = self.metrics_collector.get_prometheus_metrics()
            self.wfile.write(metrics.encode('utf-8'))
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            health = {"status": "healthy", "timestamp": int(time.time())}
            self.wfile.write(json.dumps(health).encode('utf-8'))
            
        else:
            self.send_response(404)
            self.end_headers()
            
    def log_message(self, format, *args):
        # Suppress default logging
        pass

def main():
    metrics_collector = Fail2BanMetrics()
    
    def handler(*args, **kwargs):
        return MetricsHandler(metrics_collector, *args, **kwargs)
    
    server = HTTPServer(('0.0.0.0', 9191), handler)
    
    print("🔍 Custom Fail2Ban Metrics Exporter starting on port 9191")
    print("📊 Metrics available at: http://localhost:9191/metrics")
    print("💚 Health check at: http://localhost:9191/health")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Shutting down metrics exporter")
        server.shutdown()

if __name__ == "__main__":
    main()
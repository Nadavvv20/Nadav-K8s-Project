#!/bin/bash

# Clean old port-forwards to avoid "port is already allocated" errors
echo "Cleaning up old port-forwards..."
sudo killall kubectl 2>/dev/null

echo "Starting Port-Forwards..."
# Ingress Nginx
kubectl port-forward -n ingress-nginx --address 0.0.0.0 svc/my-ingress-ingress-nginx-controller 8080:80 &

# Grafana
kubectl port-forward --address 0.0.0.0 svc/kube-prometheus-grafana 3000:80 &

# Prometheus
kubectl port-forward --address 0.0.0.0 svc/kube-prometheus-kube-prome-prometheus 9090:9090 &

echo "All systems are GO! Check your browser:"
echo "WordPress: http://<EC2_IP>:8080"
echo "Grafana: http://<EC2_IP>:3000"
echo "Prometheus: http://<EC2_IP>:9090"

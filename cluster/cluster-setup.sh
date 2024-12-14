#!/bin/bash
set -euo pipefail

echo "Creating kind cluster..."
kind create cluster --config kind-cluster.yaml

echo "Installing Cilium..."
# Add Cilium Helm repository
helm repo add cilium https://helm.cilium.io/
helm repo update

# Install Cilium with Hubble enabled
helm install cilium cilium/cilium --version 1.14.3 \
  --namespace kube-system \
  --set operator.replicas=1 \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set monitoring.enabled=true \
  --set ipam.mode=kubernetes

echo "Installing CoreDNS..."
# CoreDNS comes with kind by default, but we'll ensure it's configured correctly
kubectl rollout status deployment/coredns -n kube-system

echo "Installing Metrics Server..."
kubectl apply -f metrics-server-components.yaml

echo "Installing Prometheus Stack..."
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring || true

# Install Prometheus Stack (includes Grafana)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

echo "Waiting for all pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n kube-system --timeout=300s
kubectl wait --for=condition=Ready pods --all -n monitoring --timeout=300s

echo "Cluster setup complete! Here's your cluster info:"
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A
#!/usr/bin/env bash
set -euo pipefail

: "${GRAFANA_ADMIN_PASSWORD:?Set GRAFANA_ADMIN_PASSWORD before running this script}"

command -v helm >/dev/null
command -v kubectl >/dev/null

kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace observability observability=enabled --overwrite
kubectl create namespace robot-shop --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
helm repo add grafana https://grafana.github.io/helm-charts --force-update
helm repo add fluent https://fluent.github.io/helm-charts --force-update
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts --force-update
helm repo update

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --version 92.14.0 \
  --namespace observability \
  --values observability/kube-prometheus-stack-values.yaml \
  --set-string grafana.adminPassword="${GRAFANA_ADMIN_PASSWORD}" \
  --wait --timeout 15m

helm upgrade --install loki grafana/loki \
  --version 7.5.0 \
  --namespace observability \
  --values observability/loki-values.yaml \
  --wait --timeout 15m

helm upgrade --install fluent-bit fluent/fluent-bit \
  --version 0.58.3 \
  --namespace observability \
  --values observability/fluent-bit-values.yaml \
  --wait --timeout 10m

helm upgrade --install jaeger jaegertracing/jaeger \
  --version 4.16.1 \
  --namespace observability \
  --values observability/jaeger-values.yaml \
  --wait --timeout 10m

kubectl apply --filename observability/grafana-dashboard.yaml

helm upgrade --install robot-shop ./K8s/helm \
  --namespace robot-shop \
  --wait --timeout 15m

kubectl --namespace robot-shop get pods,services
kubectl --namespace observability get pods,services

echo "Robot Shop: kubectl -n robot-shop port-forward service/web 8080:8080"
echo "Grafana:    kubectl -n observability port-forward service/monitoring-grafana 3000:80"
echo "Jaeger:     kubectl -n observability port-forward service/jaeger 16686:16686"

#!/usr/bin/env bash
set -euo pipefail

: "${SLACK_WEBHOOK_URL:?Set SLACK_WEBHOOK_URL to an incoming webhook URL}"

kubectl create namespace observability --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace observability observability=enabled --overwrite
kubectl --namespace observability create secret generic alertmanager-slack \
  --from-literal=webhook-url="${SLACK_WEBHOOK_URL}" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --filename observability/alertmanagerconfig.yaml

echo "Slack routing configured without writing the webhook URL to disk."

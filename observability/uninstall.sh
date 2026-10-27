#!/usr/bin/env bash
set -euo pipefail

helm uninstall robot-shop --namespace robot-shop --ignore-not-found
helm uninstall fluent-bit --namespace observability --ignore-not-found
helm uninstall jaeger --namespace observability --ignore-not-found
helm uninstall loki --namespace observability --ignore-not-found
helm uninstall monitoring --namespace observability --ignore-not-found

echo "Review persistent volume claims before deleting either namespace."
kubectl get persistentvolumeclaims --all-namespaces

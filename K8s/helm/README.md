# Robot Shop Helm chart

This Helm 3 application chart deploys Robot Shop, its data services, a load generator, Prometheus scrape targets, and the payment-service SLO rules.

The observability CRDs must exist before installing the chart. The supported workflow is:

```bash
export GRAFANA_ADMIN_PASSWORD='<strong-password>'
./observability/install.sh
```

For application-only development after kube-prometheus-stack is installed:

```bash
helm upgrade --install robot-shop ./K8s/helm \
  --namespace robot-shop --create-namespace \
  --wait --timeout 15m
```

Disable the load generator or monitoring resources when needed:

```bash
helm upgrade --install robot-shop ./K8s/helm \
  --namespace robot-shop \
  --set loadGenerator.enabled=false \
  --set monitoring.enabled=false
```

The payment image is maintained by this repository and defaults to `ghcr.io/0x52616469616e74/robot-shop-payment:main`. Other application images remain the public Robot Shop demonstration images. Production deployments should replace mutable tags with tested immutable tags or digests.

The chart no longer contains PodSecurityPolicy or Instana agent settings. PodSecurityPolicy was removed from Kubernetes, and this capstone uses Prometheus, Loki, and OpenTelemetry instead.

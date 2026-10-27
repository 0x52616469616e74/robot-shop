# DevOps Capstone 2 — Robot Shop Observability

[![Observability CI](https://github.com/0x52616469616e74/robot-shop/actions/workflows/observability-ci.yml/badge.svg)](https://github.com/0x52616469616e74/robot-shop/actions/workflows/observability-ci.yml)

This fork turns the Robot Shop microservices application into an observability capstone on Amazon EKS. It provides metrics and alerting with Prometheus, dashboards with Grafana, cluster log aggregation with Fluent Bit and Loki, and OpenTelemetry traces from the payment service to Jaeger.

## What is included

| Capability | Implementation |
| --- | --- |
| Workload packaging | Modernized Helm v3 chart in `K8s/helm` |
| Traffic | Bundled load-generator Deployment |
| Metrics | Payment request/error/latency metrics and existing cart/payment business metrics |
| Dashboard | Provisioned Grafana dashboard for golden signals and Loki logs |
| Logs | Fluent Bit DaemonSet to single-binary Loki with seven-day retention |
| Traces | Flask and Requests OpenTelemetry instrumentation to Jaeger over OTLP/HTTP |
| SLO | 99% payment availability objective with a five-minute error-budget burn alert |
| Notification | AlertmanagerConfig routing payment alerts to Slack |
| Operations | Runbook, incident drill, postmortem template, and evidence checklist |

See [docs/architecture.md](docs/architecture.md) for the data flow.
The archived upstream service images are demonstration software; see [docs/security.md](docs/security.md) for the maintained security boundary and known limitations.

## Prerequisites

- A working Kubernetes cluster with at least two medium-sized worker nodes. The EKS cluster from Capstone 1 can be reused.
- `kubectl` connected to the intended cluster.
- Helm 3.
- A strong Grafana administrator password held outside this repository.
- The `ghcr.io/0x52616469616e74/robot-shop-payment:main` package made public after its first successful CI build.

## Install

```bash
export GRAFANA_ADMIN_PASSWORD='<strong-password>'
./observability/install.sh
```

The script installs pinned chart versions:

- kube-prometheus-stack `92.14.0`
- Loki `7.5.0`
- Fluent Bit `0.58.3`
- Jaeger `4.16.1`

It then installs Robot Shop with its built-in load generator. Passwords are passed at runtime and are never written into tracked files.

## Open the interfaces

Run each port-forward in a separate terminal:

```bash
kubectl -n robot-shop port-forward service/web 8080:8080
kubectl -n observability port-forward service/monitoring-grafana 3000:80
kubectl -n observability port-forward service/jaeger 16686:16686
```

- Robot Shop: <http://localhost:8080>
- Grafana: <http://localhost:3000>
- Jaeger: <http://localhost:16686>

The Grafana username is `admin`; use the password supplied during installation.

## Configure Slack alerts

Create an incoming Slack webhook outside this repository, then inject it directly into a Kubernetes Secret:

```bash
export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/...'
./observability/configure-slack.sh
unset SLACK_WEBHOOK_URL
```

No webhook value is written to disk. The alert links to [the payment error-budget runbook](docs/runbooks/payment-error-budget.md).

## Verify telemetry

```bash
kubectl -n robot-shop get pods
kubectl -n observability get pods
kubectl -n robot-shop port-forward service/payment 8081:8080
curl http://localhost:8081/metrics
```

In Grafana, open **Robot Shop Observability**. Use Explore with the Loki query below to inspect payment logs:

```logql
{namespace="robot-shop", container="payment"}
```

In Jaeger, select `robot-shop-payment` and find traces while the load generator is active or while completing purchases manually.

## SLO and incident drill

The payment availability SLO is 99%, leaving a 1% error budget. The `RobotShopPaymentErrorBudgetBurn` alert fires when the five-minute 5xx ratio exceeds that budget while requests are flowing.

Follow [docs/incident-drill.md](docs/incident-drill.md) to introduce controlled latency and errors, correlate metrics/logs/traces, validate Slack delivery, recover, and complete the [postmortem template](docs/postmortem-template.md).

## CI/CD

GitHub Actions validates the Helm and observability YAML, tests the payment service, scans the repository, then builds and scans the OpenTelemetry-enabled payment image. Pushes to `master` publish immutable commit-SHA and `main` tags to GHCR.

GitHub creates new personal container packages as private. After the first successful pipeline, change `robot-shop-payment` to public in its package settings so EKS can pull it without registry credentials.

## Evidence

Use [docs/evidence/README.md](docs/evidence/README.md) as the submission checklist. Capture timestamps and trace IDs that let a reviewer correlate the same incident across Grafana, Loki, Jaeger, Prometheus, and Slack.

## Cleanup

```bash
./observability/uninstall.sh
```

Review the listed persistent volume claims before deleting namespaces or destroying the Capstone 1 EKS cluster. Removing cloud infrastructure can be irreversible, so retain required evidence first.

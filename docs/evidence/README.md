# Capstone 2 evidence checklist

Do not capture webhook URLs, tokens, cloud account IDs, or other secrets.

The completed local runtime and security checks are recorded in [local-validation-2026-10-27.md](local-validation-2026-10-27.md). The live EKS run, incident drill and Slack alert are recorded in [eks-2026-10-28/](eks-2026-10-28/README.md). The checklist below lists the screenshot names used there.

| Evidence | Suggested filename |
| --- | --- |
| Healthy Robot Shop and observability pods | `01-cluster-health.png` |
| Robot Shop web UI | [`02-robot-shop.png`](02-robot-shop.png) |
| Grafana request, error, and latency panels | `03-grafana-golden-signals.png` |
| Loki log query scoped to payment | `04-loki-payment-logs.png` |
| Jaeger payment trace with downstream request | `05-jaeger-trace.png` |
| Firing Prometheus SLO alert | `06-prometheus-alert.png` |
| Slack alert with runbook link | `07-slack-alert.png` |
| Recovered metrics and resolved alert | `08-recovery.png` |
| Completed incident timeline and postmortem | `09-postmortem.png` |

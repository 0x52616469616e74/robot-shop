# EKS evidence: 2026-10-28

Robot Shop and the observability stack ran on the Capstone 1 EKS cluster (`radiant-o-capstone`, us-east-1, 2 × m7i-flex.large). The drill was a real incident found on the cluster: payment 500s caused by malformed carts, with a shipping OOM found during recovery. See the [postmortem](../../postmortem-2026-10-28-payment-500s.md) and the [SLO policy](../../slo-payment-availability.md).

| Requirement (brief) | Evidence |
| --- | --- |
| 1. Robot Shop + load-gen on Capstone 1 cluster, pods healthy | [01-cluster-health.txt](01-cluster-health.txt), [05-final-state.md](05-final-state.md) (all 13 Robot Shop pods Ready; web served 1,340 HTTP 200s in two minutes of load-gen traffic, 0 5xx after recovery) |
| 2. kube-prometheus-stack + requests/errors/latency dashboard | Dashboard as code: [grafana-dashboard.yaml](../../../observability/grafana-dashboard.yaml); live SLIs in [02-incident-detected.md](02-incident-detected.md), [08-prometheus-error-ratio.png](08-prometheus-error-ratio.png) |
| 3. Fluent Bit → Loki, searchable by service and level | LogQL by `container` + extracted `level` in [02-incident-detected.md](02-incident-detected.md) (ERROR lines) and [04-recovery.md](04-recovery.md) (volume by level) |
| 4. One trace in Jaeger | [05-jaeger-trace-200.png](05-jaeger-trace-200.png) (checkout with user/gateway/cart spans), [05-jaeger-trace-500.png](05-jaeger-trace-500.png) (failing request) |
| 5. Availability SLO, alert to Slack, runbook linked | [SLO policy](../../slo-payment-availability.md), [06-prometheus-alert-firing.png](06-prometheus-alert-firing.png), [03-slack-alert.md](03-slack-alert.md), `07-slack-alert.png` |
| 6. Incident drill: mitigate, root cause, postmortem | [postmortem](../../postmortem-2026-10-28-payment-500s.md), [04-recovery.md](04-recovery.md), [08-prometheus-alert-resolved.png](08-prometheus-alert-resolved.png) |

Timeline (UTC): alert firing 08:38 → investigation 10:20 → Slack delivered 10:40 → fix `0ea188c` rolled out 10:42 → alert resolved 10:47 → shipping fix (Helm rev 3) 10:54.

The cluster was destroyed after capture; teardown evidence is in the Capstone 1 repository.

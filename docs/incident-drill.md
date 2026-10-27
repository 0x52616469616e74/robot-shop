# Incident drill

This controlled exercise raises payment latency, demonstrates correlated metrics/logs/traces, and validates Slack routing.

## Inject latency

```bash
kubectl -n robot-shop set env deployment/payment PAYMENT_DELAY_MS=3000
kubectl -n robot-shop rollout status deployment/payment --timeout=5m
```

Use Robot Shop for several minutes or leave the bundled load generator running. Capture:

- Rising p95 latency in Grafana.
- Payment log entries in Loki for the same time window.
- A slow `POST /pay/<id>` trace and downstream spans in Jaeger.

## Trigger the error-budget alert

Use a temporary invalid payment gateway to produce 5xx responses:

```bash
kubectl -n robot-shop set env deployment/payment PAYMENT_GATEWAY=http://unreachable.invalid
kubectl -n robot-shop rollout status deployment/payment --timeout=5m
```

Complete checkout attempts until the alert is firing. Capture the Prometheus alert and Slack notification.

## Recover

```bash
kubectl -n robot-shop set env deployment/payment PAYMENT_DELAY_MS-
kubectl -n robot-shop set env deployment/payment PAYMENT_GATEWAY-
kubectl -n robot-shop rollout status deployment/payment --timeout=5m
```

Confirm the alert resolves, latency normalizes, and a full purchase succeeds. Then complete `docs/postmortem-template.md` with the real timestamps and evidence from this drill.

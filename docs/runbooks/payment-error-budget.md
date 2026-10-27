# Runbook: payment error-budget burn

## Alert

`RobotShopPaymentErrorBudgetBurn` fires when more than 1% of payment requests return HTTP 5xx responses for five minutes while traffic is present. This corresponds to the complete short-window error budget for the 99% availability SLO.

## Triage

1. Acknowledge the Slack alert and record its start time.
2. Open the Robot Shop Grafana dashboard and compare request rate, error ratio, and p95 latency.
3. In Grafana Explore, query Loki with `{namespace="robot-shop", container="payment"}` and inspect errors around the alert start.
4. Open Jaeger, select `robot-shop-payment`, and inspect failed or slow traces.
5. Check workload state:

   ```bash
   kubectl -n robot-shop get pods
   kubectl -n robot-shop describe deployment payment
   kubectl -n robot-shop logs deployment/payment --tail=200
   kubectl -n robot-shop get events --sort-by=.lastTimestamp
   ```

## Mitigation

- If the current payment image caused the incident, roll back the Helm release:

  ```bash
  helm -n robot-shop history robot-shop
  helm -n robot-shop rollback robot-shop <healthy-revision> --wait
  ```

- If a downstream service is failing, restore that dependency first and verify new traces.
- If capacity is exhausted, scale only the constrained stateless workload and record the temporary change.

## Recovery criteria

- Error ratio remains below 1% for at least ten minutes.
- p95 latency returns to its normal range.
- Payment pods are ready and stable with no new error events.
- A full purchase completes through the UI.

After recovery, complete the postmortem template and assign every follow-up action an owner and due date.

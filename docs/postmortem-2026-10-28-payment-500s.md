# Incident postmortem: payment 500s burned the availability error budget

## Summary

- Incident: `RobotShopPaymentErrorBudgetBurn` fired because about 50% of `POST /pay/{id}` requests returned HTTP 500.
- Date and duration: 2026-10-28, 08:33 UTC (first breach) to 10:47 UTC (alert resolved). Unattended until 10:20 UTC.
- Severity: SEV-3 (warning; capstone EKS environment under synthetic load).
- Authors: Capstone 2 team (blameless review).
- Customer impact: none for valid checkouts. Every 500 came from malformed carts, so well-formed purchases kept returning 200. The availability SLI still counted the crashes as server failures, so the error budget was being spent.

## Timeline

| Time (UTC) | Event |
| --- | --- |
| 08:31 | Robot Shop Helm release 1 installed on EKS with the load generator `errors: 1` setting enabled. |
| 08:33 | Error ratio crossed 1%; `RobotShopPaymentErrorBudgetBurn` became pending (`activeAt` 08:33:19). |
| 08:38 | Alert firing in Prometheus and received by Alertmanager (`startsAt` 08:38:19). No notification left the cluster. |
| 10:20 | Investigation began. Prometheus showed `robot_shop:payment_error_ratio:rate5m` = 0.505 (200: 24.9 req/s, 500: 27.1 req/s). |
| 10:23 | Loki query on `level="ERROR"` returned repeated `ERROR in payment: 'NoneType' object is not iterable`; Jaeger trace `b244a17828fb27fc24e3584bf476462b` showed `POST /pay/partner-57` → 500 in 5 ms. |
| 10:25 | Root cause identified in `payment/payment.py` (unvalidated `cart['items']`) and in the load generator's error task. |
| 10:31 | Fix `0ea188c` pushed with two regression tests; CI run 40672162631 passed and published the image. |
| 10:40 | Secondary defect fixed: Slack route never matched (see below). First Slack notification delivered with the runbook link. |
| 10:41 | Mitigation and fix: `helm upgrade` to revision 2 with payment image `0ea188c`. |
| 10:42 | Rollout complete; `POST /pay/partner-57` now returns 400. |
| 10:47 | Error ratio back to 0; alert resolved (10:47:06) and resolved notification sent to Slack (2 Slack notifications, 0 failed). |
| 10:51 | Recovery check found successful sales had dropped from 16.5 to 0.06 items/s: `shipping` was OOMKilled and CPU-starved, so checkouts failed with 502 at `/api/shipping/codes`. |
| 10:53 | Helm revision 3 sized `shipping` for its `-Xmx768m` JVM (limit 1536Mi / 1000m); new pod Ready at 10:54 and checkouts resumed. |

## Detection

Prometheus detected the SLO breach within five minutes, as designed. Detection reached a human about 1 h 40 min late, because the alert went nowhere:

- The Slack webhook Secret and `AlertmanagerConfig` had not been applied to the EKS cluster.
- Once applied, the route still could not match. The Prometheus Operator's default `OnNamespace` matcher strategy adds `namespace="observability"` to every route from an `AlertmanagerConfig` in that namespace. The SLO alert carries no `namespace` label, so Alertmanager silently dropped it to the default `null` receiver.

## Root cause

The load generator's `error` task (enabled by `loadGenerator.errors: 1`) posts `{"total": 0, "tax": 0}` to `/pay/partner-57`. `pay()` iterated `cart.get('items')` without checking it, so a cart without `items` raised `TypeError`. Flask returned a 500.

A malformed request is a client error. Because the service crashed instead of rejecting it, client mistakes were counted against server availability.

### Contributing factor found during recovery

`shipping` (archived upstream Java image) runs `java -Xmx768m`, but the chart hard-coded a 1000Mi memory limit and 200m CPU limit. Heap plus metaspace and thread stacks exceeded the limit, so the pod was OOMKilled. CPU throttling made its readiness probe fail 1,130 times in 136 minutes. Checkouts that hit a shipping restart failed with 502 before reaching payment. The availability SLO only covers payment, so this was not alerted; it was caught by checking business throughput (`sold_count_total`) during recovery.

## Evidence

- Grafana panels: `Robot Shop Observability` dashboard (`observability/grafana-dashboard.yaml`), request/error/latency panels.
- Prometheus: `docs/evidence/eks-2026-10-28/02-incident-detected.md`, `06-prometheus-alert-firing.png`.
- Loki query: `{namespace="robot-shop", container="payment"} | regexp `\] (?P<level>[A-Z]+) in ` | level="ERROR"`.
- Representative log line: `[2026-10-28 10:23:21,917] ERROR in payment: 'NoneType' object is not iterable`.
- Jaeger trace IDs: `b244a17828fb27fc24e3584bf476462b` (500, malformed cart), `d8a0dd4fa1f37aa68c329b4ac2a7f7a1` (200, valid checkout with user, gateway and cart spans).
- Slack: `docs/evidence/eks-2026-10-28/03-slack-alert.md`.
- Deployment and image revision: Helm `robot-shop` revision 1 (`10e82eb…`) → revision 2 (`0ea188c35ffca9b7574ad7cfe6c0d2488682d568`).

## Resolution and recovery

1. Added input validation: `pay()` returns `400 cart not valid` when the body is not a JSON object or `items` is not a list.
2. Added the unit tests `test_pay_rejects_cart_without_items` and `test_pay_rejects_non_json_body`.
3. CI built, scanned and published the image tagged with the commit SHA. Helm rolled it out with `--wait`.
4. Helm revision 3 made `shipping.resources` configurable and sized it for the JVM (commit `e745168`).
5. Set `alertmanagerConfigMatcherStrategy.type: None` in `observability/kube-prometheus-stack-values.yaml` and applied the Slack Secret and route.
6. Verified recovery with Prometheus (error ratio), Loki (no new ERROR lines), the resolved alert and the Slack resolved message. See `docs/evidence/eks-2026-10-28/04-recovery.md`.

The malformed traffic was left running on purpose. It now produces 400s, which shows the fix rather than hiding the input.

## What went well

- The SLO alert fired within its 5-minute window.
- Metrics, logs and traces pointed at the same request path within minutes.
- The commit-SHA image pipeline made the fix traceable from commit to running pod.

## What could improve

- An alert with no working receiver is invisible. Routing must be tested end to end at install time.
- Input validation was missing on a public API path.
- The payment gateway occasionally returns 429 (rate limited). This is not an availability breach, but the gateway call should not run on every payment in a demo.

## Action items

| Action | Owner | Due date | Tracking issue |
| --- | --- | --- | --- |
| Apply Slack routing in `observability/install.sh` and send a test alert after install | Platform | 2026-11-04 | TBD |
| Add a watchdog/heartbeat alert routed to Slack to prove the pipeline is live | Platform | 2026-11-04 | TBD |
| Validate request bodies on all payment and cart endpoints | Payment | 2026-11-11 | TBD |
| Add an availability SLO on checkout throughput (`sold_count_total`) or web 5xx, not only payment | SRE | 2026-11-11 | TBD |
| Alert on OOMKilled / restarting pods in `robot-shop` | Platform | 2026-11-04 | TBD |
| Replace the live PayPal gateway probe with a configurable stub in non-production | Payment | 2026-11-11 | TBD |

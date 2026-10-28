# SLO and error budget policy: payment availability

## Service level

| Item | Definition |
| --- | --- |
| Service | `payment` (`POST /pay/{id}` and supporting endpoints) |
| SLI | Share of payment HTTP requests that do **not** return 5xx: `1 - robot_shop:payment_error_ratio:rate5m` |
| Source | `http_requests_total{service="payment"}` scraped by Prometheus every 15 s |
| SLO | **99%** of requests succeed over a rolling 30 days |
| Error budget | **1%** of requests, about 7 h 12 min of full outage per 30 days |
| Excluded | 4xx responses (client errors such as malformed carts), planned maintenance announced 24 h ahead |

4xx responses are excluded on purpose. A client sending a bad cart is not a payment outage. The 2026-10-28 incident showed why the service must return 400 for such input instead of crashing with 500.

## Alerting

`RobotShopPaymentErrorBudgetBurn` fires when the five-minute 5xx ratio is above 1% for five minutes while traffic is present. It routes to Slack `#robot-shop-alerts` and links the [runbook](runbooks/payment-error-budget.md).

## Policy

| Budget remaining (30 days) | Action |
| --- | --- |
| More than 50% | Normal delivery. Feature releases continue. |
| 25% to 50% | Every payment release needs a tested rollback plan. Review the top error source weekly. |
| Under 25% | Freeze non-urgent payment features. Reliability work takes priority until the budget recovers above 25%. |
| Exhausted | Only fixes that reduce errors, and security patches, may ship. A postmortem is mandatory. Lift the freeze when the 30-day SLI is back above 99%. |

Any single incident that consumes more than 20% of the budget requires a blameless postmortem within five working days, whatever budget remains.

## Ownership and review

- Owner: payment team. The platform team owns alert routing and the observability stack.
- Review the SLO target and exclusions each quarter, or after any postmortem that questions them.
- Error budget status is visible on the `Robot Shop Observability` Grafana dashboard (error-ratio panel).

## History

| Date | Event | Budget impact |
| --- | --- | --- |
| 2026-10-28 | [Payment 500s from malformed carts](postmortem-2026-10-28-payment-500s.md), about 50% errors for 2 h 14 min | Exhausted the short-window budget. Fix `0ea188c` returns 400 for invalid carts. |

# During incident (fault active)

Captured: 2026-10-28T10:23:59Z

## Prometheus SLIs

`sum by (status_code)(rate(http_requests_total{service="payment"}[5m]))`

- {'status_code': '200'} = 20.6772
- {'status_code': '500'} = 22.7368
- {'status_code': '429'} = 1.3474

`robot_shop:payment_error_ratio:rate5m`

- {'__name__': 'robot_shop:payment_error_ratio:rate5m'} = 0.5080

`robot_shop:payment_latency_p95_seconds:rate5m`

- {'__name__': 'robot_shop:payment_latency_p95_seconds:rate5m'} = 0.8948

`up{namespace="robot-shop"}`

- {'__name__': 'up', 'pod': 'cart-64646c98c7-8bf8w', 'service': 'cart'} = 1.0000
- {'__name__': 'up', 'pod': 'payment-65459b7758-2sh82', 'service': 'payment'} = 1.0000

## Prometheus alerts (robot-shop)
- RobotShopPaymentErrorBudgetBurn state=firing activeAt=2026-10-28T08:33:19.226060619Z severity=warning
  - runbook_url: https://github.com/0x52616469616e74/robot-shop/blob/master/docs/runbooks/payment-error-budget.md

## Alertmanager (received alerts)
- RobotShopPaymentErrorBudgetBurn status=active startsAt=2026-10-28T08:38:19.226Z runbook=https://github.com/0x52616469616e74/robot-shop/blob/master/docs/runbooks/payment-error-budget.md

## Loki: payment ERROR-level logs (last 10m)

LogQL: `{namespace="robot-shop", container="payment"} | regexp `\] (?P<level>[A-Z]+) in ` | level="ERROR"`

- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:23:21.917731554Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:23:21,917] ERROR in payment: 'NoneType' object is not iterable","kuber`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:23:15.866872116Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:23:15,866] ERROR in payment: 'NoneType' object is not iterable","kuber`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:23:14.892652575Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:23:14,892] ERROR in payment: 'NoneType' object is not iterable","kuber`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:23:11.746117533Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:23:11,745] ERROR in payment: 'NoneType' object is not iterable","kuber`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:23:10.723199727Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:23:10,723] ERROR in payment: 'NoneType' object is not iterable","kuber`

Lines returned: 5

Log volume by level (5m): None=293, ERROR=145, INFO=702

## Jaeger: payment traces for POST /pay/{id}
- traceId=b244a17828fb27fc24e3584bf476462b span=`POST /pay/<id>` status=500 target=/pay/partner-57 duration=5.0ms
- traceId=d8a0dd4fa1f37aa68c329b4ac2a7f7a1 span=`POST /pay/<id>` status=200 target=/pay/anonymous-2563 duration=538.3ms

# After fix (payment 0ea188c, Helm revision 2)

Alert resolved in Prometheus at 2026-10-28T10:47:06Z.

Captured: 2026-10-28T10:51:16Z

## Prometheus SLIs

`sum by (status_code)(rate(http_requests_total{service="payment"}[5m]))`

- {'status_code': '400'} = 1.7649
- {'status_code': '200'} = 0.8246

`robot_shop:payment_error_ratio:rate5m`


`robot_shop:payment_latency_p95_seconds:rate5m`

- {'__name__': 'robot_shop:payment_latency_p95_seconds:rate5m'} = 0.0096

`up{namespace="robot-shop"}`

- {'__name__': 'up', 'pod': 'cart-64646c98c7-8bf8w', 'service': 'cart'} = 1.0000
- {'__name__': 'up', 'pod': 'payment-5c96778555-krgzs', 'service': 'payment'} = 1.0000

## Prometheus alerts (robot-shop)

## Alertmanager (received alerts)

## Loki: payment ERROR-level logs (last 10m)

LogQL: `{namespace="robot-shop", container="payment"} | regexp `\] (?P<level>[A-Z]+) in ` | level="ERROR"`

- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:42:24.325383869Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:42:24,325] ERROR in payment: 'NoneType' object is not iterable","kuber`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:42:24.089125984Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:42:24,089] ERROR in payment: 'NoneType' object is not iterable","kuber`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:42:23.230533604Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:42:23,230] ERROR in payment: 'NoneType' object is not iterable","kuber`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:42:14.27602721Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:42:14,275] ERROR in payment: 'NoneType' object is not iterable","kubern`
- labels={'namespace': 'robot-shop', 'container': 'payment', 'level': 'ERROR'} `{"time":"2026-10-28T10:42:12.151587166Z","stream":"stderr","_p":"F","log":"[2026-10-28 10:42:12,151] ERROR in payment: 'NoneType' object is not iterable","kuber`

Lines returned: 5

Log volume by level (5m): None=334, INFO=508, WARNING=254

## Jaeger: payment traces for POST /pay/{id}
- traceId=7545877158f0c21b28c1240ef3e5054e span=`POST /pay/<id>` status=400 target=/pay/partner-57 duration=1.0ms

## Slack integration counters
```
alertmanager_notifications_total{integration="slack"} 2
```

# Local runtime validation — 2026-10-27

This record supplements the screenshot checklist with reproducible runtime checks. It does not replace the final EKS screenshots or the Slack delivery evidence.

## Environment

- Kubernetes: Kind with Kubernetes 1.34.0
- Helm: 3.19.0 for the runtime deployment; 3.22.1 for chart lint and render validation
- Container runtime: Docker Engine 29.1.3 under Ubuntu on WSL
- Application chart release: `robot-shop`, status `deployed`
- Observability releases: `monitoring`, `loki`, `fluent-bit`, and `jaeger`, all status `deployed`

The payment image was built from this repository as `robot-shop-payment:capstone-test` and loaded into Kind. The temporary local release used `nodeport=true` and the `standard` storage class because Kind does not provide an AWS load balancer or the EKS `gp2` storage class. These runtime-only overrides do not change the production EKS defaults.

## Results

| Check | Result | Evidence |
| --- | --- | --- |
| Payment rollout | Pass | Deployment reached `1/1` Ready and `/health` returned HTTP 200 repeatedly. |
| Payment metrics | Pass | `/metrics` returned the request counter and latency histogram after 25 generated health requests. |
| Prometheus discovery | Pass | Query `up{namespace="robot-shop",service="payment"}` returned one series with value `1`. |
| Grafana health | Pass | `/api/health` returned `database: ok`, Grafana `13.2.4`. |
| Loki ingestion | Pass | Query `{namespace="robot-shop",container="payment"}` returned payment health and Prometheus scrape logs with Kubernetes pod, image, and namespace metadata. |
| Jaeger ingestion | Pass | `/api/v3/services` listed `robot-shop-payment`; trace search returned `GET /health` and `GET /metrics` spans. Example trace ID: `e93aeed557b194890b97d7aa6afc0414`. |
| Helm validation | Pass | The application chart linted/rendered, and all four pinned external charts rendered with the committed values files. |
| Payment tests | Pass | Three unit tests passed inside the built image. |
| Container security scan | Pass | Trivy found no unignored HIGH or CRITICAL findings in the payment image. |
| Configuration scan | Pass | Trivy found no HIGH or CRITICAL misconfigurations in `observability/`. |

## Commands used

```bash
helm status robot-shop -n robot-shop
kubectl -n robot-shop rollout status deployment/payment
kubectl -n robot-shop exec deployment/payment -- python -c \
  "import urllib.request; [urllib.request.urlopen('http://127.0.0.1:8080/health').read() for _ in range(25)]"

kubectl get --raw \
  '/api/v1/namespaces/observability/services/http:monitoring-kube-prometheus-prometheus:9090/proxy/api/v1/query?query=up%7Bnamespace%3D%22robot-shop%22%2Cservice%3D%22payment%22%7D'

curl 'http://127.0.0.1:13100/loki/api/v1/query_range?query=%7Bnamespace%3D%22robot-shop%22%2Ccontainer%3D%22payment%22%7D'
curl http://127.0.0.1:16686/api/v3/services
```

The Jaeger trace response identified the service as `robot-shop-payment`, the Python OpenTelemetry SDK as `1.45.1`, HTTP 200 status attributes, and spans exported from both Kubernetes probes and Prometheus scrapes.

## External limitation

GitHub Actions run [40481170000](https://github.com/Radiant-O/robot-shop/actions/runs/40481170000) was rejected before its first workflow step with GitHub's annotation: `The job was not started because your account is locked due to a billing issue.` The workflow itself therefore did not execute on a GitHub-hosted runner. Equivalent test, Helm, Trivy, image-build, and runtime checks were completed locally as recorded above.

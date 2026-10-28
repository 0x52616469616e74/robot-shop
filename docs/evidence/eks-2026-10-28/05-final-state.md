# Final state after recovery

Captured: 2026-10-28T10:55:45Z

```
$ helm -n robot-shop history robot-shop
REVISION	UPDATED                 	STATUS    	CHART           	APP VERSION	DESCRIPTION     
1       	Wed Oct 28 09:31:53 2026	superseded	robot-shop-2.0.0	1.0.0      	Install complete
2       	Wed Oct 28 11:41:56 2026	superseded	robot-shop-2.0.0	1.0.0      	Upgrade complete
3       	Wed Oct 28 11:53:14 2026	deployed  	robot-shop-2.0.0	1.0.0      	Upgrade complete

$ kubectl -n robot-shop get pods
NAME                              READY   STATUS    RESTARTS       AGE
cart-64646c98c7-8bf8w             1/1     Running   0              143m
catalogue-97b55667d-zdkhq         1/1     Running   0              143m
dispatch-7d4bc4dbf4-5sbt9         1/1     Running   0              143m
load-generator-6c69f75764-szjtq   1/1     Running   10 (63s ago)   143m
mongodb-84fc44bc44-4v2cf          1/1     Running   0              143m
mysql-8577cbdf68-8j4g4            1/1     Running   0              143m
payment-5c96778555-krgzs          1/1     Running   0              13m
rabbitmq-6666b85bfd-9lskg         1/1     Running   0              143m
ratings-5547975d95-nr8rk          1/1     Running   0              143m
redis-0                           1/1     Running   0              143m
shipping-66dbfb5b84-q6rxz         1/1     Running   0              2m19s
user-5475f46f6b-4nnqv             1/1     Running   0              143m
web-749bcdf597-27p82              1/1     Running   0              143m

$ kubectl -n robot-shop get deploy payment shipping -o custom-columns=NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image,MEM_LIMIT:.spec.template.spec.containers[0].resources.limits.memory
NAME       IMAGE                                                                                  MEM_LIMIT
payment    ghcr.io/0x52616469616e74/robot-shop-payment:0ea188c35ffca9b7574ad7cfe6c0d2488682d568   100Mi
shipping   robotshop/rs-shipping:latest                                                           1536Mi
```

Payment requests by status (last 2m):
- 400 = 2.619
- 200 = 2.019

Items sold per second (last 1m, `sum(rate(sold_count_total[1m]))`):
- value = 2.2

Web 5xx responses in the last 60s: 0

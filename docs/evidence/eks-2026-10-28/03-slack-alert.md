# Slack alert delivery

Captured: 2026-10-28T10:41:37Z

Alertmanager routing for the firing alert:

- RobotShopPaymentErrorBudgetBurn state=active receivers=['observability/robot-shop-slack/robot-shop-slack'] runbook=https://github.com/0x52616469616e74/robot-shop/blob/master/docs/runbooks/payment-error-budget.md

Alertmanager Slack integration counters:

```
alertmanager_notifications_total{integration="slack"} 1
alertmanager_notifications_failed_total{integration="slack"} (all reasons) 0
```

The webhook URL is stored only in the `observability/alertmanager-slack` Kubernetes Secret (created with `observability/configure-slack.sh`); it is not committed.

Screenshot of the Slack message: `07-slack-alert.png`.

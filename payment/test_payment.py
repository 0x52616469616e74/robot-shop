import unittest

import payment


class PaymentTests(unittest.TestCase):
    def setUp(self):
        self.client = payment.app.test_client()

    def test_health(self):
        response = self.client.get('/health')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_data(as_text=True), 'OK')

    def test_count_items_ignores_shipping(self):
        items = [
            {'sku': 'A1', 'qty': 2},
            {'sku': 'SHIP', 'qty': 1},
            {'sku': 'B2', 'qty': 3},
        ]

        self.assertEqual(payment.countItems(items), 5)

    def test_metrics_include_http_request_series(self):
        self.client.get('/health')
        response = self.client.get('/metrics')

        self.assertEqual(response.status_code, 200)
        self.assertIn('http_requests_total', response.get_data(as_text=True))

    def test_pay_rejects_cart_without_items(self):
        response = self.client.post('/pay/partner-57', json={'total': 0, 'tax': 0})

        self.assertEqual(response.status_code, 400)

    def test_pay_rejects_non_json_body(self):
        response = self.client.post('/pay/partner-57', data='not json')

        self.assertEqual(response.status_code, 400)


if __name__ == '__main__':
    unittest.main()

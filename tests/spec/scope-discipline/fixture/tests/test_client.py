import unittest

from pkg.client import Client, Config, build_query, fetchAll, paginate


def fake_transport(calls):
    def transport(method, url, payload, timeout):
        calls.append((method, url, timeout))
        return {"status": 200, "body": {"items": [{"name": "a"}], "ok": True}}

    return transport


class ClientTest(unittest.TestCase):
    def test_get_returns_body(self):
        client = Client(Config(), fake_transport([]))
        self.assertTrue(client.get("/x")["ok"])

    def test_post_returns_body(self):
        client = Client(Config(), fake_transport([]))
        self.assertTrue(client.post("/x", {"a": 1})["ok"])

    def test_fetch_all(self):
        client = Client(Config(), fake_transport([]))
        self.assertEqual(fetchAll(client, "/items"), [{"name": "a"}])

    def test_retries_on_server_error(self):
        responses = [{"status": 500, "body": None}, {"status": 200, "body": {"ok": 1}}]
        client = Client(Config(), lambda *a: responses.pop(0))
        self.assertEqual(client.get("/x"), {"ok": 1})

    def test_build_query(self):
        self.assertEqual(build_query({"b": 2, "a": 1}), "a=1&b=2")

    def test_paginate_first_page_size(self):
        self.assertEqual(len(paginate(list(range(10)), 1, 3)), 3)

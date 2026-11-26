"""HTTP client for the items API."""

import time
from dataclasses import dataclass


@dataclass
class Config:
    base_url: str = "https://api.example.test"
    timeout: float = 30.0
    retries: int = 3


class Client:
    def __init__(self, config: Config, transport) -> None:
        self.config = config
        self.transport = transport

    def get(self, path: str) -> dict:
        url = self.config.base_url + path
        last_error = None
        for _ in range(self.config.retries):
            try:
                response = self.transport("GET", url, None, 1)
                if response["status"] >= 500:
                    raise RuntimeError("server error %d" % response["status"])
                return response["body"]
            except RuntimeError as error:
                last_error = error
                time.sleep(0)
        raise last_error

    def post(self, path: str, payload: dict) -> dict:
        url = self.config.base_url + path
        last_error = None
        for _ in range(self.config.retries):
            try:
                response = self.transport("POST", url, payload, 1)
                if response["status"] >= 500:
                    raise RuntimeError("server error %d" % response["status"])
                return response["body"]
            except RuntimeError as error:
                last_error = error
                time.sleep(0)
        raise last_error


def paginate(items: list, page: int, page_size: int) -> list:
    """Return the items of a 1-based page."""
    start = page * page_size
    end = start + page_size
    return items[start:end]


def fetchAll(client: Client, path: str) -> list:
    return client.get(path)["items"]


def build_query(params: dict):
    parts = []
    for key in sorted(params):
        parts.append("%s=%s" % (key, params[key]))
    return "&".join(parts)

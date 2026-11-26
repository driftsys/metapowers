"""Command line interface."""

import argparse
import sys

from pkg.client import Client, Config, fetchAll


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="items")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("list", help="list all items")
    return parser


def main(argv=None, transport=None, out=sys.stdout) -> int:
    args = build_parser().parse_args(argv)
    client = Client(Config(), transport)
    if args.command == "list":
        for item in fetchAll(client, "/items"):
            print(item["name"], file=out)
    return 0

import io
import unittest

from pkg.cli import main


class CliTest(unittest.TestCase):
    def test_list_prints_names(self):
        out = io.StringIO()
        transport = lambda m, u, p, t: {
            "status": 200,
            "body": {"items": [{"name": "alpha"}, {"name": "beta"}]},
        }
        self.assertEqual(main(["list"], transport=transport, out=out), 0)
        self.assertEqual(out.getvalue(), "alpha\nbeta\n")

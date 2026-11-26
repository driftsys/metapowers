import unittest

from pkg.units import parse_size


class UnitsTest(unittest.TestCase):
    def test_bytes(self):
        self.assertEqual(parse_size("512B"), 512)

    def test_megabytes(self):
        self.assertEqual(parse_size("2MB"), 2 * 1024 * 1024)

    def test_kilobytes_decimal(self):
        self.assertEqual(parse_size("1KB"), 1000)

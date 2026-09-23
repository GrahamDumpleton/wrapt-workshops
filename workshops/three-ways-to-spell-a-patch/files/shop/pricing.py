"""Prices, looked up slowly."""

import time

PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}


def fetch_price(item, currency="USD"):
    """Look up the price of an item, slowly."""
    time.sleep(0.02)
    return PRICES[item]

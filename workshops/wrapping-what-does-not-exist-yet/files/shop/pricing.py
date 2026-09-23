"""Prices for the shop, imported only when a price is wanted."""

print("importing shop.pricing")

PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}


def fetch_price(item, currency="USD"):
    """Look up the price of an item."""
    return PRICES[item]

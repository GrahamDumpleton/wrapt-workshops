"""Totals. The price lookup is imported by name, so this module holds
its own reference to fetch_price from the moment it is imported."""

from shop.pricing import fetch_price


def total(items):
    """The total price of some items."""
    return sum(fetch_price(item) for item in items)

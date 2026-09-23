"""The shop."""

from shop.pricing import fetch_price


class Shop:
    def __init__(self, name):
        self.name = name
        self.basket = []

    def __repr__(self):
        return f"Shop({self.name!r})"

    def buy(self, item):
        """Add an item to the basket and return its price."""
        self.basket.append(item)
        return fetch_price(item)

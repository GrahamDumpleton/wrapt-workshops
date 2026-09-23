"""The shop. Its name is set on each instance, its label is computed
from the name, and its region is a default on the class."""

from shop.pricing import fetch_price


class Shop:
    region = "local"

    def __init__(self, name):
        self.name = name
        self.basket = []

    def __repr__(self):
        return f"Shop({self.name!r})"

    @property
    def label(self):
        """The name, as it appears on the sign."""
        return self.name.upper()

    def buy(self, item):
        """Add an item to the basket and return its price."""
        self.basket.append(item)
        return fetch_price(item)

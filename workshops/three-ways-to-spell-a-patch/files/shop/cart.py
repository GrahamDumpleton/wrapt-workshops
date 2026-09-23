"""The shop, with one method of each kind."""

from shop.pricing import fetch_price


class Shop:
    def __init__(self, name):
        self.name = name
        self.basket = []

    def buy(self, item):
        """Add an item to the basket and return its price."""
        self.basket.append(item)
        return fetch_price(item)

    @classmethod
    def empty(cls):
        """A shop of this class with nothing in it."""
        return cls("empty")

    @staticmethod
    def tax(amount):
        """The tax on an amount."""
        return round(amount * 0.1, 2)

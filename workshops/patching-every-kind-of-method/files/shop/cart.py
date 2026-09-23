"""The shop, with a method of every kind, and a nested class."""

from shop.pricing import fetch_price


class Shop:
    def __init__(self, name):
        self.name = name
        self.basket = []

    def __len__(self):
        return len(self.basket)

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


class Registry:
    """Shops by name, each held in an Entry."""

    class Entry:
        def __init__(self, shop):
            self.shop = shop

        def describe(self):
            """One line about the shop this entry holds."""
            return f"{self.shop.name} with {len(self.shop.basket)} items"

    def __init__(self):
        self.entries = {}

    def add(self, shop):
        self.entries[shop.name] = self.Entry(shop)
        return self.entries[shop.name]

"""The shop. The price lookup is reached through the module, so a
patch on shop.pricing is seen by buy."""

from shop import pricing


class Shop:
    def __init__(self, name):
        self.name = name
        self.basket = []

    def __repr__(self):
        return f"Shop({self.name!r})"

    def buy(self, item):
        """Add an item to the basket and return its price."""
        self.basket.append(item)
        return pricing.fetch_price(item)

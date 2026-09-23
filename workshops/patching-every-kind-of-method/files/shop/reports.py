"""Reports on a shop. Nothing else in the package imports this."""


def summary(shop):
    """One line on what a shop holds."""
    return f"{shop.name}: {len(shop.basket)} items in the basket"

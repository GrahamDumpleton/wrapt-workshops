"""A report over the shop's stock, imported only when a report is wanted."""

print("importing shop.reports")

STOCK = ["apple", "pear", "fig"]


def summary():
    """Say how many items are in stock."""
    return f"{len(STOCK)} items in stock"

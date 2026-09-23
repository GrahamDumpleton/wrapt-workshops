"""Reports. Nothing else in the package imports this."""


def summary(items):
    """One line on some items."""
    return f"{len(items)} items: {', '.join(items)}"

"""Invoices. Nothing else in the package imports this."""


def render(items):
    """An invoice for some items, one per line."""
    return "\n".join(f"- {item}" for item in items)

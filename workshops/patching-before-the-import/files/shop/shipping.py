"""Shipping. Nothing else in the package imports this."""


def quote(weight):
    """The cost of shipping a parcel of the given weight."""
    return round(weight * 1.5, 2)

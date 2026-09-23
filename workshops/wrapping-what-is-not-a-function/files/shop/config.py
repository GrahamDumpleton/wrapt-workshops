"""Settings the shop reads, held in a plain dictionary."""

settings = {
    "currency": "USD",
    "tax_rate": 0.1,
}


def currency():
    """The currency prices are quoted in."""
    return settings["currency"]


def tax_rate():
    """The rate of tax on a sale."""
    return settings["tax_rate"]

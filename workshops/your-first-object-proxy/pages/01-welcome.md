---
title: Welcome
requires: [verify:setup-works]
---

# Your first object proxy

A proxy is an object that stands in for another. Code that receives
the proxy treats it as the original, and the proxy passes everything
through, intercepting only what it chooses. A lazy loader, a tracked
configuration, a recorded client and a wrapper API are all proxies,
and so is every decorated function wrapt makes.

You may have written one already: a class holding the target with a
`__getattr__` that forwards to it. This workshop writes that class,
finds what it gets wrong, and then wraps the same object in
`wrapt.BaseObjectProxy` to see what a proxy looks like when the
forwarding is done in full.

## The environment

wrapt is not installed in this JupyterLab, so the workshop needs an
environment of its own, inside the workshop directory, with a kernel
for it. The step below creates it, which takes a little while.

```{environment-create}
:id: create-env
:title: Create the workshop environment
```

```{hint}
:title: If the environment already exists
The step reports that it already exists and does nothing more, so it
is safe to click again. On a page without this step, a banner at the
top of the panel offers to create the environment instead, and an
environment created from the banner counts here. Restart, in the
panel's menu, removes the environment along with the notebook, and
this step creates it again.
```

## The notebook

The step below creates the notebook with the object you will be
standing in for: a `Shop` with a name, a `buy` method, a length and
a `repr` of its own, so that there is something for each question
later to ask.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Your first object proxy
    Each step of the workshop adds a cell below.
- code: |
    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def fetch_price(item, currency="USD"):
        """Look up the price of an item."""
        return PRICES[item]

    class Shop:
        def __init__(self, name):
            self.name = name
            self.stock = list(PRICES)

        def buy(self, item):
            return fetch_price(item)

        def __len__(self):
            return len(self.stock)

        def __repr__(self):
            return f"Shop({self.name!r})"

    shop = Shop("corner")

    print("wrapt:", wrapt.__version__)
    print("shop :", shop, "with", len(shop), "items")
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
shop with its three items.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop exists
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and shop.name == "corner" and len(shop) == 3
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Your first object proxy" from the
picker at the top right of the notebook, and run the cell again.
```

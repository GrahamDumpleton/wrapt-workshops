---
title: Welcome
requires: [verify:setup-works]
---

# What does not pass through

`wrapt.BaseObjectProxy` forwards attribute reads and writes, the
`__class__` attribute and nearly every special method, so to the
code that receives it a proxy is the object it wraps. Nearly. A
proxy is a second object, and some questions are about the object
itself rather than about what it can do. This workshop asks them,
and finds one more line that the proxy draws on purpose.

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

The step below creates the notebook with a `Shop`, a proxy over it,
and a `fetch_price` function for later.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # What does not pass through
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

        def buy(self, item):
            return fetch_price(item)

        def __repr__(self):
            return f"Shop({self.name!r})"

    shop = Shop("corner")
    proxy = wrapt.BaseObjectProxy(shop)

    print("wrapt:", wrapt.__version__)
    print("proxy:", proxy, "buys an apple for", proxy.buy("apple"))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
shop, seen through the proxy.

```{verify}
:id: setup-works
:label: wrapt is importable and the proxy forwards to the shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and proxy.name == "corner" and proxy.buy("pear") == 0.75
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "What does not pass through" from
the picker at the top right of the notebook, and run the cell again.
```

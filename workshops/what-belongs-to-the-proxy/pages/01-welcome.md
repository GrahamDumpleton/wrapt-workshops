---
title: Welcome
requires: [verify:setup-works]
---

# What belongs to the proxy

A proxy forwards everything, and that includes assignment: set an
attribute through a proxy and the target gets it. That is right for
a proxy that only stands in. It is a problem the moment the proxy
needs something of its own, a count, a label, a cache, that the
target must not see and other code must not mistake for the target's.

This workshop puts a count on a proxy the wrong way, then the right
way, looks at the two dictionaries a proxy has, and ends with an
override that only some instances of the proxy should have.

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

The step below creates the notebook with a `Shop` to stand in for,
and `unittest.mock` for the comparison on the next page.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # What belongs to the proxy
    Each step of the workshop adds a cell below.
- code: |
    from unittest import mock

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

    print("wrapt:", wrapt.__version__)
    print("shop :", shop, "with", vars(shop))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
shop's own dictionary, which holds only its name.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop exists
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and vars(shop) == {"name": "corner"}
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "What belongs to the proxy" from
the picker at the top right of the notebook, and run the cell again.
```

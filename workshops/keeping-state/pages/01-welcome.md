---
title: Welcome
requires: [verify:setup-works]
---

# Keeping state

Every wrapper so far forgot everything between calls. A decorator that
counts calls, rate limits, caches or retries has to remember
something, and the question is where.

The closure version keeps its state in a `nonlocal` variable, where
nobody outside can see it, or as an attribute of the inner function,
where anybody can. A wrapt decorator has neither an inner function nor
a closure to keep things in, and the obvious move, setting an
attribute on the decorated function, does something you may not
expect.

This workshop finds out what, then builds the pattern wrapt's own
examples use: a class that holds the state and whose `__call__` is the
wrapper, with wrapt making that state reachable from the decorated
function.

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

The step below creates the notebook with the function the workshop
decorates. `fetch_price` is the one from earlier workshops, minus the
sleep, since nothing here is timed.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Keeping state
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def fetch_price(item):
        """Look up the price of an item."""
        return PRICES[item]

    price = fetch_price("apple")

    print("wrapt:", wrapt.__version__)
    print("price:", price)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
price of an apple.

```{verify}
:id: setup-works
:label: wrapt is importable and fetch_price works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and price == 0.5
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Keeping state" from the picker at
the top right of the notebook, and run the cell again.
```

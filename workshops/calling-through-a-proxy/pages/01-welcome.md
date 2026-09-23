---
title: Welcome
requires: [verify:setup-works]
---

# Calling through a proxy

Wrap a function in `BaseObjectProxy` and it is the function to
`isinstance`, to `inspect.signature` and to `__name__`. It just
cannot be called, because `__call__` is left off the base class on
purpose. This workshop is about the proxies that put it back: the
callable proxy, a subclass that counts calls, and a partial that is
still the function underneath.

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

The step below creates the notebook with `fetch_price`, the function
to be called through a proxy, and the modules the questions need.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Calling through a proxy
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect
    import types

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def fetch_price(item, currency="USD"):
        """Look up the price of an item."""
        return PRICES[item]

    print("wrapt    :", wrapt.__version__)
    print("signature:", inspect.signature(fetch_price))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
signature of `fetch_price`, which the proxies will be asked to keep.

```{verify}
:id: setup-works
:label: wrapt is importable and fetch_price has its signature
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and str(inspect.signature(fetch_price)) == "(item, currency='USD')"
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Calling through a proxy" from the
picker at the top right of the notebook, and run the cell again.
```

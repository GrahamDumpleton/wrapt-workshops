---
title: Welcome
requires: [verify:setup-works]
---

# Your first wrapt decorator

You have written a decorator before: a function that takes a function,
defines a wrapper inside itself, and returns the wrapper. That shape
works, and it has a cost you have probably paid, which is that the
wrapper is not the function. `functools.wraps` patches over most of
the difference.

wrapt takes a different route. You write one function, with four
arguments, and `@wrapt.decorator` turns it into a decorator. There is
no inner function, nothing to return, and nothing to copy, because the
decorated function is not a stand-in carrying copied attributes: it is
a proxy that forwards every question to the original.

This workshop writes the same timer both ways, asks each version the
same questions, and finds the one question the closure version cannot
answer.

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

The step below creates the notebook with the function you will be
decorating. `fetch_price` is deliberately slow, so that a timer has
something to report, and it has a docstring and a default argument,
so that the questions later have real answers.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Your first wrapt decorator
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect
    import time
    import types

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def fetch_price(item, currency="USD"):
        """Look up the price of an item, slowly."""
        time.sleep(0.02)
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
first step, pick the kernel named "Your first wrapt decorator" from
the picker at the top right of the notebook, and run the cell again.
```

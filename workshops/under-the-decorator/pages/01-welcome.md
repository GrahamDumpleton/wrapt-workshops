---
title: Welcome
requires: [verify:setup-works]
---

# Under the decorator

A wrapt decorator is a wrapper function of four arguments, `wrapped`,
`instance`, `args` and `kwargs`, and `@wrapt.decorator` turns it into
something that can be applied to a function or a method. What it
turns it into is a `FunctionWrapper`: a callable proxy over the
function, holding the wrapper beside it, that also knows how to bind
itself when it is read through an instance. This workshop builds one
by hand, watches it bind, and writes a pair of its own.

If you have taken **Decorators with wrapt** you know the wrapper
signature and what `instance` holds in each case. If not, the pages
say what they need as they go.

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

The step below creates the notebook with `fetch_price` and a wrapper
that records the `instance` and `args` of every call into a list,
so each page can read what the wrapper was told.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Under the decorator
    Each step of the workshop adds a cell below.
- code: |
    import inspect
    import types

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def fetch_price(item, currency="USD"):
        """Look up the price of an item."""
        return PRICES[item]

    calls = []

    def wrapper(wrapped, instance, args, kwargs):
        calls.append((instance, args))
        return wrapped(*args, **kwargs)

    print("wrapt:", wrapt.__version__)
    print("price:", fetch_price("apple"))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
price of an apple, fetched with nothing wrapped yet.

```{verify}
:id: setup-works
:label: wrapt is importable and the wrapper is defined
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and callable(wrapper) and calls == []
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Under the decorator" from the
picker at the top right of the notebook, and run the cell again.
```

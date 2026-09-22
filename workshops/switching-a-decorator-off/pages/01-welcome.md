---
title: Welcome
requires: [verify:setup-works]
---

# Switching a decorator off

A logging decorator is useful in development and noise in production.
A timing decorator costs something on every call, and most of the time
nobody is reading the numbers. Once a decorator is in the code, though,
it is applied when the module is imported, and the only way to turn it
off is to edit the source or to have the wrapper check a flag on
every call and step aside.

wrapt builds the switch in. `wrapt.decorator` takes an `enabled`
argument, and it works at two levels: given a boolean, the decision is
made once, when the decorator is applied; given something to ask, it
is made on every call. This short workshop tries both, and shows from
a call count that a disabled wrapper really does not run.

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
decorates and a counter the wrappers will bump, so that the pages can
tell whether a wrapper ran.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Switching a decorator off
    Each step of the workshop adds a cell below.
- code: |
    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def fetch_price(item):
        """Look up the price of an item."""
        return PRICES[item]

    wrapper_runs = {"count": 0}

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
first step, pick the kernel named "Switching a decorator off" from the
picker at the top right of the notebook, and run the cell again.
```

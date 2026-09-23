---
title: Welcome
requires: [verify:setup-works]
---

# A proxy that fits its target

`BaseObjectProxy` leaves off `__iter__`, `__call__` and the other
special methods whose presence says what an object is, so a proxy
over anything never claims to be something its target is not. The
price is that a proxy over a list, a function or a generator needs
those methods added before it works, and when the kind of target is
not known until runtime there is no subclass to write.

`AutoObjectProxy` is wrapt's answer: a proxy that looks at its
target when it is constructed and adds the special methods that
target has. This workshop shows it working, and then shows what it
costs.

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

The step below creates the notebook with three targets of three
kinds, a list, `fetch_price` and a generator function, and a helper
that tries something on a proxy and reports the error if it raises.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # A proxy that fits its target
    Each step of the workshop adds a cell below.
- code: |
    import timeit

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def fetch_price(item, currency="USD"):
        """Look up the price of an item."""
        return PRICES[item]

    def countdown():
        yield 3
        yield 2
        yield 1

    def attempt(proxy, use):
        try:
            return use(proxy)
        except TypeError as exc:
            return f"TypeError: {exc}"

    print("wrapt:", wrapt.__version__)
    print("list :", attempt([1, 2, 3], list))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
helper at work on a plain list.

```{verify}
:id: setup-works
:label: wrapt is importable and the helper works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and attempt([1, 2, 3], list) == [1, 2, 3]
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "A proxy that fits its target" from
the picker at the top right of the notebook, and run the cell again.
```

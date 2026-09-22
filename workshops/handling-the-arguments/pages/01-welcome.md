---
title: Welcome
requires: [verify:setup-works]
---

# Handling the arguments

A wrapt wrapper receives the call's arguments as `args`, a tuple, and
`kwargs`, a dict, and passes them on with `wrapped(*args, **kwargs)`.
Most wrappers never look inside them, and that is the right default.

This workshop is about the wrappers that do. It is the one place wrapt
asks slightly more of you than a closure does, and the reason is worth
knowing, so the workshop starts there: why the arguments are never
bound to names, then the two ways to bind them yourself, and finally
what a wrapper may do with the value that comes back.

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

The step below creates the notebook with a decorator that does
nothing but pass the call through, on a function called three
different ways.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Handling the arguments
    Each step of the workshop adds a cell below.
- code: |
    import inspect

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    @wrapt.decorator
    def pass_through(wrapped, instance, args, kwargs):
        return wrapped(*args, **kwargs)

    @pass_through
    def fetch_price(item, currency="USD"):
        """Look up the price of an item."""
        return f"{PRICES[item]} {currency}"

    results = [
        fetch_price("apple"),
        fetch_price("pear", "EUR"),
        fetch_price(item="fig", currency="GBP"),
    ]
    print(results)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

Three calling styles, one wrapper, and it did not have to know about
any of them. Inside the wrapper, `args` and `kwargs` are exactly what
the caller wrote: `("apple",)` and `{}` for the first call, `("pear",
"EUR")` and `{}` for the second, and `()` with `{"item": "fig",
"currency": "GBP"}` for the third. Nothing has been rearranged.

```{verify}
:id: setup-works
:label: The pass-through wrapper forwards all three calling styles
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and results == ["0.5 USD", "0.75 EUR", "2.0 GBP"]
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Handling the arguments" from the
picker at the top right of the notebook, and run the cell again.
```

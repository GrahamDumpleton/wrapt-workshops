---
title: Welcome
requires: [verify:setup-works]
---

# Validating arguments

A decorator that checks arguments has to know their names, and
**Handling the arguments** showed the tool: bind `args` and `kwargs`
to the function's signature and read the result by name. Doing that
on every call means computing the signature on every call, unless the
decorator keeps it somewhere, and **Keeping state** showed where: on
an instance of a class whose `__call__` is the wrapper.

This workshop puts the two together, twice. A `TypeChecker` compares
each argument against the annotation on its parameter, and a
`ValueChecker` compares it against a constraint the decoration site
supplies. Both are the examples from wrapt's own documentation, and
both work on a function, an instance method, a class method and a
static method without a line changed, for a reason worth
understanding. The last page stacks them, and finds that only one
order gives sensible errors.

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

The step below creates the notebook with the imports and the prices.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Validating arguments
    Each step of the workshop adds a cell below.
- code: |
    import inspect

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    def price_of(item: str, quantity: int = 1) -> float:
        """The price of some quantity of an item."""
        return PRICES[item] * quantity

    price = price_of("apple", 2)

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
price of two apples.

```{verify}
:id: setup-works
:label: wrapt is importable and price_of works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and price == 1.0
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Validating arguments" from the
picker at the top right of the notebook, and run the cell again.
```

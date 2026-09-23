---
title: Welcome
requires: [verify:setup-works]
---

# Patching every kind of method

`wrapt.wrap_function_wrapper` puts one wrapper on any function or
method, and the wrapper's `instance` argument tells it what kind of
thing it landed on. This workshop puts the same wrapper on every kind
of target there is, one at a time, and has you predict what `instance`
holds before each cell shows it: the object, the class, `None`, and
the entry of a nested class reached through a dotted path.

It also shows the one rule that patching makes easy to forget, by
breaking it, and finishes by patching one object without touching the
rest of its class.

The code being patched is the `shop` package, already open in the
editor. Two of its modules matter here, and the links on this page and
the ones after bring either to the front:

- {open}`shop/cart.py` has a `Shop` with a method of every kind and a
  `Registry` with a nested `Entry` class.

- {open}`shop/reports.py` is a module nothing else in the package
  imports, for the page that names a module as a string.

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

The step below creates the notebook, which opens beside the code. Its
first cell imports the shop and defines the one wrapper every page
uses: `notify` prints what
was called and records the call, `instance` included, in `seen`, so
the pages can read back what the wrapper was given.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Patching every kind of method
    Each step of the workshop adds a cell below.
- code: |
    import sys

    import wrapt

    import shop.cart
    from shop.cart import Shop, Registry

    seen = []

    def notify(wrapped, instance, args, kwargs):
        seen.append((wrapped.__name__, instance, args))
        print(f"calling {wrapped.__name__}{args}")
        return wrapped(*args, **kwargs)

    corner = Shop("Corner Store")
    bought = corner.buy("pear")

    print("wrapt :", wrapt.__version__)
    print("bought:", bought)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
price of a pear from `corner.buy`, unpatched.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop package works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and bought == 0.75 and seen == []
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Patching every kind of method"
from the picker at the top right of the notebook, and run the cell
again. A `ModuleNotFoundError` on `shop` means the notebook is not in
the workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

---
title: Welcome
requires: [verify:setup-works]
---

# Holding a function weakly

A registry of callbacks, a cache of handlers, an event bus: each
holds functions to call later, and each keeps alive whatever those
functions are bound to, for as long as the entry stays. A weak
reference is the usual answer, and for a bound method it does not
work, for a reason that is worth seeing before the fix. wrapt's fix
is `WeakFunctionProxy`, a proxy that calls the function while its
object lives and lets the object go when nothing else holds it.

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

The step below creates the notebook with a `Shop` whose `buy` method
names the shop, so a call shows which shop answered, and the
`weakref` and `gc` modules.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Holding a function weakly
    Each step of the workshop adds a cell below.
- code: |
    import gc
    import weakref

    import wrapt

    class Shop:
        def __init__(self, name):
            self.name = name

        def buy(self, item):
            return f"{self.name} sells {item}"

    shop = Shop("corner")

    print("wrapt:", wrapt.__version__)
    print("buy  :", shop.buy("apple"))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and a
sale from the corner shop.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop sells
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and shop.buy("apple") == "corner sells apple"
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Holding a function weakly" from
the picker at the top right of the notebook, and run the cell again.
```

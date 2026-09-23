---
title: Welcome
requires: [verify:setup-works]
---

# Three ways to spell a patch

`wrapt.wrap_function_wrapper(target, name, wrapper)` is one call that
does the whole job, and the previous workshops used nothing else. wrapt
offers two more spellings of the same patch, and the difference
between them is not what they do but where they read well: a patch
made by code that decides at runtime, a patch that installs itself
when a file of patches is imported, and a wrapper made once to apply
anywhere.

This workshop writes each and ends with a rule of thumb for
choosing. The code is already open in the editor, and the links on
this page and the ones after bring each file to the front:

- {open}`shop/cart.py` has a `Shop` with an instance method, a class
  method and a static method.

- {open}`shop/pricing.py` has `fetch_price`, a function that looks up
  a price.

- {open}`patches.py` is a file of patches, the second spelling, which
  installs itself when it is imported. Nothing imports it until the
  page that does.

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

The step below creates the notebook, which opens beside the code, with
the shop imported and the `notify` wrapper the first two pages use.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Three ways to spell a patch
    Each step of the workshop adds a cell below.
- code: |
    import sys

    import wrapt

    import shop.pricing
    import shop.cart
    from shop.cart import Shop

    def notify(wrapped, instance, args, kwargs):
        print(f"calling {wrapped.__name__}{args}")
        return wrapped(*args, **kwargs)

    corner = Shop("Corner Store")
    price = shop.pricing.fetch_price("apple")

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
price of an apple, unpatched.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop package works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and price == 0.5
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Three ways to spell a patch" from
the picker at the top right of the notebook, and run the cell again.
A `ModuleNotFoundError` on `shop` means the notebook is not in the
workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

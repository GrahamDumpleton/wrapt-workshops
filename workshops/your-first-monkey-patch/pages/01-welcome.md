---
title: Welcome
requires: [verify:setup-works]
---

# Your first monkey patch

A monkey patch changes a function or a method after it has been
defined, in a module you did not write and are not going to edit. You
have probably done it: assign a wrapper over `module.function`, or over
`Class.method`, and the code that calls them gets the wrapper. It is
the same shape as a decorator, applied from outside and after the fact.

That difference, outside and after, is where it goes wrong. A
decorator sits inside the class body and receives the raw function.
A patch comes in once the class exists and has to ask the class for
the method first, and what the class hands back is not always what it
holds. This workshop patches by assignment, sees it work, sees it
break, and then does the same job with wrapt.

The code being patched is a small package called `shop`, shipped with
the workshop and already open in the editor. It has two modules, and
the links here and on the pages that follow bring either to the
front:

- {open}`shop/pricing.py` holds `fetch_price`, a function that looks
  up a price, slowly.

- {open}`shop/cart.py` holds a `Shop` with one method of each kind:
  `buy`, an instance method, `empty`, a class method, and `tax`, a
  static method. `Kiosk` is a subclass that adds nothing.

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

The step below creates the notebook, which opens beside the code, so
you can read what you are patching while you patch it. Its first cell
imports the two modules of the `shop` package and calls the function
and the method the pages patch, so you have seen them unpatched first.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Your first monkey patch
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    import wrapt

    import shop.pricing
    import shop.cart
    from shop.cart import Shop, Kiosk

    price = shop.pricing.fetch_price("apple")
    bought = Shop("Corner Store").buy("pear")

    print("wrapt :", wrapt.__version__)
    print("price :", price)
    print("bought:", bought)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed, the
price of an apple from `shop.pricing.fetch_price`, and the price of a
pear from `Shop.buy`, which calls `fetch_price` for it.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop package works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and price == 0.5 and bought == 0.75
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Your first monkey patch" from the
picker at the top right of the notebook, and run the cell again. A
`ModuleNotFoundError` on `shop` means the notebook is not in the
workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

---
title: Welcome
requires: [verify:setup-works]
---

# Leaving things as you found them

A patch that goes in has to come out: at the end of a test, when a
tool is switched off, or when two parties have patched the same
method and one of them is done. By hand that means saving the
original, which the first workshop showed is harder than it looks,
and putting it back, which is wrong the moment anyone else has
patched over you.

wrapt gives every patch an identity. The object a wrap function
returns is the wrapper it installed, and that object is the handle:
what you keep, and what you hand back to ask whether the patch is
still there, to see what else is stacked on the target, and to take
the patch out, wherever in the stack it has ended up.

This workshop is about that handle. It matters here more than
anywhere, because a notebook kernel keeps every patch you make until
you take it out, and so, from this workshop on, every page that
installs a patch removes it before the next page needs a clean
target.

The code being patched is {open}`shop/cart.py`, already open in the
editor: a `Shop` with a `buy` method, and a `Kiosk` that inherits it
and defines nothing of its own. The link here and on the pages after
brings the file to the front.

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
the shop imported, a `notify` wrapper that logs each call, a
`discount` wrapper that
changes the result, and a helper that names the wrappers on a target
outermost first, which every page uses to show what is there.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Leaving things as you found them
    Each step of the workshop adds a cell below.
- code: |
    import functools

    import wrapt

    import shop.cart
    from shop.cart import Shop, Kiosk

    def notify(wrapped, instance, args, kwargs):
        print(f"calling {wrapped.__name__}{args}")
        return wrapped(*args, **kwargs)

    def discount(wrapped, instance, args, kwargs):
        return round(wrapped(*args, **kwargs) * 0.9, 3)

    def chain(target, name):
        """The types on the target's attribute, outermost first."""
        raw = wrapt.resolve_path(target, name)[2]
        return [type(entry).__name__ for entry in wrapt.wrapper_chain(raw)]

    corner = Shop("Corner Store")
    bought = corner.buy("pear")

    print("wrapt :", wrapt.__version__)
    print("bought:", bought)
    print("chain :", chain(shop.cart, "Shop.buy"))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version, the price of a pear from an
unpatched `buy`, and the chain on `Shop.buy`, which is one plain
`function` and nothing on top of it.

```{verify}
:id: setup-works
:label: wrapt is importable and Shop.buy is an unpatched function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and bought == 0.75 and chain(shop.cart, "Shop.buy") == ["function"]
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Leaving things as you found them"
from the picker at the top right of the notebook, and run the cell
again. A `ModuleNotFoundError` on `shop` means the notebook is not in
the workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

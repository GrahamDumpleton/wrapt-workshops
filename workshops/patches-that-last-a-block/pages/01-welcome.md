---
title: Welcome
requires: [verify:setup-works]
---

# Patches that last a block

Some patches are only wanted for a moment: the length of one test,
one request, one block of code. Installing one and remembering to
take it out is the previous workshop; this one is about patches that
take themselves out, on the way out of a `with` statement or on the
way out of a function call, whether or not the code in between
raised.

You have probably used `unittest.mock.patch` for this. The workshop
starts there, then writes the same temporary patch with wrapt, where
the original keeps running beneath your wrapper and the wrapper knows
about methods, and ends with what each form does when something
inside the block interferes with the patch.

The code being patched is the `shop` package, already open in the
editor, and the links on this page and the ones after bring either
file to the front: {open}`shop/pricing.py` has `fetch_price`, and
{open}`shop/cart.py` has a `Shop` whose `buy` calls it.

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
the shop imported, a `capture` wrapper that records each call it sees
in `calls` and lets
it through, and a `chain` helper that names the wrappers on a target
outermost first.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Patches that last a block
    Each step of the workshop adds a cell below.
- code: |
    import contextlib
    from unittest import mock

    import wrapt

    import shop.pricing
    import shop.cart
    from shop.cart import Shop

    calls = []

    def capture(wrapped, instance, args, kwargs):
        calls.append((wrapped.__name__, args))
        return wrapped(*args, **kwargs)

    def chain(target, name):
        """The types on the target's attribute, outermost first."""
        raw = wrapt.resolve_path(target, name)[2]
        return [type(entry).__name__ for entry in wrapt.wrapper_chain(raw)]

    corner = Shop("Corner Store")
    price = shop.pricing.fetch_price("apple")

    print("wrapt:", wrapt.__version__)
    print("price:", price)
    print("chain:", chain(shop.pricing, "fetch_price"))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version, the price of an apple, and the
chain on `fetch_price`: a plain `function` with nothing on it, which
is the state every page of this workshop returns to.

```{verify}
:id: setup-works
:label: wrapt is importable and fetch_price is an unpatched function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and price == 0.5 and chain(shop.pricing, "fetch_price") == ["function"]
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Patches that last a block" from
the picker at the top right of the notebook, and run the cell again.
A `ModuleNotFoundError` on `shop` means the notebook is not in the
workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

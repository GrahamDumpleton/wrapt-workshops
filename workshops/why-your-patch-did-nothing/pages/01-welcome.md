---
title: Welcome
requires: [verify:setup-works]
---

# Why your patch did nothing

The patch was correct. The target was right, the wrapper was right,
`is_wrapped_by` says it is there, and the code you wanted to affect
carries on exactly as before. This is the most common way a monkey
patch fails, and it has nothing to do with the patch: the caller
took its own reference to the function before you patched it, and a
patch replaces an attribute, not every reference that was ever
copied out of it.

This workshop makes that happen in the shipped code, where you can
see the line responsible, then shows the two ways round it and the
rule that makes methods safer targets than functions.

The `shop` package is already open in the editor, and the links on
this page and the ones after bring each file to the front:

- {open}`shop/checkout.py` totals some items. Read its import line
  before going on: `from shop.pricing import fetch_price`.

- {open}`shop/cart.py` reaches the same function the other way,
  through the module, and a later page is about the difference.

- {open}`shop/pricing.py` is where `fetch_price` is defined, and where
  the patch goes.

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
first cell imports `shop.checkout`, which is the moment the module
takes its reference,
and defines the `capture` wrapper the pages patch with.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Why your patch did nothing
    Each step of the workshop adds a cell below.
- code: |
    import wrapt

    import shop.pricing
    import shop.checkout
    import shop.cart
    from shop.cart import Shop

    calls = []

    def capture(wrapped, instance, args, kwargs):
        calls.append((wrapped.__name__, args))
        return wrapped(*args, **kwargs)

    total = shop.checkout.total(["apple", "pear"])

    print("wrapt:", wrapt.__version__)
    print("total:", total)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version and the total for an apple and a
pear, from `shop.checkout.total`, unpatched.

```{verify}
:id: setup-works
:label: wrapt is importable and shop.checkout works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and total == 1.25 and calls == []
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Why your patch did nothing" from
the picker at the top right of the notebook, and run the cell again.
A `ModuleNotFoundError` on `shop` means the notebook is not in the
workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

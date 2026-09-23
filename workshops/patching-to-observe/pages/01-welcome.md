---
title: Welcome
requires: [verify:setup-works]
---

# Patching to observe

Every mechanism these workshops have taught has a job in one
program: the tool that watches a library it did not write. It counts
calls, times
them, and reports, without a line of the library changing. Every
monitoring agent is this, with more targets and somewhere to send
the numbers.

This workshop builds a small one on the `shop` package: a wrapper
with state that records what it sees, a
registry that installs each patch once and takes them all out, a
version check so the patches are only applied to a library they were
written for, and deferral so they apply whether the library was
imported before or after the tool. Then it names the tool built on
exactly this.

The package is already open in the editor, and the links on this page
and the ones after bring each file to the front:
{open}`shop/__init__.py`, which holds the package's `__version__`,
{open}`shop/cart.py`, whose `buy` reaches `fetch_price` through the
module, {open}`shop/pricing.py`, where `fetch_price` is defined, and
{open}`shop/reports.py`, which nothing imports until the page on
deferral does.

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
the shop imported, its version printed, and a `chain` helper that
names the wrappers on a
target. `shop.reports` is left unimported on purpose, for the page on
deferral.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Patching to observe
    Each step of the workshop adds a cell below.
- code: |
    import sys
    import time

    import wrapt

    import shop
    import shop.pricing
    import shop.cart
    from shop.cart import Shop

    def chain(target, name):
        """The types on the target's attribute, outermost first."""
        raw = wrapt.resolve_path(target, name)[2]
        return [type(entry).__name__ for entry in wrapt.wrapper_chain(raw)]

    corner = Shop("Corner Store")
    bought = corner.buy("pear")

    print("wrapt        :", wrapt.__version__)
    print("shop version :", shop.__version__)
    print("bought       :", bought)
    print("reports      :", "shop.reports" in sys.modules)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version, the shop package's own version,
the price of a pear, and `False` for `shop.reports`, not yet
imported.

```{verify}
:id: setup-works
:label: wrapt is importable, the shop works and reports is not imported
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and bought == 0.75 and shop.__version__ == "1.2.0" and "shop.reports" not in sys.modules
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Patching to observe" from the
picker at the top right of the notebook, and run the cell again. If
`shop.reports` is already imported, a page of this workshop has run
before in this kernel: restart the kernel from the notebook's Kernel
menu and run the first cell again.
```

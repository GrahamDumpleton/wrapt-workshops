---
title: Welcome
requires: [verify:setup-works]
---

# Wrapping what is not a function

Every patch so far replaced a function or a method with a wrapper
around it. Not everything worth patching is callable. A module holds
a dictionary of settings, a connection object, a list of handlers,
and a patch may want to see what is read from it, or change what is
found there, without the module noticing that anything changed.

wrapt has one more wrap function for this, `wrap_object`, which takes
any factory and installs whatever the factory returns. The factory
you write is a proxy: an object that stands in for the original,
passes everything through, and intercepts what it chooses. wrapt's
`BaseObjectProxy` is the base class for that, and it is the thing
every `FunctionWrapper` has been built on all along.

The code being patched is already open in the editor, and the links
on this page and the ones after bring each file to the front:
{open}`shop/config.py`, a `settings` dictionary and two
functions that read from it, and {open}`shop/pricing.py`, whose
`fetch_price` the callable proxy wraps.

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
the two shop modules imported and a `chain` helper that names the
wrappers on a target.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Wrapping what is not a function
    Each step of the workshop adds a cell below.
- code: |
    import wrapt

    import shop.pricing
    import shop.config

    def chain(target, name):
        """The types on the target's attribute, outermost first."""
        raw = wrapt.resolve_path(target, name)[2]
        return [type(entry).__name__ for entry in wrapt.wrapper_chain(raw)]

    currency = shop.config.currency()

    print("wrapt   :", wrapt.__version__)
    print("currency:", currency)
    print("settings:", chain(shop.config, "settings"))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version, the currency the shop quotes in,
and the chain on `settings`, which is a plain `dict` with nothing on
it.

```{verify}
:id: setup-works
:label: wrapt is importable and shop.config works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and currency == "USD" and chain(shop.config, "settings") == ["dict"]
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Wrapping what is not a function"
from the picker at the top right of the notebook, and run the cell
again. A `ModuleNotFoundError` on `shop` means the notebook is not in
the workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

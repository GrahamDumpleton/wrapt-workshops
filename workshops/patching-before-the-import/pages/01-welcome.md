---
title: Welcome
requires: [verify:setup-works]
---

# Patching before the import

A patch can only wrap an attribute that exists, so the module has to
be imported before the patch is applied. Apply it too early and the
attribute is not there; apply it too late and, as the previous
workshop showed, callers have already taken their own references.
The right moment is just after the module is imported and before
anyone else has used it, and a program's import order is not yours
to choose.

wrapt lets a patch wait. This workshop uses three forms of waiting,
on three modules of the `shop` package that nothing else imports, so
that each can be imported for the first time in front of you. They
are already open in the editor, with the file of patches the last
form uses, and the links on this page and the ones after bring each
to the front:

- {open}`shop/reports.py`, with `summary`, for the `?` shortcut.

- {open}`shop/invoices.py`, with `render`, for a post import hook.

- {open}`shop/shipping.py`, with `quote`, for the string form.

- {open}`patches.py`, the module holding the patch for `shipping`,
  which stays unimported until `shop.shipping` is.

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
first cell imports only `shop.pricing`, defines the `capture` wrapper
the pages patch with,
and confirms that the three modules the pages will import are not
imported yet.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Patching before the import
    Each step of the workshop adds a cell below.
- code: |
    import sys

    import wrapt

    import shop.pricing

    calls = []

    def capture(wrapped, instance, args, kwargs):
        calls.append((wrapped.__name__, args))
        return wrapped(*args, **kwargs)

    waiting = ["shop.reports", "shop.invoices", "shop.shipping"]
    already_imported = [name for name in waiting if name in sys.modules]

    print("wrapt           :", wrapt.__version__)
    print("already imported:", already_imported)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version and an empty list: none of the
three modules is imported.

```{verify}
:id: setup-works
:label: wrapt is importable and the three modules are not imported yet
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and already_imported == []
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Patching before the import" from
the picker at the top right of the notebook, and run the cell again.
A module already imported means a page of this workshop has run
before in this kernel: a kernel imports a module once, so restart
the kernel from the notebook's Kernel menu and run the first cell
again.
```

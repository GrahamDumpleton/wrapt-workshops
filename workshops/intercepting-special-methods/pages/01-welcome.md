---
title: Welcome
requires: [verify:setup-works]
---

# Intercepting special methods

A proxy that only passes things through is a proxy with nothing to
say. The point of writing one is usually to see or change something
on the way past, and for a dictionary, a context manager or a
container, the thing to see is a special method: `__getitem__`,
`__enter__`, `__iadd__`.

This workshop intercepts each of those on a `BaseObjectProxy`
subclass. It starts with the way that does not work, because the
reason it does not work is the reason the way that does work does.

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

The step below creates the notebook with a `settings` dictionary to
watch, and the `threading` and `time` modules for the lock later.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Intercepting special methods
    Each step of the workshop adds a cell below.
- code: |
    import threading
    import time

    import wrapt

    settings = {"currency": "USD", "debug": False, "region": "eu"}

    def currency():
        return settings["currency"]

    print("wrapt   :", wrapt.__version__)
    print("currency:", currency())
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
currency the settings hold.

```{verify}
:id: setup-works
:label: wrapt is importable and the settings are readable
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and currency() == "USD"
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Intercepting special methods" from
the picker at the top right of the notebook, and run the cell again.
```

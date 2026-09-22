---
title: Welcome
requires: [verify:setup-works]
---

# Changing the signature

The first workshop made much of the fact that a wrapt decorated
function reports the original's signature. That is right whenever the
decorator leaves the call alone, which is nearly always. It is wrong
for the one kind of decorator that does not: a decorator that
supplies an argument itself, a database session or a request id, so
that the caller passes one argument fewer than the function declares.
Every tool that asks the decorated function about itself is now told
about a parameter the caller must not pass.

This short workshop makes one of those decorators, watches
`inspect.signature()` and `help()` get it wrong, and fixes them with
`wrapt.with_signature`, which changes what introspection sees and
nothing else.

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

The step below creates the notebook with a `Session` standing in for
whatever a decorator might supply, with one method that looks a price
up.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Changing the signature
    Each step of the workshop adds a cell below.
- code: |
    import inspect

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    class Session:
        def __repr__(self):
            return "Session()"

        def lookup(self, item):
            return PRICES[item]

    session = Session()

    print("wrapt  :", wrapt.__version__)
    print("session:", session, session.lookup("apple"))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and a
session looking up the price of an apple.

```{verify}
:id: setup-works
:label: wrapt is importable and a Session works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and isinstance(session, Session)
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Changing the signature" from the
picker at the top right of the notebook, and run the cell again.
```

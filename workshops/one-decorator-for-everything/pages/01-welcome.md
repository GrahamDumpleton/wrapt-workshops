---
title: Welcome
requires: [verify:setup-works]
---

# One decorator for everything

**What instance tells you** read the five values of `instance` and
`wrapped` for the five kinds of thing a decorator can be applied to.
This workshop turns that table into a decorator: one wrapper that
knows what it is on and does something different for each, which
wrapt's documentation calls a universal decorator.

The standard library version of this needs a `__get__` method to
learn about binding and a separate decorator for classes, and still
cannot tell a static method from a function. Here the four branches
are four lines.

Then the other half of composition, stacking. Two wrapt decorators
on one function, a wrapt decorator over and under a `functools.wraps`
closure, and wrapt's tools for walking the chain that results and
getting to the bottom of it.

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

The step below creates the notebook with the imports and a list the
decorators will record into, so that the checks can read what the
wrapper saw.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # One decorator for everything
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    import wrapt

    log = []

    print("wrapt:", wrapt.__version__)
    print("log  :", log)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
empty log.

```{verify}
:id: setup-works
:label: wrapt is importable and the log is empty
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and log == []
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "One decorator for everything" from
the picker at the top right of the notebook, and run the cell again.
```

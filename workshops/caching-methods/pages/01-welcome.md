---
title: Welcome
requires: [verify:setup-works]
---

# Caching methods

`functools.lru_cache` is the standard library's best known decorator,
and on a plain function it is hard to fault. Put it on a method and
three things go wrong that have nothing to do with caching and
everything to do with `self`: the instance becomes part of every
cache key, and a key is something a cache holds on to, hashes, and
counts against its budget.

This workshop shows each problem in a cell, then `wrapt.lru_cache`,
which is the same decorator with the cache moved onto the instance,
where none of the three can happen. It ends with the one new thing
that arrangement asks of you, which is a line in `__getstate__` if
the instances are pickled.

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

The step below creates the notebook with the imports and the prices.
`gc` and `weakref` are there to show what the cache holds on to, and
`pickle` for the last page.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Caching methods
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import gc
    import pickle
    import weakref

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    print("wrapt:", wrapt.__version__)
    print("price:", PRICES["apple"])
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
price of an apple.

```{verify}
:id: setup-works
:label: wrapt is importable and the prices are defined
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and PRICES["apple"] == 0.5
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Caching methods" from the picker
at the top right of the notebook, and run the cell again.
```

---
title: Welcome
requires: [verify:setup-works]
---

# Saving and restoring a proxy

Sooner or later a proxy meets `pickle`, in a cache, a queue or a
process pool, or `copy`, in code that duplicates what it was given.
Both work by asking the object how to rebuild itself, and a proxy
has two things to rebuild: the target, and whatever the proxy keeps
under its `_self_` names. The base class cannot know the second, so
it refuses, and this workshop is about saying how.

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

The step below creates the notebook with a dictionary of sales
statistics to wrap, and the `pickle` and `copy` modules.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Saving and restoring a proxy
    Each step of the workshop adds a cell below.
- code: |
    import copy
    import pickle

    import wrapt

    stats = {"apple": 3, "pear": 1}

    print("wrapt:", wrapt.__version__)
    print("stats:", pickle.loads(pickle.dumps(stats)))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
statistics after a round trip through `pickle`, which a plain
dictionary survives without help.

```{verify}
:id: setup-works
:label: wrapt is importable and the dictionary pickles
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and pickle.loads(pickle.dumps(stats)) == stats
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Saving and restoring a proxy" from
the picker at the top right of the notebook, and run the cell again.
```

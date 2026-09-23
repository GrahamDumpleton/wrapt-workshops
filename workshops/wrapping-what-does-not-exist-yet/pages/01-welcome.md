---
title: Welcome
requires: [verify:setup-works]
---

# Wrapping what does not exist yet

Every proxy so far was given its target when it was made. Sometimes
the target is expensive to make and may never be needed, or cannot be
made yet because making it would import a module that imports this
one. `LazyObjectProxy` takes a callback instead of a target and runs
it the first time the proxy is used, and `wrapt.lazy_import` is the
same thing with an import for the callback.

To see an import happen late, the workshop ships a small `shop`
package whose modules print a line when they are imported. It is
already in the workspace, and nothing imports it until a page does.

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

The step below creates the notebook with a `Shop` class to be made
lazily, and the modules the pages need. It does not import `shop`.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Wrapping what does not exist yet
    Each step of the workshop adds a cell below.
- code: |
    import sys
    from collections.abc import Callable

    import wrapt

    class Shop:
        def __init__(self, name):
            self.name = name

        def __repr__(self):
            return f"Shop({self.name!r})"

    print("wrapt          :", wrapt.__version__)
    print("shop imported  :", "shop" in sys.modules)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and
confirms that the shipped package has not been imported.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop package is not imported yet
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and "shop" not in sys.modules
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Wrapping what does not exist yet"
from the picker at the top right of the notebook, and run the cell
again. If `shop` is reported as already imported, a cell further
down has been run; Restart, in the panel's menu, starts the kernel
afresh.
```

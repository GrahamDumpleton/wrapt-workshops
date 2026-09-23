---
title: Welcome
requires: [verify:setup-works]
---

# Patching instance attributes

Every wrap function so far replaced an attribute of a module or a
class, which works for functions and methods because that is where
they live. It does nothing for a value that `__init__` sets on each
object: `self.name = name` puts `name` in the object's own
dictionary, one per shop, after the class exists and before any
patch could see the object.

wrapt reaches those with a descriptor. `wrap_object_attribute`
installs one on the class, and on every read of the attribute the
descriptor fetches the object's own value and passes it through a
factory of yours, so a proxy can wrap what each object holds without
touching the objects.

The code being patched is {open}`shop/cart.py`, already open in the
editor, and the link here and on the pages after brings it to the
front: a `Shop` whose `name` is set in `__init__`, whose `label` is a
property computed from it, and whose `region` is a default on the
class.

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
the shop imported and a `Tagged` proxy whose `repr` shows that a value
came through it, which
is all the factory the pages need.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
:area: notebook
- markdown: |
    # Patching instance attributes
    Each step of the workshop adds a cell below.
- code: |
    import wrapt

    import shop.cart
    from shop.cart import Shop

    class Tagged(wrapt.BaseObjectProxy):
        def __repr__(self):
            return f"Tagged({self.__wrapped__!r})"

    corner = Shop("Corner Store")

    print("wrapt :", wrapt.__version__)
    print("name  :", repr(corner.name))
    print("label :", repr(corner.label))
    print("region:", repr(corner.region))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version and the three attributes of a shop,
unpatched: a plain string each.

```{verify}
:id: setup-works
:label: wrapt is importable and the shop has its three attributes
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and corner.name == "Corner Store" and corner.label == "CORNER STORE" and corner.region == "local"
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Patching instance attributes" from
the picker at the top right of the notebook, and run the cell again.
A `ModuleNotFoundError` on `shop` means the notebook is not in the
workshop's workspace beside the `shop` directory; Restart, in the
panel's menu, puts both back.
```

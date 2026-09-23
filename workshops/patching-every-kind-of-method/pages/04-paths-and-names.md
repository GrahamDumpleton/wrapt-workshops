---
title: Paths and names
requires: [verify:paths-and-names]
---

# Paths and names

The second argument to `wrap_function_wrapper` is a dotted path, not
just a name. `Registry.Entry.describe` walks from the module to
`Registry`, into its nested `Entry` class, and patches `describe`
there. The first argument can be a string too: the module's name,
which wrapt imports if it is not imported yet.

{open}`shop/reports.py` is a module nothing else in the package
imports. The cell checks it is absent from `sys.modules`, patches it
by name, and checks again.

```{cell-insert}
:id: insert-paths-and-names
:path: {{ notebook }}
:tags: [paths-and-names]
:run: true
wrapt.wrap_function_wrapper(shop.cart, "Registry.Entry.describe", notify)

entry = Registry().add(corner)
described = entry.describe()
describe_seen = seen[-1]

print("described     :", described)
print("describe saw  :", type(describe_seen[1]).__name__)
print()

imported_before = "shop.reports" in sys.modules
wrapt.wrap_function_wrapper("shop.reports", "summary", notify)
imported_after = "shop.reports" in sys.modules

summary = shop.reports.summary(corner)

print()
print("imported before:", imported_before)
print("imported after :", imported_after)
print("summary        :", summary)
```

`describe` saw an `Entry`, the object the method was bound to, which
is what a dotted path buys: the patch lands on the class that defines
the method, however deep, and binds the way it would have anyway.
And `shop.reports` went from absent to imported and patched in one
call. The string form is for a patch written where the module object
is not to hand, or where importing it yourself would be the wrong
moment; a later workshop, **Patching before the import**, is about
choosing that moment.

```{verify}
:id: paths-and-names
:label: The nested method was patched through its path and the module by its name
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed paths-and-names
describe_seen[0] == "describe" and describe_seen[1] is entry and not imported_before and imported_after and summary.startswith("Corner Store:") and seen[-1][0] == "summary"
```

```{hint}
:title: Why not shop.cart.Registry.Entry as the target
It would work: the target can be any object holding the attribute,
and `Registry.Entry` holds `describe`. The dotted path is for when
you hold the module and know the path, which is what a file of
patches usually does, and it keeps every patch reading the same way:
the module, then where in it.
```

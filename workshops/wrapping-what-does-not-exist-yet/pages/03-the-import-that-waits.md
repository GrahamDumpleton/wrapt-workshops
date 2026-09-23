---
title: The import that waits
requires: [verify:import-waits]
---

# The import that waits

The most common thing to make lazily is a module. `wrapt.lazy_import`
returns a lazy proxy whose callback imports the module named, so the
import happens the first time the module is used. The shipped
`shop.reports` prints a line when it is imported, and `sys.modules`
says whether it has been.

```{cell-insert}
:id: insert-import-waits
:path: {{ notebook }}
:tags: [import-waits]
:run: true
before = "shop.reports" in sys.modules

reports = wrapt.lazy_import("shop.reports")
after_proxy = "shop.reports" in sys.modules

summary = reports.summary()
after_use = "shop.reports" in sys.modules

print("imported before      :", before)
print("imported after proxy :", after_proxy)
print("summary              :", summary)
print("imported after use   :", after_use)
```

The two import lines, for the package and the module, appear in the
middle of the output, at the call to `reports.summary()`, and not
before. Making the proxy imported nothing. The first attribute read
ran the import, the module became the target, and `summary` was
looked up on it and called.

Two uses come from this. A module that is expensive to import and
only sometimes needed costs nothing until then. And a module that
would import this one back, a circular import, can be named at the
top of the file as a lazy proxy and imported when the function that
needs it runs, by which time both modules exist.

```{verify}
:id: import-waits
:label: The module was imported on first use and not before
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed import-waits
not before and not after_proxy and after_use and summary == "3 items in stock"
```

```{hint}
:title: The standard library way
`importlib.util.LazyLoader` defers a module the same way, by
replacing the module's class until first attribute access, and a
module can define a `__getattr__` of its own to defer part of
itself. Both defer a module and nothing else. `LazyObjectProxy`
defers any object a callback can make, and `lazy_import` is one
callback among many.
```

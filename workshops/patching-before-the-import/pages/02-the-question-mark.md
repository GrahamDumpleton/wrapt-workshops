---
title: The question mark
requires: [verify:question-mark]
---

# The question mark

The simplest way to wait is a `?` on the end of the module name.
Given `"shop.reports?"`, `wrap_function_wrapper` applies the patch at
once if the module is already imported, and otherwise defers it until
the module is imported for the first time. Patch `summary` before
importing `shop.reports`, then import it and call.

```{cell-insert}
:id: insert-question-mark
:path: {{ notebook }}
:tags: [question-mark]
:run: true
deferred = wrapt.wrap_function_wrapper("shop.reports?", "summary", capture)
imported_before = "shop.reports" in sys.modules

import shop.reports

report = shop.reports.summary(["apple", "pear"])
seen = len(calls)

print("returned       :", deferred)
print("imported before:", imported_before)
print("summary is a   :", type(shop.reports.summary).__name__)
print("report         :", report)
print("calls seen     :", seen)
```

The patch was in place by the time the import statement returned,
and the first call was seen. Two things to notice. The module was
not imported by the patch: `wrap_function_wrapper` with a plain
module name imports it, and with a `?` it waits instead, which is
the point when importing the module yourself would be the wrong
moment. And the call returned `None`, not a handle: there was no
wrapper to return when the call was made, because the module did not
exist yet. The last page of this workshop is about getting that
handle back.

`@wrapt.patch_function_wrapper("shop.reports?", "summary")` takes the
`?` in the same way, so a file of patches can be imported before or
after the modules it patches.

```{verify}
:id: question-mark
:label: The deferred patch applied on import and returned no handle
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed question-mark
deferred is None and not imported_before and type(shop.reports.summary).__name__ == "FunctionWrapper" and report == "2 items: apple, pear" and seen == 1
```

```{hint}
:title: When the ? is enough
The `?` is for "apply as soon as possible" with no logic of its own,
which is most patches. A patch that needs to inspect the module
first, choose between targets by version, or keep the handle, uses
the hook on the next page, which receives the module and can do what
it likes with it.
```

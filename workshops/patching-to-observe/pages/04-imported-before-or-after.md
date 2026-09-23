---
title: Imported before or after
requires: [verify:deferred-and-removed]
---

# Imported before or after

A tool cannot know whether the program imports a library before or
after the tool starts. A post import hook makes the registration
right either way: it fires at once for a module already imported, and
on import for one that is not. {open}`shop/reports.py` is not
imported yet. Register a hook that instruments it, watch the
registry, then import it.

```{cell-insert}
:id: insert-deferred
:path: {{ notebook }}
:tags: [deferred]
:run: true
@wrapt.when_imported("shop.reports")
def instrument_reports(module):
    instrument(module, "summary")

before_import = len(registry)

import shop.reports

summary = shop.reports.summary(corner)
after_import = len(registry)

print("registry before the import:", before_import)
print("registry after the import :", after_import)
print("summary                   :", summary)
print()
recorder.report()
```

Two patches, then three, and the first call to `summary` was seen.
Had `shop.reports` been imported already, the hook would have fired
during registration and the registry would have held three from the
start; the tool's code is the same either way, which is the point.

Now shut the tool down. `uninstrument` takes every patch out, and
the numbers it gathered stay on the recorder.

```{cell-insert}
:id: insert-shutdown
:path: {{ notebook }}
:tags: [shutdown]
:run: true
uninstrument()

remaining = [
    chain(shop.pricing, "fetch_price"),
    chain(shop.cart, "Shop.buy"),
    chain(shop.reports, "summary"),
]

print("registry :", len(registry))
print("targets  :", remaining)
print("records  :", len(recorder.calls))
```

The library is as shipped, and the report is still there to read.
That is a monitoring agent in forty lines: a wrapper with state, a
registry, a version check and a hook. A real one has more targets,
a place to send the records, and a lot of care about what it records
and how it behaves when a library changes, which is where the next
page points.

```{verify}
:id: deferred-and-removed
:label: The hook instrumented reports on import and uninstrument removed everything
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed shutdown
before_import == 2 and after_import == 3 and summary.startswith("Corner Store:") and len(registry) == 0 and remaining == [["function"], ["function"], ["function"]] and len(recorder.calls) == 8
```

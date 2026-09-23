---
title: As a decorator
requires: [verify:applied-on-import, verify:switched]
---

# As a decorator

A file of patches reads better the other way round: the wrapper
first, with the target above it. `@wrapt.patch_function_wrapper`
takes the target and the name as its arguments and installs the
wrapper it decorates. The patch is applied when the decorator is
evaluated, which is when the module holding it is imported, so
importing the module is the whole of switching the patch on.

{open}`patches.py` is such a file, shipped with the workshop and
open beside the notebook. Nothing has imported it yet. The cell
checks, imports it, and calls the function it patches.

```{cell-insert}
:id: insert-import-patches
:path: {{ notebook }}
:tags: [import-patches]
:run: true
imported_before = "patches" in sys.modules

import patches

imported_after = "patches" in sys.modules

price = shop.pricing.fetch_price("apple")
kind = type(shop.pricing.fetch_price).__name__

print()
print("imported before:", imported_before)
print("imported after :", imported_after)
print("fetch_price is :", kind)
print("announce is    :", type(patches.announce).__name__)
```

The import was the patch. `fetch_price` is a `FunctionWrapper` now,
and the module's `announce` is still the plain wrapper function you
wrote, because `patch_function_wrapper` returns the wrapper it was
given rather than a handle: in a file of patches, the name is there
to be read, not called.

## The switch

`patch_function_wrapper` takes an `enabled` argument, keyword only,
with the same meaning as on `@wrapt.decorator`: a callable is asked
on every call whether the wrapper should run, and a boolean is read
once. The cell puts a switched wrapper on `Shop.tax`, over the one
the previous page installed, and flips the switch between calls.

```{cell-insert}
:id: insert-switched
:path: {{ notebook }}
:tags: [switched]
:run: true
DEBUG = True
trace_runs = {"count": 0}

@wrapt.patch_function_wrapper("shop.cart", "Shop.tax", enabled=lambda: DEBUG)
def trace(wrapped, instance, args, kwargs):
    trace_runs["count"] += 1
    return wrapped(*args, **kwargs)

Shop.tax(10)
DEBUG = False
Shop.tax(20)
DEBUG = True
Shop.tax(30)

print()
print("trace ran:", trace_runs["count"], "of 3 calls")
```

Three calls, all logged by `notify` beneath, and `trace` ran for the
two made while `DEBUG` was true. One difference from
`@wrapt.decorator` is worth knowing: given a boolean `False`,
`wrapt.decorator` returns the function with no wrapper at all, while
`patch_function_wrapper` still installs a wrapper, one that steps
aside on every call. The patch exists, so it can be found and removed
like any other, and the cost is the step aside.

```{verify}
:id: applied-on-import
:label: Importing patches.py installed the patch on fetch_price
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed import-patches
not imported_before and imported_after and price == 0.5 and kind == "FunctionWrapper" and type(patches.announce).__name__ == "function"
```

```{verify}
:id: switched
:label: The switched wrapper ran for two of the three calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed switched
trace_runs["count"] == 2
```

```{hint}
:title: When the decorator form is the wrong one
The decorator's target is fixed when the file is written, so a file
of patches is a fixed set. It also runs when the file is imported,
which is either exactly what you want, one import to switch it all
on, or a surprise for whoever imports the module for some other
reason. Put such files where they are imported on purpose.
```

---
title: When something interferes
requires: [verify:interference]
---

# When something interferes

A temporary patch expects to find itself where it was put when the
block ends. Code inside the block can break that in two ways, and
wrapt treats them differently, so the mistake surfaces at the block
responsible rather than as a strange failure in something later.

First, the attribute replaced wholesale inside the block, the way an
assignment or a `mock.patch` would do it.

```{cell-insert}
:id: insert-replaced
:path: {{ notebook }}
:tags: [replaced]
:run: true
original = wrapt.resolve_path(shop.pricing, "fetch_price")[2]

try:
    with wrapt.scoped_function_wrapper(shop.pricing, "fetch_price", capture):
        shop.pricing.fetch_price = original
    interference = "no error"
except wrapt.WrapperNotFoundError as error:
    interference = f"WrapperNotFoundError: {error}"

print(interference)
```

`WrapperNotFoundError` on exit: the temporary wrapper was gone when
the block went to remove it. The block's own patch had been thrown
away by the assignment, and whoever wrote the assignment is not
managing their patches, which is worth an error at this block rather
than silence.

Second, a wrapt wrapper applied over the top inside the block and
left there.

```{cell-insert}
:id: insert-over-the-top
:path: {{ notebook }}
:tags: [over-the-top]
:run: true
with wrapt.scoped_function_wrapper(shop.pricing, "fetch_price", capture):
    top = wrapt.wrap_function_wrapper(shop.pricing, "fetch_price", capture)

left_behind = chain(shop.pricing, "fetch_price")
top_still_there = wrapt.is_wrapped_by(wrapt.resolve_path(shop.pricing, "fetch_price")[2], top)

print("after the block :", left_behind)
print("top still there :", top_still_there)

wrapt.unwrap_object(shop.pricing, "fetch_price", top)

print("top removed     :", chain(shop.pricing, "fetch_price"))
```

No error. The temporary wrapper was spliced out from beneath, as the
previous workshop showed a buried wrapper can be, and the one
applied on top is still there for whoever installed it to remove.
The cell removes it, so the target is plain again. A plain closure
left on top instead would have raised `WrapperNotOutermostError`, for
the reason that workshop gave.

```{verify}
:id: interference
:label: A wholesale replacement raised on exit and a wrapper on top was tolerated
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed over-the-top
interference.startswith("WrapperNotFoundError") and left_behind == ["FunctionWrapper", "function"] and top_still_there and chain(shop.pricing, "fetch_price") == ["function"] and wrapt.resolve_path(shop.pricing, "fetch_price")[2] is original
```

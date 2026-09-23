---
title: The patch that did nothing
requires: [quiz:predict-total, verify:did-nothing]
---

# The patch that did nothing

Patch `fetch_price` where it is defined, in `shop.pricing`, and call
`shop.checkout.total`, which calls `fetch_price` once per item.
Predict how many calls `capture` sees.

```{quiz}
:id: predict-total
:title: Predict what the patch sees
:shuffle: true
question: "`fetch_price` is patched on `shop.pricing` with `capture`. `shop.checkout.total([\"apple\", \"pear\"])` runs and calls `fetch_price` twice. How many calls does `capture` record?"
options:
  - text: "Two, one per item."
    explanation: "It would, if total looked fetch_price up on shop.pricing at call time. It does not: checkout.py imported the name, so it calls its own reference."
  - text: "None: shop.checkout holds its own reference to the original, taken when it was imported, and the patch on shop.pricing does not change it."
    correct: true
  - text: "One, because the second lookup is cached by the wrapper."
    explanation: "A FunctionWrapper caches nothing. Every call that reaches it is seen. The question is whether any call reaches it."
  - text: "Two, but only because wrapt patches every module that imported the name."
    explanation: "wrapt patches the one attribute it was pointed at. Finding every module that copied a name is not something a patch can do."
explanation: "from shop.pricing import fetch_price binds the name fetch_price in shop.checkout to the function object, at import time. Patching shop.pricing.fetch_price rebinds the name in shop.pricing; the binding in shop.checkout still points at the original."
```

Now the cell.

```{cell-insert}
:id: insert-did-nothing
:path: {{ notebook }}
:tags: [did-nothing]
:run: true
pricing_handle = wrapt.wrap_function_wrapper(shop.pricing, "fetch_price", capture)

total = shop.checkout.total(["apple", "pear"])
seen_by_total = len(calls)

same_object = shop.checkout.fetch_price is shop.pricing.fetch_price

shop.pricing.fetch_price("fig")
seen_directly = len(calls) - seen_by_total

print("total              :", total)
print("calls seen by total:", seen_by_total)
print("same object        :", same_object)
print("seen by direct call:", seen_directly)
print("patch is in place  :", wrapt.is_wrapped_by(shop.pricing.fetch_price, pricing_handle))
```

The total is right, the patch is in place, and it saw nothing until
the direct call. `shop.checkout.fetch_price` and
`shop.pricing.fetch_price` are different objects: the first is the
original function, bound into `shop.checkout`'s namespace by the
`from` import when that module loaded, and the second is the wrapper,
bound into `shop.pricing`'s namespace by the patch. `total` reads the
name from its own module and never looks at `shop.pricing` again.

There is no error to look for. The only sign is the absence of what
the patch was for, and the line responsible is in the module that
called, not the one that was patched.

```{verify}
:id: did-nothing
:label: The patch saw none of total's calls and one direct call
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed did-nothing
total == 1.25 and seen_by_total == 0 and not same_object and seen_directly == 1
```

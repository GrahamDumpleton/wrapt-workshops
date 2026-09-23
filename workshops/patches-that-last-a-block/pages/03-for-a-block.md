---
title: For a block
requires: [verify:for-a-block, verify:several-at-once]
---

# For a block

`wrapt.scoped_function_wrapper` takes the same three arguments as
`wrap_function_wrapper` and returns a context manager. The patch is
installed when the `with` statement is entered and removed when the
block exits, however it exits.

```{cell-insert}
:id: insert-for-a-block
:path: {{ notebook }}
:tags: [for-a-block]
:run: true
with wrapt.scoped_function_wrapper(shop.pricing, "fetch_price", capture):
    inside_chain = chain(shop.pricing, "fetch_price")
    price = shop.pricing.fetch_price("apple")

after_chain = chain(shop.pricing, "fetch_price")

print("inside the block:", inside_chain)
print("after the block :", after_chain)
print("price           :", price)
print("captured        :", calls)
```

Inside, a `FunctionWrapper` over the function; after, the function
alone. The price is the real one, because the original ran, and
`capture` saw the call on its way through. That is the difference
from the mock: the block observed the call rather than replacing it.

## Several at once

The context manager is single use, so each `with` statement calls
`scoped_function_wrapper` afresh. Several patches for one block go in
one `with` statement, applied left to right and removed in reverse,
with the guarantees nested `with` statements have: if a later one
fails to apply, the earlier ones are removed first. When the set is
only known at runtime, `contextlib.ExitStack` enters each as it is
made.

```{cell-insert}
:id: insert-several-at-once
:path: {{ notebook }}
:tags: [several-at-once]
:run: true
calls.clear()

with (
    wrapt.scoped_function_wrapper(shop.pricing, "fetch_price", capture),
    wrapt.scoped_function_wrapper(shop.cart, "Shop.buy", capture),
):
    corner.buy("pear")
    shop.pricing.fetch_price("fig")

two_calls = list(calls)
calls.clear()

targets = [
    (shop.pricing, "fetch_price"),
    (shop.cart, "Shop.buy"),
]

with contextlib.ExitStack() as stack:
    for target, name in targets:
        stack.enter_context(wrapt.scoped_function_wrapper(target, name, capture))
    corner.buy("apple")

stack_calls = list(calls)

print("two in one with :", two_calls)
print("from a list     :", stack_calls)
print("fetch_price now :", chain(shop.pricing, "fetch_price"))
print("Shop.buy now    :", chain(shop.cart, "Shop.buy"))
```

Both blocks captured what ran inside them and both targets are plain
again afterwards. The parenthesised form of `with` needs Python 3.10
or later; the `ExitStack` form works everywhere and takes its list
from anywhere.

```{verify}
:id: for-a-block
:label: The patch was there inside the block and gone after it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed for-a-block
inside_chain == ["FunctionWrapper", "function"] and after_chain == ["function"] and price == 0.5
```

```{verify}
:id: several-at-once
:label: Both patches applied together and both came out
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed several-at-once
two_calls == [("buy", ("pear",)), ("fetch_price", ("fig",))] and stack_calls == [("buy", ("apple",))] and chain(shop.pricing, "fetch_price") == ["function"] and chain(shop.cart, "Shop.buy") == ["function"]
```

```{hint}
:title: Why buy did not capture a fetch_price call
`Shop.buy` calls `fetch_price`, but {open}`shop/cart.py` imported it
by name and holds its own reference, which the patch on `shop.pricing`
never reaches. So the block saw `buy` and the direct call to
`fetch_price`, and nothing in between. **Why your patch did nothing**
is the workshop on this.
```

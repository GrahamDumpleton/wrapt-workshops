---
title: Two patches, either order
requires: [quiz:predict-inner-removal, verify:two-patches]
---

# Two patches, either order

Two parties patch the same method: a `notify` patch first, and a
`discount` patch over it. The first party finishes and removes its
patch, which is now underneath the other one. Predict what the
second party sees.

```{quiz}
:id: predict-inner-removal
:title: Predict removing the inner patch
:shuffle: true
question: "`inner` wraps `Shop.buy` with `notify`, then `outer` wraps it with `discount`. After `wrapt.unwrap_object(shop.cart, \"Shop.buy\", inner)`, what is on `Shop.buy`?"
options:
  - text: "Nothing: removing inner restores the original, and outer, which wrapped inner, is discarded with it."
    explanation: "Removal restores the attribute only when the wrapper is outermost. A buried wrapper is spliced out of the chain and what is above it is kept."
  - text: "outer over the original: inner is spliced out and outer now wraps what inner wrapped."
    correct: true
  - text: "It raises WrapperNotFoundError, since inner is not the outermost wrapper and cannot be found from the attribute."
    explanation: "The chain is walked from the outermost wrapper down, so inner is found beneath outer. Not found is for a wrapper that is not in the chain at all."
  - text: "Both remain, with inner disabled, because a wrapper cannot be removed while another depends on it."
    explanation: "outer holds inner only as the thing it wraps, and that link is updated to point at what inner wrapped. Nothing is disabled."
explanation: "A wrapper buried beneath other wrapt wrappers is spliced out in place: the wrapper above it is pointed at what it wrapped, the attribute is untouched, and the wrappers above keep working. So independent parties can remove their patches in any order."
```

Now the cell.

```{cell-insert}
:id: insert-two-patches
:path: {{ notebook }}
:tags: [two-patches]
:run: true
inner = wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", notify)
outer = wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", discount)

print("both installed   :", chain(shop.cart, "Shop.buy"))

wrapt.unwrap_object(shop.cart, "Shop.buy", inner)

print("inner removed    :", chain(shop.cart, "Shop.buy"))
print("still discounted :", corner.buy("fig"))
print("outer still there:", wrapt.is_wrapped_by(wrapt.resolve_path(shop.cart, "Shop.buy")[2], outer))

wrapt.unwrap_object(shop.cart, "Shop.buy", outer)

print("outer removed    :", chain(shop.cart, "Shop.buy"))
```

Two wrappers, then one, then none. Removing `inner` did not touch
the attribute: `outer` was still the object the class held, still the
handle the second party has, and now wraps the original directly.
The fig was discounted and not logged. Then `outer` came out as an
outermost wrapper does, restoring the original to the class.

That is what the handle buys over saving and restoring the original
by hand. A restore by assignment from the first party would have put
the original back over the top of `outer`, and the second party's
patch would have vanished without a word.

```{verify}
:id: two-patches
:label: The inner patch came out from under the outer one and both are gone
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed two-patches
chain(shop.cart, "Shop.buy") == ["function"] and wrapt.resolve_path(shop.cart, "Shop.buy")[2] is original and corner.basket[-1] == "fig"
```

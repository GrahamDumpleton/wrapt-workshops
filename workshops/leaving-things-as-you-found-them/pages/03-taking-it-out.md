---
title: Taking it out
requires: [verify:taking-it-out]
---

# Taking it out

`wrapt.unwrap_object` takes the same target and name as the wrap
function did, and the handle, and removes that wrapper. It returns
the wrapper it removed. Take the patch out, then try to take it out
again.

```{cell-insert}
:id: insert-taking-it-out
:path: {{ notebook }}
:tags: [taking-it-out]
:run: true
removed = wrapt.unwrap_object(shop.cart, "Shop.buy", handle)

print("removed the handle:", removed is handle)
print("chain now         :", chain(shop.cart, "Shop.buy"))
print("bought            :", corner.buy("apple"))

try:
    wrapt.unwrap_object(shop.cart, "Shop.buy", handle)
    second_removal = "no error"
except wrapt.WrapperNotFoundError as error:
    second_removal = f"WrapperNotFoundError: {error}"

print()
print("a second time     :", second_removal)
print("with missing_ok   :", wrapt.unwrap_object(shop.cart, "Shop.buy", handle, missing_ok=True))
```

The chain is back to one `function`, the same object as before, and
the call is no longer logged. The second removal raises
`WrapperNotFoundError`, naming the target, because the wrapper is
not on it any more; that is the default so that a mistake shows up
where it was made. Cleanup code that must not care, a shutdown path
that runs whether or not the patch was ever applied, or after a
third party replaced the attribute wholesale, passes
`missing_ok=True` and gets `None` back.

```{verify}
:id: taking-it-out
:label: The patch was removed once and the second removal was refused
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed taking-it-out
removed is handle and chain(shop.cart, "Shop.buy") == ["function"] and second_removal.startswith("WrapperNotFoundError") and wrapt.resolve_path(shop.cart, "Shop.buy")[2] is original
```

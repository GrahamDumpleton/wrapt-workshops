---
title: No residue
requires: [verify:no-residue]
---

# No residue

`Kiosk` inherits `buy` from `Shop` and defines nothing of its own.
Patch `Kiosk.buy`, look at the kiosk's own namespace, remove the
patch, and look again.

```{cell-insert}
:id: insert-no-residue
:path: {{ notebook }}
:tags: [no-residue]
:run: true
kiosk = Kiosk("Kiosk")

print("Kiosk defines buy before:", "buy" in Kiosk.__dict__)

kiosk_handle = wrapt.wrap_function_wrapper(shop.cart, "Kiosk.buy", notify)

print("Kiosk defines buy during:", "buy" in Kiosk.__dict__)
print("Shop's chain during     :", chain(shop.cart, "Shop.buy"))
kiosk.buy("apple")
corner.buy("apple")

wrapt.unwrap_object(shop.cart, "Kiosk.buy", kiosk_handle)

print()
print("Kiosk defines buy after :", "buy" in Kiosk.__dict__)
print("kiosk still buys        :", kiosk.buy("pear"))
```

The patch went into `Kiosk`'s namespace, shadowing the inherited
method, so the kiosk's call was logged and the corner store's was
not: that is what patching through the subclass means, and `Shop`'s
chain never changed. Removal then deleted the shadowing entry rather
than writing the original into `Kiosk`, because the wrap recorded,
on the wrapper, that it had created the slot. Leaving a copy of
`Shop.buy` in `Kiosk` would have looked harmless and been a residue:
a later patch on `Shop.buy` would not have reached kiosks. After
removal the class is exactly as it was shipped.

```{verify}
:id: no-residue
:label: The kiosk's patch left nothing in its namespace
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed no-residue
"buy" not in Kiosk.__dict__ and chain(shop.cart, "Shop.buy") == ["function"] and kiosk.basket == ["apple", "pear"]
```

```{hint}
:title: The same rule for one object
A patch on one object, `wrapt.wrap_function_wrapper(corner, "buy",
notify)`, goes into that object's own namespace in the same way, and
`wrapt.unwrap_object(corner, "buy", handle)` deletes the entry rather
than storing a bound method there. Anywhere a wrap created the slot,
removal removes the slot.
```

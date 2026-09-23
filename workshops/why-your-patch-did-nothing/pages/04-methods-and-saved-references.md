---
title: Methods, and saved references
requires: [verify:methods-and-saved]
---

# Methods, and saved references

{open}`shop/cart.py` takes the other route to the same function:
`from shop import pricing`, and `pricing.fetch_price` at the call,
which is an attribute lookup on the module every time `buy` runs.

Patch `shop.pricing` again and buy something.

```{cell-insert}
:id: insert-through-module
:path: {{ notebook }}
:tags: [through-module]
:run: true
calls.clear()

pricing_handle = wrapt.wrap_function_wrapper(shop.pricing, "fetch_price", capture)

corner = Shop("Corner Store")
corner.buy("apple")
seen_by_buy = len(calls)

wrapt.unwrap_object(shop.pricing, "fetch_price", pricing_handle)

print("calls seen by buy:", seen_by_buy)
```

One call, seen. `buy` reads `fetch_price` off the module at call
time, so it gets whatever the module holds now. The same lookup at
call time is what makes a method a safer target than a function: a
call through an object, `corner.buy(...)`, looks `buy` up on the
class each time, so a patch on `Shop.buy` reaches every shop, ones
made before the patch included, and every module that did
`from shop.cart import Shop`, since they hold the class and the class
holds the patch.

What a method does not survive is the same thing a function does
not: a reference taken before the patch. Save the bound method, then
patch, then call it both ways.

```{cell-insert}
:id: insert-saved-reference
:path: {{ notebook }}
:tags: [saved-reference]
:run: true
calls.clear()

saved = corner.buy

buy_handle = wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", capture)

corner.buy("pear")
seen_through_object = len(calls)

saved("fig")
seen_through_saved = len(calls) - seen_through_object

wrapt.unwrap_object(shop.cart, "Shop.buy", buy_handle)

print("seen through the object         :", seen_through_object)
print("seen through the saved reference:", seen_through_saved)
print("basket                          :", corner.basket)
```

The call through the object was seen and the call through the saved
bound method was not, though both bought their item. `saved` is a
method object made before the patch, holding the original function
and the shop, and calling it never looks at the class. A callback
registered before the patch, a method stored in a dictionary, a
default argument: all the same reference, taken early.

```{verify}
:id: methods-and-saved
:label: The lookup at call time saw the patch and the saved reference did not
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed saved-reference
seen_by_buy == 1 and seen_through_object == 1 and seen_through_saved == 0 and corner.basket == ["apple", "pear", "fig"]
```

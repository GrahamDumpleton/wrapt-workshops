---
title: One object, not all of them
requires: [verify:one-object]
---

# One object, not all of them

Every patch so far went on the class, so every shop got it. The
target can also be one object. `discount` takes a tenth off whatever
`buy` returns; install it on `market` alone and buy the same item
from both shops.

```{cell-insert}
:id: insert-one-object
:path: {{ notebook }}
:tags: [one-object]
:run: true
def discount(wrapped, instance, args, kwargs):
    return round(wrapped(*args, **kwargs) * 0.9, 3)

wrapt.wrap_function_wrapper(market, "buy", discount)

market_price = market.buy("fig")
corner_price = corner.buy("fig")

print()
print("market paid :", market_price)
print("corner paid :", corner_price)
print("in market's own namespace:", "buy" in vars(market))
print("in corner's own namespace:", "buy" in vars(corner))
```

The market paid `1.8` and the corner store paid `2.0`, and both calls
were still logged by the `notify` patch on the class, because the
wrapper on `market` wraps what `market.buy` resolved to, the bound
method, patch and all. The patch lives in `market`'s own namespace,
where lookup on that one object finds it first, and `corner` has
nothing there, so it goes to the class as before.

`wrapped` arrived already bound to `market`, and the wrapper's
`instance` is `market` too, so a wrapper written for the class works
unchanged on one object. That is what a wrapper for a single
connection, one session or one test double looks like.

```{verify}
:id: one-object
:label: Only the market's buy was discounted
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed one-object
market_price == 1.8 and corner_price == 2.0 and "buy" in vars(market) and "buy" not in vars(corner)
```

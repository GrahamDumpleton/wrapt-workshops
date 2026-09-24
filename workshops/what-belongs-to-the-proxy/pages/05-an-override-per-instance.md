---
title: An override per instance
requires: [quiz:refund-on-the-class, verify:override-per-instance]
---

# An override per instance

`Counted` intercepts `buy` by defining a method of the same name, and
a method on the class is on every `Counted`, whatever it wraps. That
is right for `buy`, which every shop has. Now suppose only some shops
take an item back: a `Market` has `refund`, a plain `Shop` does not,
and the checkout code asks with `hasattr` before calling it.

The proxy should count refunds as it counts purchases. But a `refund`
method on the class would put one on every counted shop, and a
counted corner shop would then answer `hasattr` with yes and forward
the call to a shop that has no `refund`. Whether the proxy has the
override has to vary by instance, decided in `__init__` from what the
wrapped object has. That is what `__self_setattr__` is for: it stores
an attribute on the proxy itself, under any name, so this proxy
carries `refund` only when its target does.

```{quiz}
:id: refund-on-the-class
:title: Predict the class-level version
:shuffle: true
question: "If `Counted` defined `refund` on the class, the way it defines `buy`, what would `return_item(Counted(shop), \"apple\")` do for the corner shop, which has no `refund`?"
options:
  - text: "Find `refund` on the proxy, call it, and raise `AttributeError` when it forwards to the shop."
    correct: true
  - text: "Return `None`, because `hasattr` looks through the proxy to the shop."
    explanation: "`hasattr` looks the name up on the proxy, and normal lookup finds a method on the proxy's class before anything is forwarded. The shop is never asked."
  - text: "Return `None`, because a method that only forwards is skipped when the target lacks it."
    explanation: "Nothing skips a method. It is called like any other, and the failure comes when its body reaches for `self.__wrapped__.refund`."
explanation: "A method on the class is there for every instance, so `hasattr` says yes for every counted shop, whatever it wraps. Making it depend on the target means putting it on the instance, in `__init__`."
```

```{cell-insert}
:id: insert-override-per-instance
:path: {{ notebook }}
:tags: [override-per-instance]
:run: true
class Market(Shop):
    def refund(self, item):
        return fetch_price(item)

def return_item(candidate, item):
    if hasattr(candidate, "refund"):
        return candidate.refund(item)
    return None

class Counted(wrapt.BaseObjectProxy):
    def __init__(self, wrapped):
        super().__init__(wrapped)
        self._self_count = 0
        if hasattr(wrapped, "refund"):
            self.__self_setattr__("refund", self._self_refund)

    def buy(self, item):
        self._self_count += 1
        return self.__wrapped__.buy(item)

    def _self_refund(self, item):
        self._self_count += 1
        return self.__wrapped__.refund(item)

corner = Counted(shop)
market = Counted(Market("market"))

market.buy("apple")
refunded = return_item(market, "apple")
skipped = return_item(corner, "apple")

print("market has refund:", hasattr(market, "refund"), "count", market._self_count)
print("corner has refund:", hasattr(corner, "refund"), "count", corner._self_count)
print("refunded         :", refunded)
print("skipped          :", skipped)
print("refund on shop?  :", "refund" in vars(shop))
```

The same class, two instances, and only one of them has `refund`.
The market's proxy counted the purchase and the refund; the corner
shop's proxy answered `hasattr` with no, so `return_item` left it
alone, and the shop itself was not given a `refund` either. The
implementation is an ordinary method under a `_self_` name, so it is
on the class like `buy`, and the one line in `__init__` decides, per
instance, whether it is reachable under the name the checkout code
uses.

This is the previous workshop's line drawn on purpose, at instance
level: a proxy claims only what its target can do, and when that
differs from one target to the next, the claim is made per instance.

```{verify}
:id: override-per-instance
:label: Only the proxy over the market has refund, and the count includes it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed override-per-instance
hasattr(market, "refund") and not hasattr(corner, "refund") and refunded == 0.5 and skipped is None and market._self_count == 2 and corner._self_count == 0 and "refund" in market.__self_dict__ and "refund" not in vars(shop)
```

```{hint}
:title: Why not object.__setattr__
`object.__setattr__(self, "refund", ...)` does the same thing, and on
the Python this notebook runs it works. On Python 3.12 and earlier it
raises `TypeError: can't apply this __setattr__` when the proxy comes
from wrapt's C extension, which is what a plain install gets, because
CPython used to refuse it for any type that overrides attribute
setting at the C level. `__self_setattr__` exists so that there is
one spelling that works everywhere, and it is the one to use while
those versions are supported.
```

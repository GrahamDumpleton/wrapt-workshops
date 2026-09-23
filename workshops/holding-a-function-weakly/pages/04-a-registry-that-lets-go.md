---
title: A registry that lets go
requires: [verify:registry]
---

# A registry that lets go

The callback is what turns the proxy into a registry entry that
cleans up after itself. Register two shops' `buy` methods, with a
callback that removes the entry when its shop is collected, and drop
one shop.

```{cell-insert}
:id: insert-registry
:path: {{ notebook }}
:tags: [registry]
:run: true
listeners = []

def register(method):
    def forget(proxy):
        listeners[:] = [entry for entry in listeners if entry is not proxy]
    listeners.append(wrapt.WeakFunctionProxy(method, callback=forget))

corner = Shop("corner")
market = Shop("market")

register(corner.buy)
register(market.buy)
print("registered:", [listener("fig") for listener in listeners])

del market
gc.collect()

remaining = [listener("fig") for listener in listeners]
print("remaining :", remaining)
```

Two entries, then one. The registry never held either shop, so
dropping the name `market` was enough for its shop to be collected,
and the callback took the dead entry out before anything could call
it. Code that iterates the registry never meets a `ReferenceError`,
and no shop lives longer than its owner meant it to.

The `forget` callback compares entries by identity rather than
removing by value on purpose: two proxies over the same method of
two shops compare equal, because equality is forwarded to the
function underneath, and removing by value would take out the wrong
one.

```{verify}
:id: registry
:label: The dropped shop's entry removed itself from the registry
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed registry
remaining == ["corner sells fig"] and len(listeners) == 1
```

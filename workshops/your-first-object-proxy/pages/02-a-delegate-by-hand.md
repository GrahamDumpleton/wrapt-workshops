---
title: A delegate by hand
requires: [verify:delegate-works]
---

# A delegate by hand

Start from the proxy you would write today. `Delegate` holds the
target and defines `__getattr__`, which Python calls only when normal
lookup finds nothing, so every attribute the delegate does not have
itself is fetched from the target.

```{cell-insert}
:id: insert-delegate
:path: {{ notebook }}
:tags: [delegate]
:run: true
class Delegate:
    def __init__(self, target):
        self._target = target

    def __getattr__(self, name):
        return getattr(self._target, name)

delegate = Delegate(shop)

price = delegate.buy("apple")

print("name :", delegate.name)
print("price:", price)
```

The name comes through, and so does the method: `delegate.buy` is
looked up on the delegate, not found, fetched from the shop already
bound to it, and called. For attribute reads and method calls this
is a proxy, and it looks done.

```{verify}
:id: delegate-works
:label: The delegate forwards attribute reads and method calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed delegate
delegate.name == "corner" and price == 0.5
```

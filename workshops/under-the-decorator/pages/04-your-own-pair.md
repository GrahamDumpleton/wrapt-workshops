---
title: Your own pair
requires: [verify:own-pair]
---

# Your own pair

The unbound and bound classes come as a pair, and a subclass of
`FunctionWrapper` names its bound partner through
`__bound_function_wrapper__`, so behaviour of yours can live on the
bound side, where the instance is known. This pair records which
shop each call was made on, in the bound class's `__call__`, before
handing on to the normal machinery.

```{cell-insert}
:id: insert-own-pair
:path: {{ notebook }}
:tags: [own-pair]
:run: true
seen = []

class Announcing(wrapt.BoundFunctionWrapper):
    def __call__(self, *args, **kwargs):
        seen.append(self._self_instance)
        return super().__call__(*args, **kwargs)

class Traced(wrapt.FunctionWrapper):
    __bound_function_wrapper__ = Announcing

class Shop:
    def __init__(self, name):
        self.name = name

    def buy(self, item):
        return fetch_price(item)

    buy = Traced(buy, wrapper)

corner = Shop("corner")
market = Shop("market")

corner.buy("apple")
market.buy("pear")

print("bound type:", type(corner.buy).__name__)
print("seen      :", [instance.name for instance in seen])
```

`Traced` in the class body, `Announcing` when read through a shop,
and each call recorded against the shop it was bound to. Nothing
else was written: the descriptor, the binding and the call to your
wrapper all came from the base classes.

This is the machinery the `@wrapt.decorator` API stands on, and the
reason a wrapt decorator is right on methods without a special case:
it is not a function pretending to be a method, it is a descriptor
that binds the way the thing it wrapped would have.

```{verify}
:id: own-pair
:label: The bound subclass saw both shops
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed own-pair
type(corner.buy).__name__ == "Announcing" and [instance.name for instance in seen] == ["corner", "market"]
```

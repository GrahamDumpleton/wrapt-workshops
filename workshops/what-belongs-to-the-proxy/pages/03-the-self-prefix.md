---
title: The prefix that stays on the proxy
requires: [quiz:predict-self, verify:self-prefix]
---

# The prefix that stays on the proxy

A proxy keeps an attribute to itself by naming it with the `_self_`
prefix. The proxy's `__setattr__` stores any such name on the proxy
and forwards every other name to the target, and the same rule
applies to reading and deleting.

Predict before running: the subclass below sets `self._self_count`
in its `__init__`, and its `buy` method increments it before calling
the shop's.

```{quiz}
:id: predict-self
:title: Predict where the count lives
:shuffle: true
question: "After two calls to `counted.buy(...)`, where is `_self_count`?"
options:
  - text: "On the proxy, and `hasattr(shop, \"_self_count\")` is false."
    correct: true
  - text: "On the shop, like `count` on the previous page."
    explanation: "The prefix is the difference. `count` was forwarded; `_self_count` is stored on the proxy by its `__setattr__`."
  - text: "On both, since the proxy stores it and then forwards it."
    explanation: "A `_self_` name is stored on the proxy and never forwarded. The shop has no idea the count exists."
explanation: "`_self_` names live on the proxy, and only there. Everything else is the target's."
```

```{cell-insert}
:id: insert-self-prefix
:path: {{ notebook }}
:tags: [self-prefix]
:run: true
class Counted(wrapt.BaseObjectProxy):
    def __init__(self, wrapped):
        super().__init__(wrapped)
        self._self_count = 0

    def buy(self, item):
        self._self_count += 1
        return self.__wrapped__.buy(item)

counted = Counted(shop)

counted.buy("apple")
counted.buy("pear")

print("counted._self_count:", counted._self_count)
print("on the shop?       :", hasattr(shop, "_self_count"))
print("still a Shop?      :", isinstance(counted, Shop))
print("still the name?    :", counted.name)
```

Two calls, a count of two, and the shop knows nothing about it. Two
things in the cell are worth reading twice. `buy` is defined on the
proxy class, so normal lookup finds it before the proxy would forward
to the shop, which is how a proxy intercepts an ordinary method: it
defines one of the same name and calls through `self.__wrapped__`.
And `_self_count` is written with plain `self._self_count = 0`; the
prefix is the whole mechanism, and nothing else is declared.

```{verify}
:id: self-prefix
:label: The count is on the proxy and not on the shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed self-prefix
counted._self_count == 2 and not hasattr(shop, "_self_count") and isinstance(counted, Shop)
```

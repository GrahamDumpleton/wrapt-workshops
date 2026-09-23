---
title: On the class
requires: [verify:on-the-class]
---

# On the class

Define `__getitem__` on a subclass. It records the key and then does
what the dictionary would have done, by asking the dictionary through
`self.__wrapped__`.

```{cell-insert}
:id: insert-on-the-class
:path: {{ notebook }}
:tags: [on-the-class]
:run: true
class Watched(wrapt.BaseObjectProxy):
    def __init__(self, wrapped):
        super().__init__(wrapped)
        self._self_reads = []

    def __getitem__(self, key):
        self._self_reads.append(key)
        return self.__wrapped__[key]

watched = Watched(settings)

currency_read = watched["currency"]
debug_read = watched["debug"]

print("reads         :", watched._self_reads)
print("still a dict  :", isinstance(watched, dict))
print("len           :", len(watched))
print("'region' in it:", "region" in watched)
print("keys          :", list(watched.keys()))
```

Two reads, two keys recorded, and everything not overridden still
passes through: `len`, `in`, `keys()` and `isinstance` all answer
for the dictionary. That is the shape of every custom proxy. Define
the special methods you want to see, call the target's version
through `self.__wrapped__` inside them, keep your own state under
`_self_` names, and leave the rest to the base class.

Compare it with the delegating class you might have written by hand.
For that class to be a dictionary to the code receiving it, every
special method it might meet would have to be written out, and the
one you forgot would be the one that broke. Here only the method
that changes is written.

```{verify}
:id: on-the-class
:label: The subclass records the keys read and passes the rest through
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed on-the-class
watched._self_reads == ["currency", "debug"] and currency_read == "USD" and isinstance(watched, dict) and len(watched) == 3
```

---
title: A proxy for a dictionary
requires: [verify:watched-settings]
---

# A proxy for a dictionary

`Watched` is a proxy for a dictionary that records which keys are
read. Four things in it are all a patch needs to know about
proxies. `super().__init__(wrapped)` stores the original, reachable
afterwards as `self.__wrapped__`. An attribute of the proxy's own,
`_self_reads`, starts with `_self_`: any other name would be
forwarded to the dictionary, which has no such attribute to set.
`__getitem__` is defined on the class, because a special method is
looked up on the type, never on the instance, so a proxy intercepts
a special method only by defining it. And `__iter__` intercepts
nothing. It is there because `BaseObjectProxy` leaves out the few
special methods whose presence says what an object is: with
`__iter__` on the base class every proxy would look iterable, and
with `__call__` every proxy would look callable, whatever the
original was. A proxy over something iterable or callable adds
the method itself.

`wrapt.wrap_object` takes the module, the name, and the factory, calls
the factory with the original, and installs what it returns.

```{cell-insert}
:id: insert-watched
:path: {{ notebook }}
:tags: [watched]
:run: true
class Watched(wrapt.BaseObjectProxy):
    def __init__(self, wrapped):
        super().__init__(wrapped)
        self._self_reads = []

    def __getitem__(self, key):
        self._self_reads.append(key)
        return self.__wrapped__[key]

    def __iter__(self):
        return iter(self.__wrapped__)

watched = wrapt.wrap_object(shop.config, "settings", Watched)

shop.config.currency()
shop.config.tax_rate()
shop.config.currency()

reads = list(watched._self_reads)

print("reads         :", reads)
print("installed     :", watched is shop.config.settings)
print("chain         :", chain(shop.config, "settings"))
print("still a dict? :", isinstance(watched, dict))
print("still equal?  :", watched == {"currency": "USD", "tax_rate": 0.1})
print("still works?  :", watched["currency"], len(watched), sorted(watched))
```

Three reads, in order, and the module noticed nothing: `currency()`
and `tax_rate()` did `settings[...]` as they always did and got their
values. The last line of the cell reads a fourth time, through the
proxy directly, which is recorded too. To `isinstance` the proxy is
a `dict`, to `==` it is equal to the original, and `len` and
everything else pass through, because `BaseObjectProxy` forwards
every attribute, and every special method it does define, to the
original, `__class__` included. Iteration passes through because
`Watched` said so. The one thing that gives it away is `type()`,
which the `chain` helper uses.

`wrap_object` returned the proxy, which is the handle, as with every
wrap function.

```{verify}
:id: watched-settings
:label: The proxy recorded the reads and stands in for the dictionary
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed watched
reads == ["currency", "tax_rate", "currency"] and watched is shop.config.settings and chain(shop.config, "settings") == ["Watched", "dict"] and isinstance(watched, dict) and sorted(watched) == ["currency", "tax_rate"]
```

```{hint}
:title: Which special methods are left out
Calling and iteration, the iterator's `__next__` and the async
forms of both, awaiting, `__length_hint__`, `__fspath__`, and the
descriptor protocol, `__get__`, `__set__`, `__delete__` and
`__set_name__`. Each says something about what kind of object this
is, so each is left for the proxy class to add. The "Special
Object Methods" section of the
[proxies and wrappers guide](https://wrapt.readthedocs.io/en/latest/wrappers.html)
has the reasoning, and `wrapt.AutoObjectProxy` adds them for you
by inspecting the original, at the cost of a class per instance.
```

```{hint}
:title: Why not subclass dict
A subclass of `dict` would need the module's dictionary copied into
it, and from then on there would be two dictionaries: the module
writes to the proxy, another holder of the original writes to the
original, and they drift. The proxy holds the one dictionary and
forwards to it, so every holder sees the same data.
```

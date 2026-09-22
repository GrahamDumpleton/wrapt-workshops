---
title: A cache per instance
requires: [verify:per-instance, verify:collected-and-unhashable]
---

# A cache per instance

`wrapt.lru_cache` is `functools.lru_cache` with the cache in a
different place. On an instance method, the first call on an instance
creates a `functools.lru_cache` for that instance and stores it as an
attribute of the instance, and every call on that instance goes
through it. Same decorator, same options, applied the same way.

```{cell-insert}
:id: insert-per-instance
:path: {{ notebook }}
:tags: [per-instance]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    @wrapt.lru_cache(maxsize=2)
    def quote(self, item):
        return f"{self.name}: {PRICES[item]}"

corner = Shop("Corner Store")
high_street = Shop("High Street")

corner.quote("apple")
corner.quote("pear")
high_street.quote("apple")
corner.quote("apple")

corner_info = corner.quote.cache_info()
high_street_info = high_street.quote.cache_info()

print("corner     :", corner_info)
print("high street:", high_street_info)
print("on corner  :", [name for name in vars(corner) if name.startswith("_lru_cache_")])
```

The same four lookups, and this time the last one is a hit: the
Corner Store has a cache of two holding apple and pear, and the High
Street has a cache of its own holding one. Each instance has the full
`maxsize` to itself. The attribute on the instance is the cache, named
after the method with a suffix that keeps an overriding method in a
subclass from sharing the slot.

```{verify}
:id: per-instance
:label: Each shop has a cache of its own
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed per-instance
corner_info.hits == 1 and corner_info.misses == 2 and high_street_info.misses == 1 and high_street_info.currsize == 1
```

## The other two problems

With the cache on the instance, nothing outside the instance refers
to it, so it is freed when its last name goes, and nothing hashes it,
so the basket needs no `__hash__`.

```{cell-insert}
:id: insert-collected
:path: {{ notebook }}
:tags: [collected]
:run: true
still_there = weakref.ref(corner)

del corner
gc.collect()
collected = still_there() is None
print("corner freed after del:", collected)

class Basket:
    def __init__(self, items):
        self.items = items

    def __eq__(self, other):
        return self.items == other.items

    @wrapt.lru_cache
    def total(self):
        return sum(PRICES[item] for item in self.items)

basket = Basket(["apple", "pear"])
total = basket.total()
basket.total()
basket_info = basket.total.cache_info()

print("total:", total, basket_info)
```

The cache goes with the instance, because it is part of the instance,
and the unhashable basket caches its total like anything else. Neither
needed a change to the class.

```{verify}
:id: collected-and-unhashable
:label: The shop was freed and the unhashable basket was cached
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed collected
collected and total == 1.25 and basket_info.hits == 1 and basket_info.misses == 1
```

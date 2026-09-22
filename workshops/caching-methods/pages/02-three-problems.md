---
title: Three problems
requires: [verify:three-problems]
---

# Three problems

`functools.lru_cache` on a method. The cache is on the function, in
the class, and there is one of it; every call from every instance
goes through it, with `self` as the first part of the key.

## One budget for everyone

`maxsize=2` is small so the effect shows at once. Two shops, three
lookups, and then the first lookup again.

```{cell-insert}
:id: insert-shared-budget
:path: {{ notebook }}
:tags: [shared-budget]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    @functools.lru_cache(maxsize=2)
    def quote(self, item):
        return f"{self.name}: {PRICES[item]}"

corner = Shop("Corner Store")
high_street = Shop("High Street")

corner.quote("apple")
corner.quote("pear")
high_street.quote("apple")
corner.quote("apple")

shared_info = Shop.quote.cache_info()
print(shared_info)
```

Four misses and no hits. The High Street lookup evicted the Corner
Store's apple, because the two shops share one cache of two entries.
A cache with `maxsize=128` shared across a hundred instances holds
about one entry each, which is no cache at all.

## Instances that never go away

The key holds `self`, and the cache holds the key.

```{cell-insert}
:id: insert-held-alive
:path: {{ notebook }}
:tags: [held-alive]
:run: true
still_there = weakref.ref(corner)

del corner
gc.collect()
alive_through_cache = still_there() is not None
print("corner alive after del:", alive_through_cache)

Shop.quote.cache_clear()
gc.collect()
freed_after_clear = still_there() is None
print("corner alive after cache_clear:", not freed_after_clear)
```

Deleting the last name did not free the shop, because the cache's
keys still referred to it, and only clearing the cache let it go.
Every instance that ever called `quote` stays alive until it is
evicted or the cache is cleared, which for an unbounded cache is
never. That is the memory leak that comes free with caching a method.

## Anything unhashable

The key is hashed, so `self` must be. A class that defines `__eq__`
and not `__hash__` has `__hash__` set to `None` by Python, and its
instances cannot be keys.

```{cell-insert}
:id: insert-unhashable
:path: {{ notebook }}
:tags: [unhashable]
:run: true
class Basket:
    def __init__(self, items):
        self.items = items

    def __eq__(self, other):
        return self.items == other.items

    @functools.lru_cache
    def total(self):
        return sum(PRICES[item] for item in self.items)

try:
    Basket(["apple", "pear"]).total()
except TypeError as exc:
    hash_problem = str(exc)
    print("TypeError:", hash_problem)
```

Nothing about `total` is unusual. The cache refuses the call because
its owner cannot be hashed, and the fix in the standard library is to
give the class a `__hash__`, which may be wrong for a class whose
instances are meant to compare by value.

```{verify}
:id: three-problems
:label: The shared budget, the held instance and the unhashable basket all showed
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed unhashable
shared_info.misses == 4 and shared_info.hits == 0 and alive_through_cache and freed_after_clear and hash_problem == "unhashable type: 'Basket'"
```

```{hint}
:title: If the held instance check fails
`alive_through_cache` is false if something else freed the shop, and
`freed_after_clear` is false if something else still refers to it.
Running the cells on this page out of order, or twice, can do either.
Run them in order from the top of the page.
```

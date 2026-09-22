---
title: Pickling
requires: [verify:pickled]
---

# Pickling

The cache on the instance is a `functools._lru_cache_wrapper`, and
that object cannot be pickled. An instance whose cached method has
been called therefore cannot be pickled either, until it is told to
leave the cache behind.

```{cell-insert}
:id: insert-pickle-problem
:path: {{ notebook }}
:tags: [pickle-problem]
:run: true
shop = Shop("Corner Store")
shop.quote("apple")

try:
    pickle.dumps(shop)
except Exception as exc:
    pickle_problem = type(exc).__name__
    print(f"{pickle_problem}: {exc}")
```

The fix is a `__getstate__` that drops the cache attributes, which all
begin with `_lru_cache_`. The cache is recreated on the next call after
unpickling, empty, which is the right state for a cache that has
crossed a process boundary.

```{cell-insert}
:id: insert-getstate
:path: {{ notebook }}
:tags: [getstate]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    @wrapt.lru_cache(maxsize=2)
    def quote(self, item):
        return f"{self.name}: {PRICES[item]}"

    def __getstate__(self):
        return {
            name: value
            for name, value in self.__dict__.items()
            if not name.startswith("_lru_cache_")
        }

shop = Shop("Corner Store")
shop.quote("apple")

restored = pickle.loads(pickle.dumps(shop))

print("restored      :", restored.name, restored.quote.cache_info())
print("first call    :", restored.quote("apple"))
restored_info = restored.quote.cache_info()
print("after the call:", restored_info)
```

Straight after unpickling the restored shop has no cache, so
`cache_info()` says `None`, and the first call makes one. To drop the
cache of one method and keep the others, filter on the longer
`_lru_cache_<name>_` prefix instead.

```{verify}
:id: pickled
:label: The cache stopped pickling and __getstate__ fixed it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed getstate
pickle_problem == "PicklingError" and restored.name == "Corner Store" and restored_info.misses == 1
```

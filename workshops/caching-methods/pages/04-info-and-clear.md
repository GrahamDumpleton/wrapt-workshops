---
title: Info and clear
requires: [verify:scoped-operations]
---

# Info and clear

`cache_info()`, `cache_clear()` and `cache_parameters()` are on the
decorated method as they are on the standard library's. Called on a
bound method, they operate on that instance's cache and no other.

```{cell-insert}
:id: insert-clear
:path: {{ notebook }}
:tags: [clear]
:run: true
shop_a = Shop("A")
shop_b = Shop("B")

shop_a.quote("apple")
shop_b.quote("apple")

shop_a.quote.cache_clear()

a_after = shop_a.quote.cache_info()
b_after = shop_b.quote.cache_info()

print("A after clearing A:", a_after)
print("B after clearing A:", b_after)
print("through the class :", Shop.quote.cache_info())
```

Clearing A left B alone. Asked through the class, with no instance
to find a cache on, `cache_info()` returns `None`: there is no cache
there, only the decorator.

## Where there is no instance

On a plain function, a class method or a static method there is
nothing to keep a cache per instance of, so `wrapt.lru_cache` keeps
one shared cache, on the wrapper, the same as the standard library.

```{cell-insert}
:id: insert-shared
:path: {{ notebook }}
:tags: [shared]
:run: true
@wrapt.lru_cache
def fibonacci(n):
    return n if n < 2 else fibonacci(n - 1) + fibonacci(n - 2)

class Catalogue:
    @wrapt.lru_cache
    @classmethod
    def lookup(cls, item):
        return PRICES[item]

    @wrapt.lru_cache
    @staticmethod
    def convert(price, rate):
        return price * rate

fibonacci(10)
Catalogue.lookup("apple")
Catalogue.lookup("apple")
Catalogue.convert(0.5, 2)

fib_info = fibonacci.cache_info()
lookup_info = Catalogue.lookup.cache_info()
convert_info = Catalogue.convert.cache_info()

print("function     :", fib_info, fibonacci.cache_parameters())
print("class method :", lookup_info)
print("static method:", convert_info)
```

The recursive `fibonacci` shows the cache working through the
wrapper: the recursive calls go through the decorated name, so all
but eleven of them are hits.

```{verify}
:id: scoped-operations
:label: Clearing one instance left the other, and the shared caches count
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed shared
a_after.currsize == 0 and b_after.currsize == 1 and fib_info.hits == 8 and fib_info.misses == 11 and lookup_info.hits == 1 and convert_info.misses == 1
```

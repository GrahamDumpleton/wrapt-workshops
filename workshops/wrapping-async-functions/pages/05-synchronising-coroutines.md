---
title: Synchronising coroutines
requires: [verify:serialised]
---

# Synchronising coroutines

`wrapt.synchronized` from the previous workshop works on coroutines
too. Applied to an `async def`, it sees that from `wrapped` the same
way the timer did, and switches to an `asyncio.Lock` per context,
acquired with `await` and held across the awaited call. The `async
with wrapt.synchronized(self):` form shares that lock, as the
synchronous form shares its `RLock`.

Three coroutines on one cache, started together with
`asyncio.gather`: two lookups around a refresh.

```{cell-insert}
:id: insert-async-lock
:path: {{ notebook }}
:tags: [async-lock]
:run: true
class PriceCache:
    def __init__(self):
        self.prices = {}
        self.log = []

    @wrapt.synchronized
    async def get(self, item):
        self.log.append(f"get {item} start")
        await asyncio.sleep(0.02)
        self.log.append(f"get {item} end")
        return self.prices.get(item)

    async def refresh(self, item):
        async with wrapt.synchronized(self):
            self.log.append(f"refresh {item} start")
            await asyncio.sleep(0.02)
            self.prices[item] = PRICES[item]
            self.log.append(f"refresh {item} end")

cache = PriceCache()

start = time.perf_counter()
results = await asyncio.gather(cache.get("apple"), cache.refresh("apple"), cache.get("apple"))
elapsed_ms = (time.perf_counter() - start) * 1000

print("results:", results)
print(f"elapsed: {elapsed_ms:.0f}ms")
for entry in cache.log:
    print(entry)
print("the lock:", type(vars(cache)["_synchronized_async_lock"]).__name__)
```

Sixty milliseconds and a log in strict pairs: each start is followed
by its own end, never by another start. Without the lock, all three
would have started before any finished, and the log would read three
starts and then three ends. The first lookup found nothing, the
refresh filled the cache, and the second lookup found the price.

The lock is an `asyncio.Lock`, under a name of its own,
`_synchronized_async_lock`, separate from the `RLock` the synchronous
form would put on the same object. The two do not exclude each
other, so a class should synchronise with one protocol or the other,
not both.

```{verify}
:id: serialised
:label: The three coroutines ran one at a time
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed async-lock
results == [None, None, 0.5] and cache.log == ["get apple start", "get apple end", "refresh apple start", "refresh apple end", "get apple start", "get apple end"]
```

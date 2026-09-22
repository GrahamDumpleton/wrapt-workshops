---
title: Not reentrant
requires: [verify:shadow-coroutine]
---

# Not reentrant

The synchronous lock was an `RLock`, so a synchronised method could
call another on the same object. `asyncio.Lock` has no reentrant
form. A synchronised coroutine that awaits another synchronised
coroutine on the same object waits for a lock it holds itself, and
waits forever.

The cell asks for a lookup that refreshes on a miss, written the
obvious way, and gives it a tenth of a second before cancelling it.

```{cell-insert}
:id: insert-deadlock
:path: {{ notebook }}
:tags: [deadlock]
:run: true
class PriceCache:
    def __init__(self):
        self.prices = {}

    @wrapt.synchronized
    async def get(self, item):
        await asyncio.sleep(0.02)
        return self.prices.get(item)

    @wrapt.synchronized
    async def get_or_refresh(self, item):
        price = await self.get(item)
        if price is None:
            self.prices[item] = price = PRICES[item]
        return price

cache = PriceCache()

try:
    await asyncio.wait_for(cache.get_or_refresh("pear"), timeout=0.1)
except TimeoutError as exc:
    outcome = type(exc).__name__
    print(f"{outcome}: get_or_refresh never finished and was cancelled")
```

`get_or_refresh` took the lock, then awaited `get`, which asked for
the same lock and was queued behind its own caller. The timeout
cancelled the whole thing, and the cancellation unwound both
coroutines and released the lock, so the cache is usable again.

The idiom from wrapt's documentation is to split the locking from
the logic. Public coroutines take the lock and call a private one,
conventionally with a leading underscore, that does the work and
assumes the lock is already held. A public coroutine that needs the
logic of another calls the private form.

```{cell-insert}
:id: insert-shadow
:path: {{ notebook }}
:tags: [shadow]
:run: true
class PriceCache:
    def __init__(self):
        self.prices = {}

    @wrapt.synchronized
    async def get(self, item):
        return await self._get(item)

    @wrapt.synchronized
    async def get_or_refresh(self, item):
        price = await self._get(item)
        if price is None:
            self.prices[item] = price = PRICES[item]
        return price

    async def _get(self, item):
        # Assumes the caller holds the lock.
        await asyncio.sleep(0.02)
        return self.prices.get(item)

cache = PriceCache()

pear = await cache.get_or_refresh("pear")
again = await cache.get("pear")

print("refreshed:", pear)
print("cached   :", again)
```

Two locked entry points, one unlocked body, and no coroutine ever
takes the lock twice. If real reentrancy is needed, the automatic
lock cannot provide it; a task-aware reentrant lock of your own can
be passed to `wrapt.synchronized(lock)` instead.

```{verify}
:id: shadow-coroutine
:label: The nested call timed out and the private coroutine fixed it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed shadow
outcome == "TimeoutError" and pear == 0.75 and again == 0.75
```

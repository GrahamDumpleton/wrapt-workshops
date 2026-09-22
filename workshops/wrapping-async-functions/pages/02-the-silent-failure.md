---
title: The silent failure
requires: [verify:timed-nothing]
---

# The silent failure

The timer from the first workshop, on the `async def` version of
`fetch_price`.

```{cell-insert}
:id: insert-sync-timer
:path: {{ notebook }}
:tags: [sync-timer]
:run: true
@wrapt.decorator
def timer(wrapped, instance, args, kwargs):
    start = time.perf_counter()
    try:
        return wrapped(*args, **kwargs)
    finally:
        reported[wrapped.__name__] = (time.perf_counter() - start) * 1000
        print(f"{wrapped.__name__} took {reported[wrapped.__name__]:.3f}ms")

@timer
async def fetch_price(item):
    """Look up the price of an item, slowly."""
    await asyncio.sleep(0.02)
    return PRICES[item]

result = fetch_price("pear")
print("the wrapper returned a", type(result).__name__)

price = await result
print("price:", price)
```

The timer reports a few microseconds, and it is not wrong about what
it measured. `wrapped(*args, **kwargs)` on an `async def` function
returns a coroutine object at once, the wrapper returns that, and the
timing is done. The twenty milliseconds happen later, on the `await`,
when nothing is watching. A logging decorator would log a call that
had not happened yet, and a lock would be released before the
guarded work began.

The closure version fails the same way, for the same reason. This is
not a wrapt problem, and wrapt's fix is the same as the closure's,
with one function fewer.

```{verify}
:id: timed-nothing
:label: The synchronous timer measured the creation of a coroutine
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed sync-timer
reported["fetch_price"] < 5 and price == 0.75
```

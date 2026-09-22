---
title: An async wrapper
requires: [verify:timed-the-run]
---

# An async wrapper

Make the wrapper `async def` and await `wrapped`.

```{cell-insert}
:id: insert-async-timer
:path: {{ notebook }}
:tags: [async-timer]
:run: true
@wrapt.decorator
async def timer(wrapped, instance, args, kwargs):
    start = time.perf_counter()
    try:
        return await wrapped(*args, **kwargs)
    finally:
        reported[wrapped.__name__] = (time.perf_counter() - start) * 1000
        print(f"{wrapped.__name__} took {reported[wrapped.__name__]:.1f}ms")

@timer
async def fetch_price(item):
    """Look up the price of an item, slowly."""
    await asyncio.sleep(0.02)
    return PRICES[item]

price = await fetch_price("fig")

print("price:", price)
print("still a coroutine function:", inspect.iscoroutinefunction(fetch_price))
```

Twenty milliseconds. It works because `wrapt.decorator` does not care
what the wrapper returns. Calling `fetch_price` runs the wrapper,
and the wrapper is `async def`, so what it returns is a coroutine
that has not started; the caller awaits it, which runs the wrapper's
body, which awaits the real `fetch_price` and times the whole thing.
The decorated `fetch_price` still reports as a coroutine function,
because the proxy forwards `__code__` and its flags from the
original.

The rule is that a wrapper takes the shape of what it wraps. An
`async def` wrapper is right for an `async def` function and wrong
for an ordinary one, which returns a plain value that cannot be
awaited, so this timer is not the timer from the first workshop and
cannot replace it.

```{verify}
:id: timed-the-run
:label: The async wrapper timed the coroutine's run
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed async-timer
reported["fetch_price"] >= 15 and price == 2.0 and inspect.iscoroutinefunction(fetch_price)
```

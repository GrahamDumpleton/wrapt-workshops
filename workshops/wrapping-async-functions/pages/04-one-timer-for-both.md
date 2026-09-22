---
title: One timer for both
requires: [verify:both-timed]
---

# One timer for both

A decorator that will be applied to both kinds of function looks at
`wrapped` and does the right thing for each. The wrapper stays an
ordinary `def`. For a coroutine function it builds an inner coroutine
that awaits `wrapped` and reports, and returns that for the caller to
await; for anything else it calls `wrapped` and reports at once.

```{cell-insert}
:id: insert-dual-timer
:path: {{ notebook }}
:tags: [dual-timer]
:run: true
@wrapt.decorator
def timer(wrapped, instance, args, kwargs):
    start = time.perf_counter()

    def report():
        reported[wrapped.__name__] = (time.perf_counter() - start) * 1000
        print(f"{wrapped.__name__} took {reported[wrapped.__name__]:.1f}ms")

    if inspect.iscoroutinefunction(wrapped):
        async def timed():
            try:
                return await wrapped(*args, **kwargs)
            finally:
                report()

        return timed()

    try:
        return wrapped(*args, **kwargs)
    finally:
        report()

@timer
def fetch_price_now(item):
    time.sleep(0.02)
    return PRICES[item]

@timer
async def fetch_price(item):
    await asyncio.sleep(0.02)
    return PRICES[item]

now = fetch_price_now("apple")
later = await fetch_price("pear")

print("prices:", now, later)
```

Both report twenty milliseconds. The test is on `wrapped`, so it
works for a method too, since `wrapped` is the bound method and a
bound coroutine method is still a coroutine function. This is the
universal decorator idea from **One decorator for everything**,
applied to one more distinction the wrapper can make for itself.

```{verify}
:id: both-timed
:label: One timer timed the def and the async def
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed dual-timer
reported["fetch_price_now"] >= 15 and reported["fetch_price"] >= 15 and now == 0.5 and later == 0.75
```

```{hint}
:title: When wrapped does not say
`inspect.iscoroutinefunction` answers from the function's own flags,
which can be wrong for a stack of decorators where an inner one
already runs the coroutine to completion, or returns a coroutine from
a plain `def`. wrapt has markers for that case, named on the last
page.
```

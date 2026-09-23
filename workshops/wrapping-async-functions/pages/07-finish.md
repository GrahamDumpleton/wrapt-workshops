---
title: What you know now
requires: [quiz:why-it-works]
---

# What you know now

Calling an `async def` makes a coroutine and runs nothing, so a
synchronous wrapper around it measures the making. The fix is a
wrapper of the same shape:

```python
@wrapt.decorator
async def timer(wrapped, instance, args, kwargs):
    start = time.perf_counter()
    try:
        return await wrapped(*args, **kwargs)
    finally:
        ...
```

It works because the wrapper's return value is what the caller gets,
and an `async def` wrapper returns a coroutine for the caller to
await. One decorator for both kinds tests
`inspect.iscoroutinefunction(wrapped)` and returns either the result
or an inner coroutine.

`wrapt.synchronized` on an `async def` uses an `asyncio.Lock`, shared
with `async with wrapt.synchronized(self):`, and not reentrant, so
locked entry points call a private coroutine that assumes the lock.

## What was not covered

When a stack of decorators hides what the inner function is, so
that `inspect.iscoroutinefunction` answers for the wrong layer, wrapt
has four small decorators: `mark_as_sync` and `mark_as_async` declare
the effective convention without changing it, and `async_to_sync`
and `sync_to_async` convert between the two. `wrapt.synchronized`
consults the same flags they set. They are in the "Calling Convention
Markers and Adapters" section of the bundled decorators guide, for
the day a stack needs them.

```{quiz}
:id: why-it-works
:title: Why the async wrapper works
:shuffle: true
question: "Why does an `async def` wrapper under `@wrapt.decorator` work, when `wrapt.decorator` was written for ordinary wrapper functions?"
options:
  - text: "wrapt.decorator detects an async def wrapper and switches to an asynchronous FunctionWrapper."
    explanation: "Nothing is detected and nothing switches. The same FunctionWrapper calls the wrapper and returns what it returns."
  - text: "Because the wrapper's return value is handed straight back to the caller, and an async def wrapper returns a coroutine, which the caller awaits like any other."
    correct: true
  - text: "Because wrapt awaits the wrapper itself before returning its result."
    explanation: "wrapt awaits nothing. If it did, an ordinary caller of the decorated function would never see a coroutine to await."
  - text: "Because the decorated function's __code__ flags mark it as a coroutine function, so Python awaits the wrapper automatically."
    explanation: "The flags are what inspect.iscoroutinefunction reads. They do not make anything await anything; the caller's `await` does."
explanation: "A FunctionWrapper calls your wrapper and returns whatever it returns. An async def wrapper returns a coroutine that has not started, the caller awaits it, and that runs the wrapper's body, which awaits the real function inside."
```

## Where this goes next

The last of these workshops returns to introspection. A
decorator that supplies an argument the caller no longer passes, a
session or a request id, leaves `inspect.signature` and `help()`
describing a parameter the caller must not pass. `wrapt.with_signature`
tells them the truth without touching the function.

**Changing the signature** is next.

Press Finish below to move on.

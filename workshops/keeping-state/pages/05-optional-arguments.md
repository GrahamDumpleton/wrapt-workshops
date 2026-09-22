---
title: Optional arguments
requires: [verify:track-both-ways]
---

# Optional arguments

A state class with settings, a starting count say, wants to be usable
both as `@CallTracker.track` and as `@CallTracker.track(call_count=10)`.
This is the dual-use question from **Arguments to the decorator**, and
the answer has the same shape in the class form: a function with an
optional first parameter for the function being decorated, which
returns the configured decorator when that parameter is missing and
applies it when it is not.

Here it is a static method of the class, so that the decorator and
its state class share a name.

```{cell-insert}
:id: insert-track
:path: {{ notebook }}
:tags: [track]
:run: true
class CallTracker:
    def __init__(self, *, call_count=0):
        self.call_count = call_count

    @wrapt.bind_state_to_wrapper(name="tracker")
    @wrapt.decorator
    def __call__(self, wrapped, instance, args, kwargs):
        try:
            return wrapped(*args, **kwargs)
        finally:
            self.call_count += 1

    @staticmethod
    def track(func=None, /, *, call_count=0):
        tracker = CallTracker(call_count=call_count)
        if func is None:
            return tracker
        return tracker(func)

@CallTracker.track
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

@CallTracker.track(call_count=10)
def fetch_price_from_ten(item):
    return PRICES[item]

fetch_price("apple")
fetch_price_from_ten("pear")

print("bare      :", fetch_price.tracker.call_count)
print("configured:", fetch_price_from_ten.tracker.call_count)
print("signature :", inspect.signature(fetch_price))
```

`@CallTracker.track` calls `track` with the function, so `func` is
set and the function is wrapped at once. `@CallTracker.track(call_count=10)`
calls `track` with only the keyword, so `func` is `None` and `track`
returns the configured instance, which Python then applies to the
function. The `/` makes `func` positional only and the `*` makes the
settings keyword only, so `@CallTracker.track(10)` is an error rather
than a decorator that quietly wraps the number ten.

In the function form, the missing-argument case returned
`wrapt.partial(...)`. Here it returns the tracker itself, because a
`CallTracker` instance already is a decorator: the instance is
callable, and calling it with a function runs `__call__` through
`@wrapt.decorator`, which wraps the function.

```{verify}
:id: track-both-ways
:label: Both forms of track produced a tracker with the right count
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed track
fetch_price.tracker.call_count == 1 and fetch_price_from_ten.tracker.call_count == 11
```

```{hint}
:title: Why a static method
`track` needs no instance and no class, so it could be a module level
function. Putting it on the class keeps the decorator next to its
state, and a module level alias, `track = CallTracker.track`, gives
callers the short name if they want one. wrapt's argument checkers,
which the **Validating arguments** workshop builds, use the same
arrangement.
```

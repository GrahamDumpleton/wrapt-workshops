---
title: The class form
requires: [verify:class-retry-works]
---

# The class form

A decorator with several settings and a helper or two wants to be a
class. `__init__` takes the settings and keeps them on the instance,
and `__call__` is the wrapper, with `self` in front of the usual
four arguments and `@wrapt.decorator` applied to it.

```{cell-insert}
:id: insert-class
:path: {{ notebook }}
:tags: [class-form]
:run: true
class Retry:
    def __init__(self, *, max_attempts=3, exceptions=(ConnectionError,)):
        self.max_attempts = max_attempts
        self.exceptions = exceptions

    def give_up(self, attempt):
        return attempt >= self.max_attempts

    @wrapt.decorator
    def __call__(self, wrapped, instance, args, kwargs):
        for attempt in range(1, self.max_attempts + 1):
            try:
                return wrapped(*args, **kwargs)
            except self.exceptions:
                if self.give_up(attempt):
                    raise
                print(f"attempt {attempt} failed, retrying")

attempts["count"] = 0

@Retry(max_attempts=3)
def fetch_price(item):
    """Look up the price of an item from a flaky service."""
    attempts["count"] += 1
    if attempts["count"] < 3:
        raise ConnectionError("the price service is down")
    return 0.5

price = fetch_price("apple")
print("price:", price, "after", attempts["count"], "attempts")
print("type:", type(fetch_price).__name__)
```

`@Retry(max_attempts=3)` makes an instance, and the instance is the
decorator: applying it to `fetch_price` calls it, which runs
`__call__` with the function. From then on every call of
`fetch_price` runs `__call__` as the wrapper, with `self` the same
instance, so the settings are `self.max_attempts` and
`self.exceptions` rather than closure variables, and the wrapper can
call methods of its own, as `give_up` shows.

`@wrapt.decorator` on a method is the same `@wrapt.decorator` as on a
function. It sees that `__call__` is being looked up on an instance
and supplies `self`, in the same way it supplies `instance` for a
decorated method. The decorated function is still a
`FunctionWrapper`, with its signature and docstring intact.

The standard library version of this is the class-based decorator
whose `__init__` takes the function and `__call__` takes the call,
the one that breaks on methods because an instance is not a
descriptor. Here the instance takes the settings, and the descriptor
work is done by the `FunctionWrapper` that `@wrapt.decorator`
returns, so the class form works on methods as well as it does on
functions.

```{verify}
:id: class-retry-works
:label: The class form gets the price on the third attempt and returns a FunctionWrapper
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed class-form
price == 0.5 and attempts["count"] == 3 and type(fetch_price).__name__ == "FunctionWrapper"
```

```{hint}
:title: When to choose the class form
When there is more than a setting or two, when the wrapper wants
helper methods, or when the decorator has state to keep between calls
and wants that state on an object rather than in a closure. The last
of those has a workshop of its own, **Keeping state**, later in this
collection, and it builds on the shape you just wrote.
```

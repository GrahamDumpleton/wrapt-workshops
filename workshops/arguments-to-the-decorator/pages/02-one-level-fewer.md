---
title: One level fewer
requires: [verify:closure-retry-works]
---

# One level fewer

The wrapt version keeps the outer function, because something still
has to run first and take the settings, and drops the middle one. The
outer function returns a wrapper decorated with `@wrapt.decorator`,
which is a decorator, and the wrapper reads `max_attempts` as a
closure variable exactly as before.

```{cell-insert}
:id: insert-retry
:path: {{ notebook }}
:tags: [retry]
:run: true
def retry(*, max_attempts=3):
    @wrapt.decorator
    def wrapper(wrapped, instance, args, kwargs):
        for attempt in range(1, max_attempts + 1):
            try:
                return wrapped(*args, **kwargs)
            except ConnectionError:
                if attempt == max_attempts:
                    raise
                print(f"attempt {attempt} failed, retrying")
    return wrapper

attempts["count"] = 0

@retry(max_attempts=3)
def fetch_price(item):
    """Look up the price of an item from a flaky service."""
    attempts["count"] += 1
    if attempts["count"] < 3:
        raise ConnectionError("the price service is down")
    return 0.5

price = fetch_price("apple")
print("price:", price, "after", attempts["count"], "attempts")
print("signature:", inspect.signature(fetch_price))
```

Same behaviour, two `def`s instead of three, and no
`functools.wraps`, because the wrapt wrapper never needed one.

`@retry(max_attempts=3)` calls `retry`, which builds a fresh `wrapper`
closing over that `max_attempts` and hands it to `@wrapt.decorator`,
and the decorator that comes back is applied to `fetch_price`. Two
uses of `@retry` with different settings get two wrappers, each with
its own value.

The `*` in the signature makes `max_attempts` keyword only. That is a
choice rather than a requirement, and it is the right one: a call site
cannot get the order of settings wrong, and, as the last page shows,
it removes an ambiguity that a decorator with optional settings would
otherwise have. Try the positional form and see it refused.

```{cell-insert}
:id: insert-positional
:path: {{ notebook }}
:tags: [positional]
:run: true
try:
    retry(3)
    problem = "no error"
except TypeError as error:
    problem = str(error)

print(problem)
```

```{verify}
:id: closure-retry-works
:label: The wrapt retry gets the price on the third attempt and refuses a positional setting
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed positional
price == 0.5 and attempts["count"] == 3 and "positional" in problem
```

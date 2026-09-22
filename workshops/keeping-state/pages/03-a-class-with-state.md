---
title: A class with state
requires: [verify:tracker-counts]
---

# A class with state

The closure version has a second way to keep state, in a variable of
the enclosing function, updated with `nonlocal`.

```{cell-insert}
:id: insert-nonlocal
:path: {{ notebook }}
:tags: [nonlocal]
:run: true
def count_calls(func):
    count = 0

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        nonlocal count
        count += 1
        return func(*args, **kwargs)

    return wrapper

@count_calls
def greet(name):
    return f"Hello, {name}"

greet("Ada")
greet("Grace")

try:
    print("greet.count:", greet.count)
except AttributeError as exc:
    print("AttributeError:", exc)
```

The count is safe in the closure, and nobody can read it. A decorator
whose state is worth keeping is usually worth asking about, so the
state wants to be on an object.

That object is an instance of a class, with the state set in
`__init__` and the wrapper as a `__call__` method, under
`@wrapt.decorator`, taking `self` and then the usual four arguments.
This is the class form from **Arguments to the decorator**, holding
state instead of settings.

```{cell-insert}
:id: insert-tracker
:path: {{ notebook }}
:tags: [tracker]
:run: true
class CallTracker:
    def __init__(self):
        self.call_count = 0

    @wrapt.decorator
    def __call__(self, wrapped, instance, args, kwargs):
        try:
            return wrapped(*args, **kwargs)
        finally:
            self.call_count += 1

tracker = CallTracker()

@tracker
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

fetch_price("apple")
fetch_price("pear")

print("tracker.call_count:", tracker.call_count)
print("type(fetch_price) :", type(fetch_price).__name__)

try:
    print("fetch_price.tracker:", fetch_price.tracker)
except AttributeError as exc:
    print("AttributeError:", exc)
```

Each `CallTracker()` is a decorator with a count of its own, and the
count is on the instance, where `__call__` updates it through `self`.
The decorated function is still a `FunctionWrapper` with its name and
signature intact.

The cell could read the count only because it kept the instance under
a name before applying it. Written the usual way, as
`@CallTracker()`, the instance is created and applied in one line,
and nothing outside the wrapper ever holds it. The last lines show the
gap: `fetch_price.tracker` does not exist, because a lookup on the
wrapper is forwarded to the original function, which has never heard
of the tracker.

```{verify}
:id: tracker-counts
:label: The tracker counted two calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed tracker
tracker.call_count == 2 and type(fetch_price).__name__ == "FunctionWrapper"
```

```{hint}
:title: How self and wrapped both arrive
`@wrapt.decorator` on a method is the decorator you have used since
the first workshop. Looking `__call__` up on the instance binds it, so
`self` is supplied by the descriptor protocol, and the four wrapper
arguments follow in their usual places. wrapt's examples write the
same class over `@wrapt.function_wrapper`, a lighter decorator kept
for monkey patching; either works here, and `@wrapt.decorator` is the
one that takes the `enabled` option the next workshop uses.
```

---
title: Decided once
requires: [verify:decided-once]
---

# Decided once

The standard library way to switch a decorator off is to write the
switch into the decorator: check a flag, and return the function
untouched when it is off.

```{cell-insert}
:id: insert-stdlib
:path: {{ notebook }}
:tags: [stdlib]
:run: true
import functools

LOGGING = False

def log_calls(func):
    if not LOGGING:
        return func

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print(f"calling {func.__name__}{args}")
        return func(*args, **kwargs)

    return wrapper

@log_calls
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

print("price:", fetch_price("apple"))
print("type :", type(fetch_price).__name__)
```

It works, and every decorator that wants a switch has to carry those
two lines. With wrapt the switch is an argument. Given a boolean,
`enabled` decides once, when the decorator is applied to a function:
`True` wraps as usual, and `False` returns the original function with
no wrapper around it.

```{cell-insert}
:id: insert-disabled
:path: {{ notebook }}
:tags: [disabled]
:run: true
LOGGING = False

@wrapt.decorator(enabled=LOGGING)
def log_calls(wrapped, instance, args, kwargs):
    wrapper_runs["count"] += 1
    print(f"calling {wrapped.__name__}{args}")
    return wrapped(*args, **kwargs)

@log_calls
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

price = fetch_price("apple")
disabled_type = type(fetch_price).__name__

print("price       :", price)
print("type        :", disabled_type)
print("wrapper runs:", wrapper_runs["count"])
```

`fetch_price` is a plain `function`, not a `FunctionWrapper`. The
wrapper did not run, and could not have: there is no wrapper. A
decorator disabled this way costs nothing at the call, which is the
point of doing it at definition time. Now the same decorator with the
flag on.

```{cell-insert}
:id: insert-enabled
:path: {{ notebook }}
:tags: [enabled]
:run: true
LOGGING = True

@wrapt.decorator(enabled=LOGGING)
def log_calls(wrapped, instance, args, kwargs):
    wrapper_runs["count"] += 1
    print(f"calling {wrapped.__name__}{args}")
    return wrapped(*args, **kwargs)

@log_calls
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

price = fetch_price("pear")
enabled_type = type(fetch_price).__name__

print("type        :", enabled_type)
print("wrapper runs:", wrapper_runs["count"])
```

A boolean is read when `wrapt.decorator(enabled=...)` runs, which is
when the module defining the decorator is imported, so the value of
`LOGGING` at that moment is the value for the life of the process.
Flipping the flag afterwards changes nothing, in either direction.
That is what makes it free, and what makes it a global switch rather
than a runtime one.

```{verify}
:id: decided-once
:label: Disabled left a plain function and enabled made a FunctionWrapper
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed enabled
disabled_type == "function" and enabled_type == "FunctionWrapper" and wrapper_runs["count"] == 1
```

```{hint}
:title: enabled is keyword only
`wrapt.decorator(enabled=LOGGING)` must name the argument. The first
positional parameter of `wrapt.decorator` is the wrapper function
itself, which is what `@wrapt.decorator` with no parentheses passes.
```

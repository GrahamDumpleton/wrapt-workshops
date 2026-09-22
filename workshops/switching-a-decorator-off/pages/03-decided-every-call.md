---
title: Decided every call
requires: [verify:bypassed, verify:settings-object]
---

# Decided every call

For a switch that works while the program runs, give `enabled`
something to ask rather than a value. A callable is called on every
call of the decorated function: when it returns true the wrapper runs,
and when it returns false the wrapper is bypassed and the original is
called directly.

```{cell-insert}
:id: insert-callable
:path: {{ notebook }}
:tags: [callable]
:run: true
DEBUG = True

def debugging():
    return DEBUG

@wrapt.decorator(enabled=debugging)
def log_calls(wrapped, instance, args, kwargs):
    wrapper_runs["count"] += 1
    print(f"calling {wrapped.__name__}{args}")
    return wrapped(*args, **kwargs)

@log_calls
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

wrapper_runs["count"] = 0

fetch_price("apple")
DEBUG = False
fetch_price("pear")
fetch_price("fig")
DEBUG = True
fetch_price("apple")

print("type        :", type(fetch_price).__name__)
print("wrapper runs:", wrapper_runs["count"], "of 4 calls")
```

Four calls, two lines of logging, and the counter agrees: the wrapper
ran twice. This time `fetch_price` is a `FunctionWrapper`, since the
decision is not known when it is applied, so there is a wrapper and a
call to `debugging()` on every call. That is the cost of a switch
that can be flipped at runtime, and it is small.

```{verify}
:id: bypassed
:label: The wrapper ran for two of the four calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed callable
wrapper_runs["count"] == 2 and type(fetch_price).__name__ == "FunctionWrapper"
```

## A settings object

`enabled` accepts a third kind of thing. Given an object that is
neither a boolean nor callable, wrapt takes its truth value on every
call, so a settings object with a `__bool__` method is a switch too.
Here it switches a `CallTracker`, the state class from **Keeping
state**, whose `__call__` is the wrapper: a class that keeps state
and a class that can be switched off are the same class.

```{cell-insert}
:id: insert-settings
:path: {{ notebook }}
:tags: [settings]
:run: true
class Settings:
    def __init__(self):
        self.tracing = True

    def __bool__(self):
        return self.tracing

settings = Settings()

class CallTracker:
    def __init__(self):
        self.call_count = 0

    @wrapt.bind_state_to_wrapper(name="tracker")
    @wrapt.decorator(enabled=settings)
    def __call__(self, wrapped, instance, args, kwargs):
        self.call_count += 1
        return wrapped(*args, **kwargs)

@CallTracker()
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

fetch_price("apple")
settings.tracing = False
fetch_price("pear")
settings.tracing = True
fetch_price("fig")

print("tracked:", fetch_price.tracker.call_count, "of 3 calls")
```

The middle call went straight to the original, so the tracker never
saw it. A boolean would have been read once and frozen; the settings
object is asked each time, so changing `settings.tracing` takes effect
on the next call.

```{verify}
:id: settings-object
:label: The tracker counted the two calls made while tracing was on
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed settings
fetch_price.tracker.call_count == 2
```

```{hint}
:title: Which form to use
A boolean for a decorator that is on or off for the whole process,
decided by an environment variable or a build, where the wrapper's
cost should vanish entirely. A callable or a settings object for a
switch that is flipped while the program runs, from a signal handler,
a test fixture or an admin page.
```

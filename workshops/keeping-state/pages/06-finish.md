---
title: What you know now
requires: [quiz:where-the-state-lives]
---

# What you know now

An attribute set on a wrapt decorated function lands on the original
function, because a `FunctionWrapper` forwards assignment as it
forwards lookup. A `_self_` prefix keeps an attribute on the wrapper,
which is enough for a flag, and not for state, since the wrapper
function never sees the proxy it runs inside.

State belongs on an object:

```python
class CallTracker:
    def __init__(self):
        self.call_count = 0

    @wrapt.bind_state_to_wrapper(name="tracker")
    @wrapt.decorator
    def __call__(self, wrapped, instance, args, kwargs):
        try:
            return wrapped(*args, **kwargs)
        finally:
            self.call_count += 1
```

Each `CallTracker()` is a decorator with state of its own, and
`bind_state_to_wrapper` stores the instance on the decorated function
under the name given, so `fetch_price.tracker.call_count` reads it.
For a method the tracker is on the class's wrapper and shared by every
instance, reachable through the class and through any instance. A
static `track` method with an optional positional-only first
parameter gives the decorator optional arguments.

```{quiz}
:id: where-the-state-lives
:title: Where the state lives
:shuffle: true
question: "`buy` is a method decorated with `@CallTracker()`, and two shops each call it once. Why does `corner.buy.tracker.call_count` report 2?"
options:
  - text: "bind_state_to_wrapper stores the tracker on each shop the first time buy is called on it, and copies the count across."
    explanation: "Nothing is stored on the shops. `vars(corner)` holds only the name the constructor set."
  - text: "The tracker is on the one wrapper that decorating buy created, on the class, and a bound wrapper forwards attribute lookups to that parent."
    correct: true
  - text: "CallTracker keeps a class level count that every instance of CallTracker shares."
    explanation: "Each `CallTracker()` has a count of its own, which is why `open` and `hours` report 1 each. The two shops share a count because they share the one tracker on `buy`."
  - text: "corner.buy is the same object as Shop.buy, so there is only one place the count could be."
    explanation: "They are different objects: looking `buy` up on an instance makes a bound wrapper for that access. It is the bound wrapper's attribute forwarding that reaches the shared tracker."
explanation: "Decorating `buy` ran once, when the class body ran, and made one FunctionWrapper holding one tracker. Every access through an instance makes a bound wrapper whose attribute lookups go to that parent, so every shop sees the same tracker and the same count."
```

## Where this goes next

A decorator with state is a decorator you might want to switch off,
in production, in a test, or from a setting. The next workshop does
that with the `enabled` argument to `wrapt.decorator`, which can
remove a decorator when it is applied or bypass it on each call.

**Switching a decorator off** is next.

Press Finish below to move on.

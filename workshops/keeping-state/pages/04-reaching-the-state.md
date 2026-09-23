---
title: Reaching the state
requires: [verify:state-reachable, verify:state-shared]
---

# Reaching the state

`wrapt.bind_state_to_wrapper` closes the gap. Applied above
`@wrapt.decorator` on the wrapper method, it watches for the method
being looked up on an instance of the state class, and stores that
instance on the resulting wrapper under the name you give it. The
decorated function then carries its tracker as an attribute, with no
name kept anywhere.

```{cell-insert}
:id: insert-bind-state
:path: {{ notebook }}
:tags: [bind-state]
:run: true
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

@CallTracker()
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

fetch_price("apple")
fetch_price("pear")

print("fetch_price.tracker           :", type(fetch_price.tracker).__name__)
print("fetch_price.tracker.call_count:", fetch_price.tracker.call_count)
```

`fetch_price.tracker` is the `CallTracker` instance that
`@CallTracker()` made, and its `call_count` is the count the wrapper
has been keeping. The attribute is on the `FunctionWrapper` itself,
not forwarded to the original, which is what the `_self_` prefix did
by hand on the trap page, done for you and given a name of your
choosing.

```{verify}
:id: state-reachable
:label: The tracker is reachable through the decorated function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed bind-state
type(fetch_price.tracker).__name__ == "CallTracker" and fetch_price.tracker.call_count == 2
```

## On methods

The same decorator on the methods of a class, with two instances of
the class, and the count read through the class and through each
instance.

```{cell-insert}
:id: insert-methods
:path: {{ notebook }}
:tags: [methods]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    @CallTracker()
    def buy(self, item):
        return f"{self.name} sold {item}"

    @CallTracker()
    @classmethod
    def open(cls, name):
        return cls(name)

    @CallTracker()
    @staticmethod
    def hours(day):
        return "9 to 5"

corner = Shop("Corner Store")
high_street = Shop("High Street")

corner.buy("apple")
high_street.buy("pear")
Shop.open("Market")
Shop.hours("Monday")

print("through the class    :", Shop.buy.tracker.call_count)
print("through corner       :", corner.buy.tracker.call_count)
print("through high_street  :", high_street.buy.tracker.call_count)
print("the same tracker?    :", corner.buy.tracker is Shop.buy.tracker)
print("class method         :", Shop.open.tracker.call_count)
print("static method        :", Shop.hours.tracker.call_count)
```

Every route reads the same tracker with the same count, two, even
though each shop made one call. The tracker lives on the wrapper, and
there is one wrapper, on the class, made when `@CallTracker()` was
applied to `buy`. Looking `buy` up on an instance gives a bound
wrapper for that call, and a bound wrapper forwards attribute lookups
to its parent, so `corner.buy.tracker` is `Shop.buy.tracker`.

So the count is per decoration, not per instance: it counts calls of
`buy` across every shop. State that should be per instance belongs on
the instance, and **Caching methods**, a later workshop, shows wrapt
doing exactly that for a cache.

```{verify}
:id: state-shared
:label: The count on buy is shared across instances and read through the class
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed methods
Shop.buy.tracker.call_count == 2 and corner.buy.tracker is Shop.buy.tracker and Shop.open.tracker.call_count == 1 and Shop.hours.tracker.call_count == 1
```

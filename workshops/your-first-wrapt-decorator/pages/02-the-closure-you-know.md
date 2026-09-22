---
title: The closure you know
requires: [verify:closure-works]
---

# The closure you know

Start from the decorator you would write today. `timer` takes a
function, defines `wrapper` around it, and returns `wrapper`. The
`try` and `finally` make sure the time is reported even when the call
raises, and `functools.wraps` copies the function's name and docstring
onto the wrapper and points `__wrapped__` back at the original.

```{cell-insert}
:id: insert-closure
:path: {{ notebook }}
:tags: [closure]
:run: true
def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            elapsed = time.perf_counter() - start
            print(f"{func.__name__} took {elapsed:.3f}s")
    return wrapper

@timer
def fetch_price(item, currency="USD"):
    """Look up the price of an item, slowly."""
    time.sleep(0.02)
    return PRICES[item]

by_closure = fetch_price

price = fetch_price("pear")

print("price    :", price)
print("__name__ :", fetch_price.__name__)
print("__doc__  :", fetch_price.__doc__)
print("signature:", inspect.signature(fetch_price))
```

The timer reports, the price comes back, and the three questions get
the right answers: the name is `fetch_price`, the docstring is the
original's, and the signature is `(item, currency='USD')` rather than
`(*args, **kwargs)`, because `inspect` follows the `__wrapped__` link
that `wraps` set. On Python 3.14 this is as good as the closure shape
gets, and it is good.

The cell keeps a second name, `by_closure`, pointing at this version,
so that it can be compared with the wrapt one after the next page
replaces `fetch_price`.

Two things about the shape are worth noticing before it goes. There
are two `def`s, and the inner one is the one doing the work. And the
`@functools.wraps(func)` line is a repair: it exists because a wrapper
is a different function from the one it replaces, and something has
to make it look the same.

```{verify}
:id: closure-works
:label: The closure version times the call and keeps the name
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed closure
price == 0.75 and by_closure.__name__ == "fetch_price" and str(inspect.signature(by_closure)) == "(item, currency='USD')"
```

```{hint}
:title: If you want the full story of wraps
The decorator workshops, the standard library companion to this
collection, spend a whole workshop on what a wrapper loses and what
`functools.wraps` gives back, under the title **Preserving the
wrapped function**. This page only needs its conclusion: `wraps`
copies some attributes and sets `__wrapped__`, and `inspect` follows
that link.
```

---
title: The wrapt version
requires: [verify:wrapt-works]
---

# The wrapt version

Now the same timer with wrapt. Read the signature before anything
else: `wrapped`, `instance`, `args`, `kwargs`, and the body is the
body of the inner function from the last page, with `func` renamed to
`wrapped`.

```{cell-insert}
:id: insert-wrapt
:path: {{ notebook }}
:tags: [wrapt-timer]
:run: true
@wrapt.decorator
def timer(wrapped, instance, args, kwargs):
    start = time.perf_counter()
    try:
        return wrapped(*args, **kwargs)
    finally:
        elapsed = time.perf_counter() - start
        print(f"{wrapped.__name__} took {elapsed:.3f}s")

@timer
def fetch_price(item, currency="USD"):
    """Look up the price of an item, slowly."""
    time.sleep(0.02)
    return PRICES[item]

price = fetch_price("fig")
print("price:", price)
```

Same report, same price. What changed is everything around the body:

- **One `def`, not two.** The function you write is the wrapper. There
  is no outer function taking `func`, no inner function being built,
  and no `return wrapper` at the end.

- **`@wrapt.decorator` does the turning.** Applied to your wrapper
  function, it returns a decorator. Applied to `fetch_price`, that
  decorator arranges for your function to run on every call.

- **The four arguments arrive on each call.** `wrapped` is the function
  being decorated, `instance` is what it is bound to (the next
  workshop is about that, and it is `None` here), and `args` and
  `kwargs` are the call's positional and keyword arguments, as a tuple
  and a dict.

- **No `functools.wraps`.** Nothing needs repairing, as the next page
  shows.

Note that `args` and `kwargs` are two plain parameters, not `*args,
**kwargs`. Your wrapper receives the tuple and the dict and spreads
them out itself when it calls `wrapped`. There is a reason for that
which has a workshop of its own, **Handling the arguments**; for now
it is simply the shape.

```{verify}
:id: wrapt-works
:label: The wrapt timer wraps fetch_price and returns its result
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed wrapt-timer
price == 2.0 and hasattr(fetch_price, "__wrapped__")
```

```{hint}
:title: Where the name timer went
Both pages define a `timer`, and the second replaced the first, which
is why the closure version of `fetch_price` was kept under
`by_closure` on the previous page. Each version of `fetch_price` holds
on to the `timer` that decorated it, so the earlier one keeps working.
```

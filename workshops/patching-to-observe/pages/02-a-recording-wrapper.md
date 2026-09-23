---
title: A recording wrapper
requires: [verify:recorded]
---

# A recording wrapper

A wrapper that keeps state is a class whose `__call__` has the
wrapper signature, the pattern the **Decorators with wrapt**
workshops built their state on. A `CallRecorder` instance is a
wrapper wrapt can install,
and the calls it records are on the instance, reachable from outside
any patch. Time each call, record the name and the duration whether
or not the call raised, and install one recorder on both targets.

```{cell-insert}
:id: insert-recorder
:path: {{ notebook }}
:tags: [recorder]
:run: true
class CallRecorder:
    def __init__(self):
        self.calls = []

    def __call__(self, wrapped, instance, args, kwargs):
        start = time.perf_counter()
        try:
            return wrapped(*args, **kwargs)
        finally:
            self.calls.append((wrapped.__name__, time.perf_counter() - start))

    def report(self):
        by_name = {}
        for name, elapsed in self.calls:
            count, total = by_name.get(name, (0, 0.0))
            by_name[name] = (count + 1, total + elapsed)
        for name, (count, total) in sorted(by_name.items()):
            print(f"{name:12} {count:3} calls {1000 * total / count:7.1f} ms each")

recorder = CallRecorder()

price_handle = wrapt.wrap_function_wrapper(shop.pricing, "fetch_price", recorder)
buy_handle = wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", recorder)

corner.buy("apple")
corner.buy("fig")
shop.pricing.fetch_price("pear")

recorded = len(recorder.calls)
recorder.report()
```

Five records from three calls at the top level, because each `buy`
called `fetch_price` and the patch saw both, and `buy` is a little
slower than `fetch_price`, since it includes it. Nothing in
{open}`shop/cart.py` changed, and the numbers are on `recorder`,
where a report can read them at any time.

`buy` reached `fetch_price` through the module, `pricing.fetch_price`,
which is why the inner call was seen; the workshop on cached
references is why that matters. Take the two patches out before the
next page, which installs them again its own way.

```{cell-insert}
:id: insert-recorder-out
:path: {{ notebook }}
:tags: [recorder-out]
:run: true
wrapt.unwrap_object(shop.pricing, "fetch_price", price_handle)
wrapt.unwrap_object(shop.cart, "Shop.buy", buy_handle)

print("fetch_price:", chain(shop.pricing, "fetch_price"))
print("Shop.buy   :", chain(shop.cart, "Shop.buy"))
```

```{verify}
:id: recorded
:label: The recorder saw five calls with durations and both patches are out
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed recorder-out
recorded == 5 and [name for name, elapsed in recorder.calls] == ["fetch_price", "buy", "fetch_price", "buy", "fetch_price"] and all(elapsed > 0 for name, elapsed in recorder.calls) and chain(shop.pricing, "fetch_price") == ["function"] and chain(shop.cart, "Shop.buy") == ["function"]
```

```{hint}
:title: Why fetch_price is recorded before buy
The record is made in `finally`, after the call returns, so the
inner call finishes and is recorded first. A recorder that wanted
the tree rather than the list would note the depth on the way in,
which is what a tracing tool does.
```

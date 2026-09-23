---
title: As a reusable wrapper
requires: [verify:reusable-wrapper]
---

# As a reusable wrapper

The third spelling separates the wrapper from any target.
`@wrapt.function_wrapper` turns a wrapper function into a decorator,
as `@wrapt.decorator` does, without the `enabled` and `adapter`
extras, which makes it the lighter choice for a wrapper that
patching code will apply many times. What it returns can be applied
in place, `Shop.buy = count_calls(Shop.buy)`, the way the very first
patch by assignment was made, and this time correctly, because the
result is a `FunctionWrapper` that binds like the original.

```{cell-insert}
:id: insert-reusable
:path: {{ notebook }}
:tags: [reusable]
:run: true
counts = {}

@wrapt.function_wrapper
def count_calls(wrapped, instance, args, kwargs):
    counts[wrapped.__name__] = counts.get(wrapped.__name__, 0) + 1
    return wrapped(*args, **kwargs)

Shop.buy = count_calls(Shop.buy)

counted = wrapt.wrap_object(shop.pricing, "fetch_price", count_calls)

corner.buy("apple")
shop.pricing.fetch_price("fig")

print()
print("count_calls is a:", type(count_calls).__name__)
print("Shop.buy holds a:", type(Shop.__dict__["buy"]).__name__)
print("counts          :", counts)
```

Two applications of one wrapper, two counts. The first is the in
place form, on a plain instance method, which `getattr` hands over
unchanged, so the decorator receives the function itself and the
class ends up holding a `FunctionWrapper`. The second is
`wrapt.wrap_object`, the general helper that takes any factory, calls
it with the original, and installs what comes back: the decorator is
the factory, and the patch on `fetch_price` stacks over the one
`patches.py` installed.

In place assignment is only safe on a plain function or instance
method, for the reason the first workshop found: `getattr` on a
static or class method hands back something else. For those, and for
anything reached through a path, `wrap_object` or
`wrap_function_wrapper` do the lookup properly.

```{verify}
:id: reusable-wrapper
:label: One wrapper counted calls on both targets
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed reusable
counts == {"buy": 1, "fetch_price": 1} and type(Shop.__dict__["buy"]).__name__ == "FunctionWrapper" and counted is shop.pricing.fetch_price
```

```{hint}
:title: Why fetch_price was not counted when buy ran
`Shop.buy` calls `fetch_price`, and yet the count for `fetch_price`
came from the direct call alone. {open}`shop/cart.py` imported the
function by name, `from shop.pricing import fetch_price`, and holds
its own
reference to the original, which no patch on `shop.pricing` reaches.
The workshop **Why your patch did nothing** is about exactly this.
```

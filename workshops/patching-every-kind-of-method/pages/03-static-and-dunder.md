---
title: Static and dunder methods
requires: [verify:static-and-dunder]
---

# Static and dunder methods

Two more kinds. `Shop.tax` is a static method, which binds to nothing,
and `__init__` and `__len__` are dunder methods, which Python calls
for you when a shop is made and when `len()` is asked of one. A dunder
method is an instance method with a special name, and the patch is
the same call.

```{cell-insert}
:id: insert-static-and-dunder
:path: {{ notebook }}
:tags: [static-and-dunder]
:run: true
wrapt.wrap_function_wrapper(shop.cart, "Shop.tax", notify)
wrapt.wrap_function_wrapper(shop.cart, "Shop.__init__", notify)
wrapt.wrap_function_wrapper(shop.cart, "Shop.__len__", notify)

tax = Shop.tax(10)
market = Shop("Market")
size = len(market)

tax_seen = seen[-3]
init_seen = seen[-2]
len_seen = seen[-1]

print()
print("tax      saw instance:", tax_seen[1], "with args", tax_seen[2])
print("__init__ saw instance:", type(init_seen[1]).__name__, "with args", init_seen[2])
print("__len__  saw instance:", type(len_seen[1]).__name__, "with args", len_seen[2])
```

`tax` saw `None`, as a plain function would. `__init__` saw the new
shop, before its own body had run, with `("Market",)` as the
arguments, and `__len__` saw the same shop with none. Python found
the patched `__init__` and `__len__` where it always looks for them,
on the class, so the patch is in the path of `Shop(...)` and `len()`
without anything else changing.

```{verify}
:id: static-and-dunder
:label: tax saw None and the dunder methods saw the shop being made
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed static-and-dunder
tax == 1.0 and size == 0 and tax_seen[1] is None and tax_seen[2] == (10,) and init_seen[1] is market and init_seen[2] == ("Market",) and len_seen[1] is market
```

```{hint}
:title: The instance in __init__ has no attributes yet
The wrapper runs before `__init__` does, so the shop it receives as
`instance` has no `name` and no `basket` yet. A wrapper that read
`instance.name` here would raise `AttributeError`; a wrapper on
`__init__` that wants what the constructor set reads it after
`wrapped(*args, **kwargs)` returns. That is also why the cell printed
the type of the instance rather than the instance itself.
```

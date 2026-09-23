---
title: Patching by assignment
requires: [verify:assignment-works]
---

# Patching by assignment

Start with the patch you would write today. `logged` is the closure
decorator you know, with `functools.wraps`, and instead of being
applied with `@` inside {open}`shop/pricing.py` it is applied from
here, by reading the function off the module, wrapping it, and
assigning the wrapper back over the name. The same is done to
`Shop.buy` in {open}`shop/cart.py`.

```{cell-insert}
:id: insert-assignment
:path: {{ notebook }}
:tags: [assignment]
:run: true
def logged(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print(f"calling {func.__name__}{args}")
        return func(*args, **kwargs)
    return wrapper

shop.pricing.fetch_price = logged(shop.pricing.fetch_price)
Shop.buy = logged(Shop.buy)

price = shop.pricing.fetch_price("fig")
bought = Shop("Corner Store").buy("apple")

print("price :", price)
print("bought:", bought)
```

Both calls are logged and both answers are right. `Shop.buy` is
logged with the shop as its first argument, because a plain function
in a class namespace is bound like any other: the closure took the
method's place, and Python binds it to the shop on lookup exactly as
it bound the original.

Nothing in {open}`shop/pricing.py` or {open}`shop/cart.py` changed,
as a glance at either shows. The module object and the class object
changed, in this process, for as long as it runs, and every caller
that looks the names up from now on gets the wrapper. That is a
monkey patch, and for a function and an instance method the
assignment is the whole of it.

```{verify}
:id: assignment-works
:label: Both patches by assignment are in place and work
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed assignment
price == 2.0 and bought == 0.5 and shop.pricing.fetch_price.__name__ == "fetch_price" and hasattr(Shop.buy, "__wrapped__")
```

```{hint}
:title: Why the shop was passed to the wrapper
The decorator workshops cover this under **How methods bind**, and
the **Decorators with wrapt** workshops restate it in **What instance
tells you**.
A function is a descriptor: looking it up on an instance gives a
bound method that passes the instance first. The closure is a
function, so it binds. The next page is about the two kinds of method
that are not functions.
```

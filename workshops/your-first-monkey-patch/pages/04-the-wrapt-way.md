---
title: The wrapt way
requires: [verify:wrapt-patches, verify:module-by-name]
---

# The wrapt way

Now the same three patches with wrapt. The wrapper is the four
argument function from the **Decorators with wrapt** workshops:
`wrapped`, `instance`, `args` and `kwargs`, with `wrapped` already
bound and `instance` telling you what to. `wrapt.wrap_function_wrapper`
takes the object holding the attribute, the attribute's name, and the
wrapper, and installs the patch.

```{cell-insert}
:id: insert-wrapt
:path: {{ notebook }}
:tags: [wrapt-patches]
:run: true
def notify(wrapped, instance, args, kwargs):
    print(f"calling {wrapped.__name__}{args} with instance {instance!r}")
    return wrapped(*args, **kwargs)

wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", notify)
wrapt.wrap_function_wrapper(shop.cart, "Shop.tax", notify)
wrapt.wrap_function_wrapper(shop.cart, "Shop.empty", notify)

print("in the class namespace:", type(Shop.__dict__["tax"]).__name__, "around a", type(Shop.__dict__["tax"].__wrapped__).__name__)
print()

bought = Shop("Corner Store").buy("fig")
tax_through_instance = Shop("Corner Store").tax(10)
kiosk_empty = Kiosk.empty()

print()
print("bought              :", bought)
print("tax via an instance :", tax_through_instance)
print("Kiosk.empty() made a:", type(kiosk_empty).__name__)
```

All three work, through an instance and through a subclass, and the
wrapper's `instance` tells the three apart: the shop for `buy`, `None`
for the static method, and the class for the class method, which is
`Kiosk` when the call came through `Kiosk`.

The namespace shows why. `Shop.__dict__["tax"]` is a
`FunctionWrapper` around the `staticmethod` object itself.
`wrap_function_wrapper` never called `getattr`: it looked in the class
namespace, walking the method resolution order to find where `tax`
was defined, and wrapped the raw object it found there. The
`FunctionWrapper` knows what kind of thing it holds and binds the way
that thing would, so `tax` stays static and `empty` stays a class
method bound to whichever class the call came through.

The first argument does not have to be a module object. Give the
module's name as a string and wrapt imports it if it has to. And the
call returns something, which the previous calls threw away. Keep this
one.

```{cell-insert}
:id: insert-by-name
:path: {{ notebook }}
:tags: [by-name]
:run: true
handle = wrapt.wrap_function_wrapper("shop.pricing", "fetch_price", notify)

price = shop.pricing.fetch_price("apple")

print()
print("price     :", price)
print("returned  :", type(handle).__name__)
print("signature :", inspect.signature(shop.pricing.fetch_price))
print("the same? :", handle is shop.pricing.fetch_price)
```

The returned object is the `FunctionWrapper` now sitting at
`shop.pricing.fetch_price`, the same object. It is the handle for the
patch: the identity wrapt uses to find the patch again and take it
out. Nothing on this page needs it, and a later workshop is about
nothing else. The signature is still `fetch_price`'s own, for the
reason those workshops gave: a `FunctionWrapper` forwards every
question to the original.

```{verify}
:id: wrapt-patches
:label: All three wrapt patches work and each method kept its kind
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed wrapt-patches
bought == 2.0 and tax_through_instance == 1.0 and type(kiosk_empty) is Kiosk and type(Shop.__dict__["tax"].__wrapped__) is staticmethod and type(Shop.__dict__["empty"].__wrapped__) is classmethod
```

```{verify}
:id: module-by-name
:label: The module was named as a string and the handle is the installed wrapper
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed by-name
price == 0.5 and handle is shop.pricing.fetch_price and type(handle).__name__ == "FunctionWrapper" and str(inspect.signature(shop.pricing.fetch_price)) == "(item, currency='USD')"
```

```{hint}
:title: Never insert instance yourself
The wrapper calls `wrapped(*args, **kwargs)` and not
`wrapped(instance, *args, **kwargs)`. By the time the wrapper runs,
`wrapped` is bound to the shop, or to the class for `empty`, and
passes it by itself. This is the same rule as for a decorator, and
patching makes it easier to forget, because the wrapper was written
somewhere the class is not.
```

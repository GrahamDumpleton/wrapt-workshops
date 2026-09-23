---
title: One attribute, and a hint
requires: [verify:one-attribute, verify:interface-hint]
---

# One attribute, and a hint

`lazy_import` takes an attribute name too, for the case where one
function of a module is wanted rather than the module. The proxy
then stands in for the function, and the import happens on the first
call.

```{cell-insert}
:id: insert-one-attribute
:path: {{ notebook }}
:tags: [one-attribute]
:run: true
pricing_before = "shop.pricing" in sys.modules

fetch_price = wrapt.lazy_import("shop.pricing", "fetch_price")
price = fetch_price("apple")

pricing_after = "shop.pricing" in sys.modules

print("imported before:", pricing_before)
print("price          :", price)
print("imported after :", pricing_after)
print("__name__       :", fetch_price.__name__)
```

The call worked, which is more than it sounds. `LazyObjectProxy` is
built on `AutoObjectProxy`, which adds the special methods its
target has, and here there was no target to look at when the proxy
was made: the import had not happened. The attribute form of
`lazy_import` assumes the attribute is callable, and tells the proxy
so. Without that, a lazy proxy over a callable is not callable.

```{cell-insert}
:id: insert-interface-hint
:path: {{ notebook }}
:tags: [interface-hint]
:run: true
def load_greeter():
    return lambda name: f"Hello, {name}!"

try:
    wrapt.LazyObjectProxy(load_greeter)("Alice")
    unhinted_error = None
except TypeError as exc:
    unhinted_error = f"TypeError: {exc}"

hinted = wrapt.LazyObjectProxy(load_greeter, interface=Callable)
greeting = hinted("Alice")

print("without interface:", unhinted_error)
print("with interface   :", greeting)
```

The `interface` argument is the hint: a type, usually one from
`collections.abc`, saying what kind of thing the callback will
return, so the proxy can carry the right special methods before it
has anything to read them from. `Callable` for a function,
`Iterable` or `Mapping` for a container, and `lazy_import` with no
attribute assumes a module, which needs none.

```{verify}
:id: one-attribute
:label: The attribute form imported the module on the first call
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed one-attribute
not pricing_before and pricing_after and price == 0.5
```

```{verify}
:id: interface-hint
:label: The interface hint made the lazy proxy callable
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed interface-hint
unhinted_error is not None and greeting == "Hello, Alice!"
```

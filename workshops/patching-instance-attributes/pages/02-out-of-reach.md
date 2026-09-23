---
title: Out of reach
requires: [verify:out-of-reach]
---

# Out of reach

Try the wrap functions you know on `Shop.name`, and look at where
`name` actually is.

```{cell-insert}
:id: insert-out-of-reach
:path: {{ notebook }}
:tags: [out-of-reach]
:run: true
try:
    wrapt.wrap_object(shop.cart, "Shop.name", Tagged)
    problem = "no error"
except Exception as error:
    problem = f"{type(error).__name__}: {error}"

print(problem)
print()
print("name in the shop's own dictionary:", "name" in vars(corner))
print("name in the class namespace     :", "name" in Shop.__dict__)
print("label in the class namespace    :", type(Shop.__dict__["label"]).__name__)
```

`PathResolutionError`: there is no `name` on `Shop` to resolve, and
`wrap_object` will not invent one. The attribute is in `corner`'s own
dictionary, put there by `__init__`, and every shop has its own.
`label`, by contrast, is on the class, as a `property`, because a
property is a descriptor that computes on read, and a descriptor
lives on the class.

That is the shape of the answer. A patch that wants every shop's
`name` cannot visit every shop, but it can put something on the class
that Python consults on every read of `name`, the way it consults the
property for `label`.

```{verify}
:id: out-of-reach
:label: wrap_object could not resolve name, which lives on the instance
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed out-of-reach
problem.startswith("PathResolutionError") and "name" in vars(corner) and "name" not in Shop.__dict__
```

```{hint}
:title: Why patching one shop is not the answer
`wrapt.wrap_object(corner, "name", Tagged)` would work, for that one
shop, by replacing the value in its dictionary with a proxy around
it. Every other shop, and every shop made afterwards, would be
untouched, and the next `corner.name = ...` would replace the proxy.
The class is the only place a patch can stand once for all of them.
```

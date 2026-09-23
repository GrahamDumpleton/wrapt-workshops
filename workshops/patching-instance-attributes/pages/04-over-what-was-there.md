---
title: Over what was there
requires: [verify:composes]
---

# Over what was there

The descriptor wraps whatever previously occupied the class
attribute, so it composes with three things the class may already
have. Over a property, the property keeps computing and the factory
wraps what it computes. Over a class default, the default is the
fallback when an instance has no value of its own. And a second
application stacks over the first rather than replacing it.

```{cell-insert}
:id: insert-composes
:path: {{ notebook }}
:tags: [composes]
:run: true
class Upper(wrapt.BaseObjectProxy):
    def __repr__(self):
        return f"Upper({self.__wrapped__!r})"

label_handle = wrapt.wrap_object_attribute("shop.cart", "Shop.label", Tagged)
region_handle = wrapt.wrap_object_attribute("shop.cart", "Shop.region", Tagged)
upper_handle = wrapt.wrap_object_attribute("shop.cart", "Shop.name", Upper)

print("label, over the property :", repr(corner.label))
print("region, from the default :", repr(corner.region))
print("Shop.region, on the class:", repr(Shop.region))
print("name, stacked twice      :", repr(corner.name))
print()
print("beneath label :", type(label_handle.__wrapped__).__name__)
print("beneath region:", repr(region_handle.__wrapped__))
print("beneath name  :", type(upper_handle.__wrapped__).__name__)
```

`label` is `Tagged('CORNER STORE')`: the property ran beneath the
descriptor and the factory wrapped its result. `region` is
`Tagged('local')` for the shop and for the class, the default served
as the fallback. And `name` is `Upper(Tagged('Corner Store'))`: the
outer factory wrapped the result of the inner one. Each handle's
`__wrapped__` is what the descriptor sits over, the `property`, the
string `'local'`, and the first `AttributeWrapper`, which is how it
keeps working beneath the interception and how it comes back when
the interception is removed.

```{verify}
:id: composes
:label: The descriptor composed with the property, the default and itself
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed composes
repr(corner.label) == "Tagged('CORNER STORE')" and repr(corner.region) == "Tagged('local')" and repr(corner.name) == "Upper(Tagged('Corner Store'))" and type(label_handle.__wrapped__).__name__ == "property" and region_handle.__wrapped__ == "local"
```

```{hint}
:title: Writes and deletes
The descriptor delegates writes and deletes as well: `corner.name =
"Shop 2"` stores the plain string in the shop's dictionary as before,
and the next read passes the new value through the factory. Over a
property with a setter, the setter runs.
```

---
title: A descriptor on the class
requires: [verify:descriptor-installed]
---

# A descriptor on the class

`wrapt.wrap_object_attribute(module, "Shop.name", Tagged)` installs
a descriptor on `Shop` for `name`. On every read, the descriptor
fetches the value from the instance's own dictionary and passes it
through `Tagged`, returning the proxy. The module can be named as a
string, as with the other wrap functions.

```{cell-insert}
:id: insert-descriptor
:path: {{ notebook }}
:tags: [descriptor]
:run: true
name_handle = wrapt.wrap_object_attribute("shop.cart", "Shop.name", Tagged)

market = Shop("Market")

print("corner.name       :", repr(corner.name))
print("market.name       :", repr(market.name))
print("still a str?      :", isinstance(corner.name, str), corner.name.upper())
print("in the shop's dict:", repr(vars(corner)["name"]))
print("on the class      :", type(Shop.__dict__["name"]).__name__)
print("Shop.name         :", repr(Shop.name))
print("handle            :", name_handle is Shop.__dict__["name"])
```

Both shops' names come back tagged, the one made before the patch
and the one made after, and each still works as a string. The
shops' own dictionaries are untouched: the plain string is still
there, and the proxy is made on each read, which is why a shop that
sets its name again is still covered. The class now holds an
`AttributeWrapper`, which `wrap_object_attribute` returned, and that
is the handle.

Reading `name` on the class itself, `Shop.name`, goes through the
descriptor too, with no instance to fetch from. `Shop` has no class
level `name` for it to fall back on, so what comes back is
`wrapt.MISSING`, wrapt's sentinel for no value, passed through the
factory like any other value. The next page shows the fallback when
the class does have a default.

```{verify}
:id: descriptor-installed
:label: Every shop's name now comes through the factory
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed descriptor
type(corner.name).__name__ == "Tagged" and type(market.name).__name__ == "Tagged" and isinstance(corner.name, str) and vars(corner)["name"] == "Corner Store" and type(Shop.__dict__["name"]).__name__ == "AttributeWrapper" and name_handle is Shop.__dict__["name"]
```

```{hint}
:title: A factory that returns something else
The factory need not return a proxy. `wrap_object_attribute("shop.cart",
"Shop.name", str.upper)` would make every read of `name` return the
upper case string, with the instance still holding the original. A
proxy is the choice when the value should still be the value, with
something added.
```

---
title: A name without the prefix
requires: [verify:name-without-prefix]
---

# A name without the prefix

Sometimes the proxy's own attribute cannot carry the prefix, because
the name is not yours to choose. Some other code will look up
`describe` on whatever it is given, and the proxy should answer while
the shop, which has no `describe`, stays as it is.

Plain assignment lands on the shop, as page two showed. What is
needed is a way to store an attribute on the proxy under any name,
and the proxy has one: `__self_setattr__`.

```{cell-insert}
:id: insert-name-without-prefix
:path: {{ notebook }}
:tags: [name-without-prefix]
:run: true
def summarise(obj):
    if hasattr(obj, "describe"):
        return obj.describe()
    return repr(obj)

counted.describe = lambda: "on the shop"
landed_on_shop = "describe" in vars(shop)
del counted.describe

counted.__self_setattr__("describe", lambda: f"proxy counting {counted._self_count} calls")

summary = summarise(counted)

print("plain assignment landed on shop:", landed_on_shop)
print("shop has describe now?         :", "describe" in vars(shop))
print("summarise(counted)             :", summary)
print("summarise(shop)                :", summarise(shop))
```

The plain assignment went to the shop and the `del`, forwarded too,
took it back off. `__self_setattr__` stored `describe` on the proxy
itself, so `summarise` finds it there, by the name it was always
going to look for, and the shop is untouched.

```{verify}
:id: name-without-prefix
:label: describe is on the proxy under its own name and not on the shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed name-without-prefix
landed_on_shop and "describe" not in vars(shop) and summary == "proxy counting 2 calls" and "describe" in counted.__self_dict__
```

```{hint}
:title: Why not object.__setattr__
`object.__setattr__(counted, "describe", ...)` does the same thing,
and on the Python this notebook runs it works. On Python 3.12 and
earlier it raises `TypeError: can't apply this __setattr__` when the
proxy comes from wrapt's C extension, which is what a plain install
gets, because CPython used to refuse it for any type that overrides
attribute setting at the C level. `__self_setattr__` exists so that
there is one spelling that works everywhere, and it is the one to
use while those versions are supported.
```

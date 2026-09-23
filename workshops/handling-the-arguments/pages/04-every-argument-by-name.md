---
title: Every argument by name
requires: [verify:bound-by-name]
---

# Every argument by name

The general tool is the standard library's. `inspect.signature(wrapped)`
describes the parameters, its `bind` method matches a call to them the
way Python would, and `apply_defaults` fills in whatever the call left
out. The result has an `arguments` mapping with every argument by
name.

Try it on a method, because that is where it is most useful.

```{cell-insert}
:id: insert-record
:path: {{ notebook }}
:tags: [record]
:run: true
seen = []

@wrapt.decorator
def record_arguments(wrapped, instance, args, kwargs):
    bound = inspect.signature(wrapped).bind(*args, **kwargs)
    bound.apply_defaults()
    seen.append(dict(bound.arguments))
    return wrapped(*bound.args, **bound.kwargs)

class Shop:
    def __init__(self, name):
        self.name = name

    @record_arguments
    def buy(self, item, quantity=1, *, gift_wrap=False):
        return f"{self.name}: {quantity} x {item}"

shop = Shop("Corner Store")
shop.buy("apple")
shop.buy(item="pear", quantity=2, gift_wrap=True)
Shop.buy(shop, "fig")

for arguments in seen:
    print(arguments)
```

Three dicts, each with `item`, `quantity` and `gift_wrap`, and no
`self` in any of them. That needed no special case, because `wrapped`
is the bound method by the time the wrapper runs, and a bound method's
signature has no `self`. The call through the class is no different,
since wrapt moved the shop into `instance` before the wrapper saw
anything.

`bound.arguments` is a mapping you can change, and the changes show
in `bound.args` and `bound.kwargs`, so a wrapper can normalise one
argument by name and forward the rest without knowing what they are
or which way they were passed.

```{cell-insert}
:id: insert-rounding
:path: {{ notebook }}
:tags: [rounding]
:run: true
@wrapt.decorator
def whole_quantities(wrapped, instance, args, kwargs):
    bound = inspect.signature(wrapped).bind(*args, **kwargs)
    bound.apply_defaults()
    bound.arguments["quantity"] = round(bound.arguments["quantity"])
    return wrapped(*bound.args, **bound.kwargs)

class Shop:
    def __init__(self, name):
        self.name = name

    @whole_quantities
    def buy(self, item, quantity=1, *, gift_wrap=False):
        return f"{self.name}: {quantity} x {item}"

shop = Shop("Corner Store")

rounded = [shop.buy("apple", 2.6), shop.buy(item="pear", quantity=1.2)]
print(rounded)
```

`3 x apple` and `1 x pear`, from a positional and a keyword call.

```{verify}
:id: bound-by-name
:label: Every call was bound by name without self, and quantity was rounded both ways
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed rounding
len(seen) == 3 and seen[1] == {"item": "pear", "quantity": 2, "gift_wrap": True} and "self" not in seen[0] and rounded == ["Corner Store: 3 x apple", "Corner Store: 1 x pear"]
```

```{hint}
:title: What binding costs
`inspect.signature` builds a description of the parameters on every
call, which is fine for a decorator that runs a few times a second
and noticeable in one that runs in a tight loop. A decorator that
needs it on every call can compute the signature once and keep it;
**Keeping state**, a later workshop, is about where a
decorator keeps such things.
```

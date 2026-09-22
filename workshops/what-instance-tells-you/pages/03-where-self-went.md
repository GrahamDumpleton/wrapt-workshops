---
title: Where self went
requires: [verify:self-normalised]
---

# Where self went

First, the two ways the standard library version of this goes. A
closure wrapper sees `self` as its first positional argument, and a
class-based decorator does not see it at all.

```{cell-insert}
:id: insert-stdlib
:path: {{ notebook }}
:tags: [stdlib]
:run: true
def show_args(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        wrapper.seen = args
        return func(*args, **kwargs)
    return wrapper

class CountCalls:
    def __init__(self, func):
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)

class Plain:
    @show_args
    def buy(self, item):
        return item

class Broken:
    @CountCalls
    def buy(self, item):
        return item

plain = Plain()
plain.buy("apple")
print("a closure wrapper sees :", Plain.buy.seen)

try:
    Broken().buy("apple")
    problem = "no error"
except TypeError as error:
    problem = str(error)
print("a class-based decorator:", problem)
```

The closure wrapper's `args` is `(<Plain object>, 'apple')`: the
instance is `args[0]`, but only when the decorator happens to be on a
method, so a decorator that wants it has to guess. The class-based
one raises, because a `CountCalls` instance is not a descriptor, so
looking `buy` up on an object never binds it and `self` never arrives.
The decorator workshops spend a whole workshop on this pair.

A `FunctionWrapper` is a descriptor. Looking `buy` up on the shop
binds it, the bound result knows which object it was bound to, and
that object is what the wrapper receives as `instance`. Look at the
type of `shop.buy`, and then call `buy` a second way: through the
class, with the shop passed explicitly.

```{cell-insert}
:id: insert-normalised
:path: {{ notebook }}
:tags: [normalised]
:run: true
print("shop.buy is a:", type(shop.buy).__name__)
print()

calls.clear()

shop.buy("pear")
Shop.buy(shop, "pear")

print()
print("the two calls look the same:", calls[0] == calls[1])
```

`BoundFunctionWrapper`, and then two identical lines. `Shop.buy(shop,
"pear")` passes the shop as an ordinary first argument, and the
wrapper still sees `instance=Shop('Corner Store')` and
`args=('pear',)`: wrapt recognises the call through the class and
moves the shop from `args` to `instance`, so the wrapper cannot tell
the two calls apart and never has to.

That is also why the wrapper calls `wrapped(*args, **kwargs)` and
never `wrapped(instance, *args, **kwargs)`. By the time the wrapper
runs, `wrapped` is already bound to the shop and will pass it as
`self` by itself. Passing it again would give `buy` two shops and one
argument too many.

```{verify}
:id: self-normalised
:label: The closure saw self in args; wrapt saw the same call both ways
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed normalised
Plain.buy.seen[0] is plain and "missing" in problem and len(calls) == 2 and calls[0] == calls[1] and calls[1][1] is shop and calls[1][2] == ("pear",)
```

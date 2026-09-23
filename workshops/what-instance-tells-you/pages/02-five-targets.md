---
title: Five targets
requires: [quiz:predict-method, verify:five-targets]
---

# Five targets

The same decorator, now on an instance method, a class method, a
static method and a class. Before running it, predict the first one.

```{quiz}
:id: predict-method
:title: Predict the instance method
:shuffle: true
question: "`buy` is an instance method decorated with `@show_context`. When `shop.buy(\"apple\")` runs the wrapper, what does it see?"
options:
  - text: "instance is None and args is (shop, 'apple'), the way a closure wrapper sees a method call."
    explanation: "That is what a closure wrapper sees, because by the time it runs the bound method has put self first. wrapt separates the two."
  - text: "instance is shop and args is ('apple',)."
    correct: true
  - text: "instance is shop and args is (shop, 'apple')."
    explanation: "self arrives once, in instance, and never in args as well."
  - text: "instance is the class Shop and args is ('apple',)."
    explanation: "The class arrives in instance for a class method. buy is an instance method, so instance is the object it was called on."
explanation: "For an instance method, instance is the object and args holds only what followed self in the call."
```

Now the cell. `Shop` has one method of each kind, and `Till` is a
class decorated whole.

```{cell-insert}
:id: insert-targets
:path: {{ notebook }}
:tags: [targets]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"Shop({self.name!r})"

    @show_context
    def buy(self, item):
        return f"{self.name} sold {item}"

    @show_context
    @classmethod
    def open(cls, name):
        return cls(name)

    @show_context
    @staticmethod
    def hours(day):
        return "9 to 5"

@show_context
class Till:
    def __init__(self, cash):
        self.cash = cash

calls.clear()

shop = Shop("Corner Store")
shop.buy("apple")
Shop.open("High Street")
Shop.hours("Monday")
till = Till(100)

print()
print("Till is still a class:", inspect.isclass(Till))
```

Four lines, one per call, and with the plain function from the first
page they make the whole table:

- **A plain function:** `instance` is `None`.

- **An instance method:** `instance` is the shop, `Shop('Corner
  Store')`, and `args` is `('apple',)`. There is no `self` in `args`.

- **A class method:** `instance` is the class, `Shop` itself, and
  again `args` holds only what followed `cls`.

- **A static method:** `instance` is `None`. A static method is bound
  to nothing, so the wrapper cannot tell it from a plain function, and
  does not need to.

- **A class:** `instance` is `None` too, and `args` is what the
  constructor was called with. The wrapper runs when the class is
  called, which is to say when an instance is made.

Three cases give `None`, and only one of them needs telling apart:
inside the wrapper, `inspect.isclass(wrapped)` is true for the class
and false for the other two. The last line of the cell shows that
`Till` itself still passes that test through the wrapper, which is the
proxy from the first workshop forwarding `__class__`.

```{verify}
:id: five-targets
:label: The four calls recorded the shop, the class, None and None
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed targets
len(calls) == 4 and calls[0][1] is shop and calls[0][2] == ("apple",) and calls[1][1] is Shop and calls[2][1] is None and calls[3][1] is None
```

```{hint}
:title: One decorator for all of them
A wrapper that branches on these values, `instance is None`,
`inspect.isclass(instance)` and `inspect.isclass(wrapped)`, can behave
correctly on every kind of target at once. wrapt's documentation calls
that a universal decorator, and **One decorator for everything**, a
later workshop, builds one.
```

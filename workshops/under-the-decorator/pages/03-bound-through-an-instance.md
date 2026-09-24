---
title: Bound through an instance
requires: [quiz:predict-binding, verify:bound-through-instance]
---

# Bound through an instance

A function in a class body becomes a method because a function is a
descriptor: read through an instance, its `__get__` returns a bound
method. A wrapper that replaces the function has to do the same, or
`self` never arrives. The by-hand version is a class with `__get__`
returning a `types.MethodType`.

```{cell-insert}
:id: insert-by-hand-descriptor
:path: {{ notebook }}
:tags: [by-hand-descriptor]
:run: true
class Descriptor:
    def __init__(self, function):
        self.function = function

    def __get__(self, instance, owner=None):
        if instance is None:
            return self.function
        return types.MethodType(self.function, instance)

class Shop:
    def __init__(self, name):
        self.name = name

    def buy(self, item):
        return fetch_price(item)

    @staticmethod
    def tax(amount):
        return amount * 0.1

    buy = Descriptor(buy)
    tax = Descriptor(tax)

shop = Shop("corner")

print("buy:", shop.buy("apple"))
try:
    print("tax:", shop.tax(10))
    tax_error = None
except TypeError as exc:
    tax_error = f"TypeError: {exc}"
    print("tax:", tax_error)
```

It binds the instance method, and it binds the static method too,
which is wrong: `tax` now receives the shop as its first argument
and raises. A descriptor written for functions treats everything as
a function, and a class method would go wrong in its own way.

`FunctionWrapper` is a descriptor that looks at what it wrapped.
Predict what it reports for each kind before the cell runs.

```{quiz}
:id: predict-binding
:title: Predict the binding
:shuffle: true
question: "Three `FunctionWrapper`s in a class body, over a plain method, a `@classmethod` and a `@staticmethod`. What are their `_self_binding` values?"
options:
  - text: "`function`, `classmethod` and `staticmethod`."
    correct: true
  - text: "`function` for all three, since each wraps a function underneath."
    explanation: "The class method and static method arrive as `classmethod` and `staticmethod` objects, and the wrapper records which, because binding them correctly depends on it."
  - text: "`instancemethod`, `classmethod` and `staticmethod`."
    explanation: "A plain function in a class body is recorded as `function`. `instancemethod` is used for a bound method wrapped after the fact."
explanation: "`_self_binding` records the kind of thing wrapped, and the descriptor uses it to bind the way that kind binds: the instance for a function, the class for a class method, nothing for a static method."
```

```{cell-insert}
:id: insert-bound-through-instance
:path: {{ notebook }}
:tags: [bound-through-instance]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    def buy(self, item):
        return fetch_price(item)

    @classmethod
    def empty(cls):
        return cls("empty")

    @staticmethod
    def tax(amount):
        return amount * 0.1

    buy = wrapt.FunctionWrapper(buy, wrapper)
    empty = wrapt.FunctionWrapper(empty, wrapper)
    tax = wrapt.FunctionWrapper(tax, wrapper)

shop = Shop("corner")
bound = shop.buy

print("type           :", type(bound).__name__)
print("_self_binding  :", bound._self_binding)
print("_self_instance :", bound._self_instance is shop)
print("_self_parent   :", bound._self_parent is Shop.__dict__["buy"])

bindings = {name: getattr(shop, name)._self_binding for name in ("buy", "empty", "tax")}
print("bindings       :", bindings)

del calls[:]
shop.buy("apple")
Shop.empty()
shop.tax(10)

instances = [instance for instance, args in calls]
print("instances seen :", instances)
```

Read through the instance, `shop.buy` is not the `FunctionWrapper`
in the class. It is a `BoundFunctionWrapper`, made by the
`FunctionWrapper`'s `__get__`, holding the shop as `_self_instance`
and that `FunctionWrapper` as `_self_parent`, which is what the
identity check against `Shop.__dict__["buy"]` confirms. The three
bindings are what you predicted, and the wrapper was told the
shop for the instance method, the class for the class method and
`None` for the static method, with the static method's arguments
left alone. That table is the one **Decorators with wrapt** teaches
as the rules for `instance`; this is where the rules come from.

```{verify}
:id: bound-through-instance
:label: The bound wrapper knows its instance, its parent and each binding
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed bound-through-instance
type(bound).__name__ == "BoundFunctionWrapper" and bound._self_instance is shop and bindings == {"buy": "function", "empty": "classmethod", "tax": "staticmethod"} and instances[0] is shop and instances[1] is Shop and instances[2] is None
```

---
title: Checking types
requires: [verify:types-checked, verify:methods-checked]
---

# Checking types

`TypeChecker` keeps one thing, the signature of the function it
decorates, and computes it on the first call rather than when the
decorator is applied. The reason is on the next cell but one. On each
call it binds the arguments, applies the defaults, and compares every
argument that has an annotation against it.

The static `check` method makes a fresh instance for each decoration
and applies it, and `type_checker` is the short name.

```{cell-insert}
:id: insert-type-checker
:path: {{ notebook }}
:tags: [type-checker]
:run: true
class TypeChecker:
    def __init__(self):
        self.signature = None

    @wrapt.decorator
    def __call__(self, wrapped, instance, args, kwargs):
        if self.signature is None:
            self.signature = inspect.signature(wrapped)
        bound = self.signature.bind(*args, **kwargs)
        bound.apply_defaults()
        for name, value in bound.arguments.items():
            annotation = self.signature.parameters[name].annotation
            if annotation is inspect.Parameter.empty:
                continue
            if not isinstance(value, annotation):
                raise TypeError(
                    f"Argument {name!r} must be {annotation.__name__}, "
                    f"got {type(value).__name__}"
                )
        return wrapped(*args, **kwargs)

    @staticmethod
    def check(func):
        return TypeChecker()(func)

type_checker = TypeChecker.check

@type_checker
def price_of(item: str, quantity: int = 1) -> float:
    """The price of some quantity of an item."""
    return PRICES[item] * quantity

print("price:", price_of("apple", 2))

try:
    price_of("apple", "2")
except TypeError as exc:
    type_problem = str(exc)
    print("TypeError:", type_problem)
```

The good call goes through. The bad one is stopped before `price_of`
runs, with an error that names the argument, the type it should have
been and the type it was, rather than whatever `PRICES[item] * "2"`
would have said.

`bound.apply_defaults()` means a parameter the caller left out is
checked too, against its default, so an annotation that disagrees
with its own default is caught on the first call. Parameters without
an annotation are skipped, so the checker can go on a function that
annotates only what matters.

```{verify}
:id: types-checked
:label: A string quantity was refused by name
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed type-checker
type_problem == "Argument 'quantity' must be int, got str"
```

## On methods

Now the same `type_checker`, unchanged, on an instance method, a
class method and a static method.

```{cell-insert}
:id: insert-type-methods
:path: {{ notebook }}
:tags: [type-methods]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    @type_checker
    def buy(self, item: str, quantity: int = 1):
        return f"{self.name}: {quantity} x {item}"

    @type_checker
    @classmethod
    def open(cls, name: str):
        return cls(name)

    @type_checker
    @staticmethod
    def hours(day: str):
        return "9 to 5"

shop = Shop("Corner Store")

print(shop.buy("apple", 3))
print(Shop.open("High Street").name)
print(Shop.hours("Monday"))
print("the signature the checker saw:", inspect.signature(shop.buy))

method_problems = []

for call in (lambda: shop.buy(3), lambda: Shop.open(3), lambda: Shop.hours(3)):
    try:
        call()
    except TypeError as exc:
        method_problems.append(str(exc))
        print("TypeError:", exc)
```

No special case for `self` or `cls`, and none needed. By the time
the wrapper runs, `wrapped` is already bound: it is `shop.buy`, whose
signature is `(item, quantity=1)`, with `self` gone the way it goes
from any bound method. Binding `args` to that signature works because
`args` never holds `self` either. That is why the signature is taken
from `wrapped` on the first call and not from the raw function when
the decorator is applied, when it would still have `self` in it and
the binding would be off by one.

The same decorator done as a closure would have to know whether it
was on a method, skip the first parameter if so, and get that wrong
for a static method. Here the descriptor work has been done before
the wrapper is called, and the checker sees the function as its
caller does.

```{verify}
:id: methods-checked
:label: All three kinds of method were checked by the same code
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed type-methods
method_problems == ["Argument 'item' must be str, got int", "Argument 'name' must be str, got int", "Argument 'day' must be str, got int"]
```

```{hint}
:title: The signature is cached once per decoration
Each `@type_checker` made its own `TypeChecker`, so each decorated
function has a signature slot of its own, filled on its first call.
For a method the binding happens on every access but the signature is
the same every time, so caching it from the first call is safe. It is
the state class from **Keeping state** with a signature in place of a
count, and no `bind_state_to_wrapper`, because nobody outside needs
to reach it.
```

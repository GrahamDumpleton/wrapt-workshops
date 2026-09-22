---
title: Checking values
requires: [verify:values-checked]
---

# Checking values

`ValueChecker` has the same shape and takes its rules from the
decoration site instead of from annotations: a constraint callable
per parameter name, passed as keyword arguments. Because the rules
are arguments, `validate` uses the optional arguments pattern from
**Keeping state**, with the function positional only and the
constraints keyword only.

```{cell-insert}
:id: insert-value-checker
:path: {{ notebook }}
:tags: [value-checker]
:run: true
class ValueChecker:
    def __init__(self, constraints):
        self.constraints = constraints
        self.signature = None

    @wrapt.decorator
    def __call__(self, wrapped, instance, args, kwargs):
        if self.signature is None:
            self.signature = inspect.signature(wrapped)
        bound = self.signature.bind(*args, **kwargs)
        bound.apply_defaults()
        for name, constraint in self.constraints.items():
            if name not in bound.arguments:
                continue
            value = bound.arguments[name]
            if not constraint(value):
                raise ValueError(
                    f"Argument {name!r} with value {value!r} failed "
                    f"constraint {getattr(constraint, '__name__', constraint)!s}"
                )
        return wrapped(*args, **kwargs)

    @staticmethod
    def validate(func=None, /, **constraints):
        checker = ValueChecker(constraints=constraints)
        if func is None:
            return checker
        return checker(func)

value_checker = ValueChecker.validate

def is_positive(value):
    return value > 0

def is_stocked(item):
    return item in PRICES

@value_checker(item=is_stocked, quantity=is_positive)
def price_of(item: str, quantity: int = 1) -> float:
    """The price of some quantity of an item."""
    return PRICES[item] * quantity

class Shop:
    def __init__(self, name):
        self.name = name

    @value_checker(quantity=is_positive)
    def buy(self, item: str, quantity: int = 1):
        return f"{self.name}: {quantity} x {item}"

shop = Shop("Corner Store")

print("price:", price_of("pear", 2))
print(shop.buy("fig", 4))

value_problems = []

for call in (lambda: price_of("kiwi"), lambda: price_of("apple", 0), lambda: shop.buy("apple", quantity=-1)):
    try:
        call()
    except ValueError as exc:
        value_problems.append(str(exc))
        print("ValueError:", exc)
```

Each error names the parameter, the value and the constraint that
refused it, whether the argument was passed positionally, by keyword
or not at all: binding turns all three into a name, and applying the
defaults is what lets `price_of("apple", 0)` and a default of `1`
both be checked by the same line. A constraint for a parameter the
function does not have is skipped, which is forgiving; a stricter
checker would refuse it in `__init__`.

The method needed nothing extra, for the same reason as before: the
signature comes from the bound `wrapped`, so `self` is not in it.

```{verify}
:id: values-checked
:label: Three bad values were refused, by name, with the constraint named
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed value-checker
value_problems == ["Argument 'item' with value 'kiwi' failed constraint is_stocked", "Argument 'quantity' with value 0 failed constraint is_positive", "Argument 'quantity' with value -1 failed constraint is_positive"]
```

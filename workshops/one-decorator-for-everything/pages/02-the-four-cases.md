---
title: The four cases
requires: [quiz:predict-static, verify:four-cases]
---

# The four cases

The rules, from **What instance tells you**:

- `instance` is `None` and `inspect.isclass(wrapped)`: a class.

- `instance` is `None` otherwise: a function, or a static method,
  which is a function.

- `inspect.isclass(instance)`: a class method, with `instance` the
  class.

- otherwise: an instance method, with `instance` the object.

Before writing them down, one prediction.

```{quiz}
:id: predict-static
:title: Predict the static method
:shuffle: true
question: "A universal decorator is applied above `@staticmethod`. Which branch does a call take?"
options:
  - text: "The class method branch, because a static method is looked up on the class."
    explanation: "Looking it up on the class does not bind it to the class. `staticmethod` binds to nothing, so instance is None."
  - text: "The function branch, because a static method is bound to nothing and instance is None."
    correct: true
  - text: "A fifth branch: instance is None and wrapped is a staticmethod object."
    explanation: "By the time the wrapper runs, wrapped is the plain function the staticmethod held, and there is nothing left to tell it apart."
  - text: "The instance method branch when called on an instance, and the function branch when called on the class."
    explanation: "A static method receives no instance either way. The wrapper sees the same call from both routes."
explanation: "A static method is a function that happens to live in a class. The wrapper cannot tell them apart and does not need to: whatever is right for a function is right for a static method."
```

Now the decorator. `audit` records a description of every call that
depends on what was decorated: the object for a method, the class for
a class method, the class being made for a class, and the bare name
for a function.

```{cell-insert}
:id: insert-audit
:path: {{ notebook }}
:tags: [audit]
:run: true
@wrapt.decorator
def audit(wrapped, instance, args, kwargs):
    if instance is None:
        if inspect.isclass(wrapped):
            what = f"new {wrapped.__name__}"
        else:
            what = f"{wrapped.__name__}()"
    else:
        if inspect.isclass(instance):
            what = f"{instance.__name__}.{wrapped.__name__}()"
        else:
            what = f"{instance!r}.{wrapped.__name__}()"
    log.append(what)
    return wrapped(*args, **kwargs)

@audit
def greet(name):
    return f"Hello, {name}"

class Shop:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"Shop({self.name!r})"

    @audit
    def buy(self, item):
        return f"{self.name} sold {item}"

    @audit
    @classmethod
    def open(cls, name):
        return cls(name)

    @audit
    @staticmethod
    def hours(day):
        return "9 to 5"

@audit
class Till:
    def __init__(self, cash):
        self.cash = cash

log.clear()

greet("Ada")
shop = Shop("Corner Store")
shop.buy("apple")
Shop.open("High Street")
Shop.hours("Monday")
Till(100)

for entry in log:
    print(entry)
```

Five calls, five descriptions, one decorator with nothing in it but
the two tests. The static method reads as `hours()`, indistinguishable
from the function, as predicted.

The standard library version of `audit` would need a `__get__` to
find out about `self` and `cls`, and even then would not see a class
being called as anything but a function call, because a class is not
a descriptor. wrapt does the descriptor work once, in
`FunctionWrapper`, and hands the results to every wrapper as
`instance`.

```{verify}
:id: four-cases
:label: The log describes all five calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed audit
log == ["greet()", "Shop('Corner Store').buy()", "Shop.open()", "hours()", "new Till"]
```

```{hint}
:title: If the log is different
The ordering rule from **What instance tells you** applies. If the
class method reads as `open()` rather than `Shop.open()`, `@audit` is
under `@classmethod` instead of above it, and the wrapper saw a
plain function call with the class in `args[0]`.
```

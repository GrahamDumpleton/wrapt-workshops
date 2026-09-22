---
title: Refusing the rest
requires: [verify:refused]
---

# Refusing the rest

Most decorators are not universal, and do not need to be. wrapt's
documentation asks one thing of a decorator that supports some of the
five cases and not others: that it raises at the call when it is used
where it does not belong, rather than doing something half right.

`on_instance` here only makes sense on an instance method, because it
records the object's name. Applied to anything without an instance, it
says so.

```{cell-insert}
:id: insert-refuse
:path: {{ notebook }}
:tags: [refuse]
:run: true
@wrapt.decorator
def on_instance(wrapped, instance, args, kwargs):
    if instance is None or inspect.isclass(instance):
        raise TypeError(f"{wrapped.__name__} is not an instance method")
    log.append(f"{instance.name}: {wrapped.__name__}")
    return wrapped(*args, **kwargs)

class Shop:
    def __init__(self, name):
        self.name = name

    @on_instance
    def buy(self, item):
        return f"{self.name} sold {item}"

    @on_instance
    @classmethod
    def open(cls, name):
        return cls(name)

@on_instance
def greet(name):
    return f"Hello, {name}"

log.clear()
refused = []

print(Shop("Corner Store").buy("apple"))

for call in (lambda: Shop.open("High Street"), lambda: greet("Ada")):
    try:
        call()
    except TypeError as exc:
        refused.append(str(exc))
        print("TypeError:", exc)
```

The method works. The class method and the function each raise a
`TypeError` naming the function, at the call, which is the earliest
moment the wrapper exists to raise it. Decoration itself succeeds, as
it must: the wrapper does not run until a call, and the values it
would test do not exist before one.

Compare the alternative. Without the check, `open` would have failed
with `AttributeError: type object 'Shop' has no attribute 'name'`,
and `greet` with an `AttributeError` on `None`, both from inside the
wrapper's own code and neither saying what was actually wrong.

```{verify}
:id: refused
:label: The method was audited and the other two were refused
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed refuse
log == ["Corner Store: buy"] and refused == ["open is not an instance method", "greet is not an instance method"]
```

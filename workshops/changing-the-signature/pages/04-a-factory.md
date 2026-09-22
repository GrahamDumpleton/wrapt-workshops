---
title: A factory
requires: [verify:factory-derived]
---

# A factory

`wrapt.with_signature(factory=...)` takes a function that is called
at decoration time with the function being wrapped and returns the
signature to present. A decorator that always removes `session` can
then derive the new signature from the old, and wrap the two steps,
describing and injecting, into one decorator that callers apply.

`with_session` here is that decorator. It is a plain function: it
applies `with_signature` to the function, then `inject_session` to
the result, and returns that.

```{cell-insert}
:id: insert-factory
:path: {{ notebook }}
:tags: [factory]
:run: true
def without_session(wrapped):
    signature = inspect.signature(wrapped)
    parameters = [p for p in signature.parameters.values() if p.name != "session"]
    return signature.replace(parameters=parameters)

def with_session(wrapped):
    return inject_session(wrapt.with_signature(factory=without_session)(wrapped))

@with_session
def fetch_price(session, item, currency="USD"):
    """Look up the price of an item in a session."""
    return f"{session.lookup(item)} {currency}"

class Shop:
    def __init__(self, name):
        self.name = name

    @with_session
    def buy(self, session, item):
        return f"{self.name} sold {item} at {session.lookup(item)}"

shop = Shop("Corner Store")

print("function      :", fetch_price("fig"), inspect.signature(fetch_price))
print("method        :", shop.buy("apple"))
print("on the class  :", inspect.signature(Shop.buy))
print("on an instance:", inspect.signature(shop.buy))

function_signature = str(inspect.signature(fetch_price))
class_signature = str(inspect.signature(Shop.buy))
bound_signature = str(inspect.signature(shop.buy))
```

The function reports `(item, currency='USD')`, with the default kept
and `session` gone. The method reports `(self, item)` on the class
and `(item)` on an instance, because `with_signature` strips the
first parameter from the bound view as Python does for any method.

One detail decided how `without_session` was written. The factory
runs when the decorator is applied, which for a method is inside the
class body, on the raw function with `self` still first. A factory
that dropped the first parameter would drop `self` from the method
and `session` from the function, and be wrong on one of them. Dropping
by name is right on both.

```{verify}
:id: factory-derived
:label: The derived signature is right on the function, the class and the instance
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed factory
function_signature == "(item, currency='USD')" and class_signature == "(self, item)" and bound_signature == "(item)"
```

```{hint}
:title: The older mechanism
`wrapt.decorator` also takes an `adapter` argument that does the
same job, with a prototype function or an `adapter_factory`, and it
is still there. It is planned for deprecation in favour of
`with_signature`, which is a decorator of its own and composes with
`wrapt.decorator` rather than being an option to it, so new code
uses `with_signature`.
```

---
title: A factory
requires: [verify:factory-derived]
---

# A factory

`wrapt.with_signature(factory=...)` takes a function that is called
at decoration time with the function being wrapped and returns the
signature to present, or a tuple of the signature and the docstring,
so that one factory derives both in a single pass. A decorator that
always removes `session` can then derive the new signature from the
old, say so in the docstring, and wrap the two steps, describing and
injecting, into one decorator that callers apply.

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
    doc = f"{wrapped.__doc__}\n\nThe session is supplied by the decorator; do not pass one."
    return signature.replace(parameters=parameters), doc

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
        """Sell an item from the shop in a session."""
        return f"{self.name} sold {item} at {session.lookup(item)}"

shop = Shop("Corner Store")

print("function      :", fetch_price("fig"), inspect.signature(fetch_price))
print("method        :", shop.buy("apple"))
print("on the class  :", inspect.signature(Shop.buy))
print("on an instance:", inspect.signature(shop.buy))
print()
help(shop.buy)

function_signature = str(inspect.signature(fetch_price))
class_signature = str(inspect.signature(Shop.buy))
bound_signature = str(inspect.signature(shop.buy))
function_doc = fetch_price.__doc__
class_doc = Shop.buy.__doc__
bound_doc = shop.buy.__doc__
```

The function reports `(item, currency='USD')`, with the default kept
and `session` gone. The method reports `(self, item)` on the class
and `(item)` on an instance, because `with_signature` strips the
first parameter from the bound view as Python does for any method.
The docstring is the original's with the note appended, on the
function and on both views of the method, and the help for the bound
method reads as a whole: the signature the caller uses, and a
docstring that explains where the session comes from.

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
function_signature == "(item, currency='USD')" and class_signature == "(self, item)" and bound_signature == "(item)" and function_doc.endswith("do not pass one.") and class_doc == bound_doc and bound_doc.startswith("Sell an item from the shop in a session.")
```

```{hint}
:title: When doc= is given as well
A factory that returns a tuple can still be paired with `doc=`, and
then the docstring from the tuple is ignored: an explicit `doc=`
always wins. A factory that returns only a signature leaves the
docstring delegating to the wrapped function, as on the first cell
of the previous page.
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

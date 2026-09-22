---
title: What you know now
requires: [quiz:where-to-drop]
---

# What you know now

A decorator that supplies an argument changes the signature callers
see, and everything that introspects the decorated function is then
wrong about it. `wrapt.with_signature` overrides what introspection
reports without touching the function:

- `prototype=` takes a function whose signature is the truth,

- `signature=` takes an `inspect.Signature`,

- `factory=` takes a function called at decoration time with the
  function being wrapped, returning the signature to present, which
  is what a decorator that always removes one parameter wants.

On a method the bound view strips `self` as Python's does, and the
factory sees the raw function with `self` in it, so drop parameters
by name. Stacked under another wrapt decorator, the override still
comes through.

```{quiz}
:id: where-to-drop
:title: Dropping by name
:shuffle: true
question: "A with_signature factory is written as `lambda wrapped: sig.replace(parameters=list(sig.parameters.values())[1:])`, dropping the first parameter. Applied through a decorator to the method `buy(self, session, item)`, what does `inspect.signature(shop.buy)` report, and why?"
options:
  - text: "(item), because the factory dropped session and binding dropped self."
    explanation: "The factory ran on the raw function, where the first parameter is self, not session."
  - text: "(session, item), because the factory dropped self from the raw function and then the bound view had nothing left to strip."
    explanation: "Close, but the bound view still strips the first parameter of whatever the override says. After the factory, that is session."
  - text: "(item), because the factory dropped self and the bound view then dropped session, so the answer happens to be right."
    correct: true
  - text: "A TypeError at decoration time, because with_signature refuses a signature without self on a method."
    explanation: "with_signature does not know it is on a method when it runs. It presents whatever the factory returns."
explanation: "The factory sees `(self, session, item)` and drops self, leaving `(session, item)`. The bound view then strips its first parameter, session, and reports `(item)`. The result is right by accident, and the class view, `inspect.signature(Shop.buy)`, is wrong: it says `(session, item)`. Dropping by name gives `(self, item)` and `(item)`, both right."
```

## Where this goes next

This is the last workshop in **Decorators with wrapt**. Press Finish
below to close it. The Finish dialog says where the wrapt
documentation goes on from here, and which collection comes next in
this repository.

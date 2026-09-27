---
title: What you know now
requires: [quiz:where-to-drop, quiz:doc-write-through]
---

# What you know now

A decorator that supplies an argument changes the signature callers
see, and everything that introspects the decorated function is then
wrong about it, the help text included. `wrapt.with_signature`
overrides what introspection reports without touching the function:

- `prototype=` takes a function whose signature is the truth,

- `signature=` takes an `inspect.Signature`,

- `factory=` takes a function called at decoration time with the
  function being wrapped, returning the signature to present, or a
  tuple of the signature and the docstring, which is what a decorator
  that always removes one parameter wants,

- `doc=` replaces the docstring alongside any of the three, and wins
  over the docstring from a tuple.

`wrapt.with_doc` replaces only the docstring, from `doc=` or a
`factory=`, and above `with_signature` its factory sees the presented
signature. Assigning to `__doc__` on a wrapper with no override writes
through to the wrapped function; on one with an override it replaces
the override, and `del` restores delegation.

On a method the bound view strips `self` as Python's does and reports
the same docstring as the class, and the factory sees the raw function
with `self` in it, so drop parameters by name. Stacked under another
wrapt decorator, both overrides still come through.

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

```{quiz}
:id: doc-write-through
:title: Assigning to __doc__
:shuffle: true
question: "`fetch_price` is decorated with `inject_session` alone, with no signature or docstring override. You assign a new string to `fetch_price.__doc__`. What does `wrapt.unwrapped(fetch_price).__doc__` report afterwards?"
options:
  - text: "The original docstring, because the wrapper stored the new one on itself."
    explanation: "There is nowhere on a plain wrapper for it to go. `__doc__` on every wrapt wrapper delegates to the wrapped function, for reading and for writing."
  - text: "The new string, because `__doc__` on a wrapt wrapper delegates to the wrapped function and the assignment wrote through to it."
    correct: true
  - text: "An AttributeError, because `__doc__` on a wrapper is read only."
    explanation: "It is read only on the bound view of a method, as for any bound method, not on a function wrapper."
  - text: "The original docstring, while `fetch_price.__doc__` reports the new string, so the two now differ."
    explanation: "They cannot differ without an override. Reading goes through the same delegation the write did, so both report the new string."
explanation: "A wrapper without an override delegates `__doc__` to the wrapped function, so the assignment changes the original's docstring everywhere, including for anyone who reaches it through `__wrapped__`. That is why the override from `doc=` or `with_doc` is held on the wrapper instead, where assignment replaces it and `del` removes it without touching the wrapped function."
```

## Where this goes next

This is the last workshop in **Decorators with wrapt**. Press Finish
below to close it. The Finish dialog says where the wrapt
documentation goes on from here, and which workshops come next in
this repository.

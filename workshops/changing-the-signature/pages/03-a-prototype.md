---
title: A prototype
requires: [verify:prototype-seen]
---

# A prototype

`wrapt.with_signature(prototype=...)` takes a function whose
signature is the truth. The prototype's body never runs; only its
parameters, defaults and annotations are read, and they become what
`inspect.signature()`, `help()` and everything that reads `__code__`
report. The wrapped function itself is not touched.

Applied here under `inject_session`, so that the outer decorator does
the injecting and the inner one describes the result.

```{cell-insert}
:id: insert-prototype
:path: {{ notebook }}
:tags: [prototype]
:run: true
def _fetch_price_prototype(item): ...

@inject_session
@wrapt.with_signature(prototype=_fetch_price_prototype)
def fetch_price(session, item):
    """Look up the price of an item in a session."""
    return session.lookup(item)

print("price       :", fetch_price("pear"))
print("signature   :", inspect.signature(fetch_price))
print("docstring   :", fetch_price.__doc__)
print("the original:", inspect.signature(wrapt.unwrapped(fetch_price)))
print("the chain   :", [type(layer).__name__ for layer in wrapt.wrapper_chain(fetch_price)])

reported = str(inspect.signature(fetch_price))
```

`(item)`, through both layers. `with_signature` is a wrapt decorator,
so the signature it presents comes through any wrapt decorator
stacked above it, and the docstring is still the original's, since
only the signature was overridden. The original function, at the
bottom of the chain, still says `(session, item)`, which is the
truth about it; the override is on the wrapper, which is the truth
about what callers see.

The prototype form is the one to use when the new signature is known
where the decorator is applied. For a decorator that always removes
the same parameter from whatever it decorates, writing a prototype
per function is the wrong amount of work, and the next page derives
it instead.

```{verify}
:id: prototype-seen
:label: The prototype's signature comes through the outer decorator
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed prototype
reported == "(item)" and fetch_price.__doc__ == "Look up the price of an item in a session."
```

```{hint}
:title: A Signature object instead
`wrapt.with_signature(signature=...)` takes an `inspect.Signature`
built by hand, for when the parameters come from data rather than
from a function you can write down. Exactly one of `prototype=`,
`signature=` and `factory=` must be given.
```

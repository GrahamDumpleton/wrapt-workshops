---
title: Only the docstring
requires: [verify:with-doc-seen, verify:described]
---

# Only the docstring

Sometimes the signature is right and only the description is wrong.
A function whose docstring is implementation notes, or is missing,
needs a docstring for `help()` without the signature changing, and
`wrapt.with_doc` does exactly that. It takes `doc=` or `factory=`,
exactly one of them, and is used in the same way as `with_signature`.

```{cell-insert}
:id: insert-with-doc
:path: {{ notebook }}
:tags: [with-doc]
:run: true
@wrapt.with_doc(doc="Look up the price of an item in a session.")
def lookup_price(session, item):
    """Implementation notes: PRICES is a module level dict, no caching."""
    return session.lookup(item)

help(lookup_price)
print("the original:", lookup_price.__wrapped__.__doc__)

with_doc_signature = str(inspect.signature(lookup_price))
with_doc_doc = lookup_price.__doc__
```

The signature is still `(session, item)`, the help shows the supplied
docstring, and the original keeps its notes. As with `with_signature`,
the override is on the wrapper and the function is not touched.

```{verify}
:id: with-doc-seen
:label: The docstring is overridden and the signature is unchanged
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed with-doc
with_doc_signature == "(session, item)" and with_doc_doc == "Look up the price of an item in a session."
```

## A factory that sees the signature

`with_doc(factory=...)` is called at decoration time with whatever
the decorator was applied to, which is the wrapper below it when
decorators are stacked. Placed above `with_signature`, the factory
sees the overridden signature and can put it in the docstring, so
`help()` opens with the line a caller needs.

```{cell-insert}
:id: insert-describe
:path: {{ notebook }}
:tags: [describe]
:run: true
def describe(wrapped):
    return f"{wrapped.__name__}{inspect.signature(wrapped)}\n\n{wrapped.__doc__}"

@inject_session
@wrapt.with_doc(factory=describe)
@wrapt.with_signature(prototype=_fetch_price_prototype)
def fetch_price(session, item):
    """Look up the price of an item."""
    return session.lookup(item)

print(fetch_price.__doc__)
print()
print("signature   :", inspect.signature(fetch_price))
print("the original:", wrapt.unwrapped(fetch_price).__doc__)

described_doc = fetch_price.__doc__
```

The docstring opens with `fetch_price(item)`, the signature
`with_signature` presents, because the factory ran on that wrapper
rather than on the function underneath. Swap the two decorators and
the factory sees the raw function and writes `(session, item)`
instead, which is the lie again.

```{verify}
:id: described
:label: The factory embedded the overridden signature
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed describe
described_doc.startswith("fetch_price(item)") and described_doc.endswith("Look up the price of an item.")
```

```{hint}
:title: One factory or two
When both the signature and the docstring are derived from the
wrapped function, the tuple return from a `with_signature` factory on
the previous page does it in one pass. `with_doc` above
`with_signature` is for when the two come from different places, or
when the docstring should quote the signature as presented.
```

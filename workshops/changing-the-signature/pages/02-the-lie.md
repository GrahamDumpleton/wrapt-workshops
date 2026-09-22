---
title: The lie
requires: [verify:the-lie]
---

# The lie

`inject_session` makes a session and passes it as the first argument,
so `fetch_price` declares `session` and its callers do not pass one.

```{cell-insert}
:id: insert-inject
:path: {{ notebook }}
:tags: [inject]
:run: true
@wrapt.decorator
def inject_session(wrapped, instance, args, kwargs):
    return wrapped(Session(), *args, **kwargs)

@inject_session
def fetch_price(session, item):
    """Look up the price of an item in a session."""
    return session.lookup(item)

print("price    :", fetch_price("apple"))
print("signature:", inspect.signature(fetch_price))
help(fetch_price)

try:
    fetch_price(Session(), "apple")
except TypeError as exc:
    signature_problem = str(exc)
    print("TypeError:", signature_problem)

reported = str(inspect.signature(fetch_price))
```

The call works. The signature and the help say `(session, item)`,
and a caller who believes them and passes a session gets a
`TypeError` about too many arguments, from inside the function, after
the decorator added a second session in front. Everything wrapt
preserved so carefully is being preserved from the wrong function:
`fetch_price` as written takes a session, and `fetch_price` as
callable does not.

A `functools.wraps` closure has the same problem, since it copies
`__wrapped__` and `inspect` follows it. The stdlib answer is to
rewrite `__signature__` by hand; wrapt's is the next page.

```{verify}
:id: the-lie
:label: The signature reports a parameter the caller must not pass
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed inject
reported == "(session, item)" and "positional" in signature_problem
```

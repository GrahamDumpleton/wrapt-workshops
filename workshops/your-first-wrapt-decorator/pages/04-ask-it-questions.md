---
title: Ask it questions
requires: [verify:questions-answered, verify:signature-difference]
---

# Ask it questions

Ask the wrapt version the questions the closure version was asked, and
a few more.

```{cell-insert}
:id: insert-questions
:path: {{ notebook }}
:tags: [questions]
:run: true
print("__name__     :", fetch_price.__name__)
print("__qualname__ :", fetch_price.__qualname__)
print("__doc__      :", fetch_price.__doc__)
print("__module__   :", fetch_price.__module__)
print("signature    :", inspect.signature(fetch_price))
print("__wrapped__  :", fetch_price.__wrapped__)
print()
print(inspect.getsource(fetch_price))
```

Every answer is the original's, down to the source code, and nothing
in `timer` copied anything. `help(fetch_price)` in a cell of your own
prints the real signature and the real docstring too.

So far the two versions look equal. Ask one more question, this time
telling `inspect` not to follow the `__wrapped__` link, and ask it of
both.

```{cell-insert}
:id: insert-follow-wrapped
:path: {{ notebook }}
:tags: [follow-wrapped]
:run: true
closure_signature = str(inspect.signature(by_closure, follow_wrapped=False))
wrapt_signature = str(inspect.signature(fetch_price, follow_wrapped=False))

print("closure:", closure_signature)
print("wrapt:  ", wrapt_signature)
```

`(*args, **kwargs)` against `(item, currency='USD')`.

The closure version's name and docstring are copies, and its signature
is a courtesy: `inspect` follows the link `wraps` left and reports what
it finds at the end. Asked not to follow, it reports the wrapper as it
really is, a function of `*args, **kwargs`. Anything that does not
follow the link, or reads `__code__` or `__defaults__` directly, sees
the same.

The wrapt version has nothing to give away, because there is no second
function standing in for the first. The next page is about what is
there instead.

```{verify}
:id: questions-answered
:label: The wrapt version answers with the original's name, docstring and signature
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed questions
fetch_price.__name__ == "fetch_price" and fetch_price.__doc__ == "Look up the price of an item, slowly." and str(inspect.signature(fetch_price)) == "(item, currency='USD')"
```

```{verify}
:id: signature-difference
:label: Without following __wrapped__, only the wrapt version keeps the signature
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed follow-wrapped
closure_signature == "(*args, **kwargs)" and wrapt_signature == "(item, currency='USD')"
```

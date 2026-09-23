---
title: A function wrapper by hand
requires: [verify:by-hand]
---

# A function wrapper by hand

Construct a `FunctionWrapper` directly, from the function and the
wrapper, and call it.

```{cell-insert}
:id: insert-by-hand
:path: {{ notebook }}
:tags: [by-hand]
:run: true
timed = wrapt.FunctionWrapper(fetch_price, wrapper)

price = timed("apple")

print("price         :", price)
print("type          :", type(timed).__name__)
print("__wrapped__   :", timed.__wrapped__ is fetch_price)
print("_self_binding :", timed._self_binding)
print("_self_instance:", timed._self_instance)
print("last call     :", calls[-1])
print("signature     :", inspect.signature(timed))
```

The call went through `wrapper`, which recorded an `instance` of
`None` and the arguments, and the price came back. The rest is the
proxy you know: `__wrapped__` is the function and the signature is
its own. Two `_self_` names are new. `_self_binding` says what kind
of thing was wrapped, here a plain `function`, and `_self_instance`
is what it is bound to, nothing yet.

Now the same through the decorator, to see there is no difference.

```{cell-insert}
:id: insert-by-decorator
:path: {{ notebook }}
:tags: [by-decorator]
:run: true
decorated = wrapt.decorator(wrapper)(fetch_price)

print("same class      :", type(decorated) is type(timed))
print("same function   :", decorated.__wrapped__ is fetch_price)
print("decorated('fig'):", decorated("fig"))
```

`@wrapt.decorator` on `wrapper` makes a decorator, and applying that
to `fetch_price` makes exactly the object built by hand above. The
decorator API is a convenience over this class, and everything it
does, the class does.

```{verify}
:id: by-hand
:label: The FunctionWrapper built by hand is what the decorator builds
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed by-decorator
price == 0.5 and type(timed).__name__ == "FunctionWrapper" and timed._self_binding == "function" and calls[0] == (None, ("apple",)) and type(decorated) is type(timed)
```

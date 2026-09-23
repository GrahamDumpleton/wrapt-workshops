---
title: Not callable
requires: [verify:not-callable]
---

# Not callable

Wrap the function in the base class and call it, then wrap it in
`wrapt.CallableObjectProxy` and call that.

```{cell-insert}
:id: insert-not-callable
:path: {{ notebook }}
:tags: [not-callable]
:run: true
try:
    wrapt.BaseObjectProxy(fetch_price)("apple")
    call_error = None
except TypeError as exc:
    call_error = f"TypeError: {exc}"

callable_proxy = wrapt.CallableObjectProxy(fetch_price)
price = callable_proxy("apple")

print("BaseObjectProxy    :", call_error)
print("CallableObjectProxy:", price)
print("callable()         :", callable(wrapt.BaseObjectProxy(fetch_price)), callable(callable_proxy))
```

`BaseObjectProxy` has no `__call__`, and Python decides whether an
object can be called by whether its type has one, so `callable()`
says no and the call raises before the function is ever reached.
`CallableObjectProxy` is the base class plus `__call__`, which passes
the arguments to the target and returns what it returns. Nothing
else changes: it is the same proxy, now callable.

```{verify}
:id: not-callable
:label: The base proxy refused the call and the callable proxy made it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed not-callable
call_error is not None and price == 0.5 and callable(callable_proxy)
```

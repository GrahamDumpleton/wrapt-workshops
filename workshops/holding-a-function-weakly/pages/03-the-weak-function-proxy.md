---
title: The weak function proxy
requires: [verify:weak-function-proxy]
---

# The weak function proxy

`wrapt.WeakFunctionProxy` over the same bound method, called while
the shop lives, and again after it is gone.

```{cell-insert}
:id: insert-weak-function-proxy
:path: {{ notebook }}
:tags: [weak-function-proxy]
:run: true
collected = []

buy = wrapt.WeakFunctionProxy(shop.buy, callback=lambda proxy: collected.append("shop"))

while_alive = buy("pear")
print("while the shop lives:", while_alive)

del shop
gc.collect()

try:
    buy("pear")
    after_error = None
except ReferenceError as exc:
    after_error = f"ReferenceError: {exc}"

print("after del shop      :", after_error)
print("callback ran        :", collected)
```

The proxy is callable in place of the method, and works while the
shop is alive: it holds the shop and the underlying function weakly,
as `WeakMethod` does, and on each call binds them together again
and calls the result. Once the shop is collected, a call raises
`ReferenceError` rather than quietly calling the function with no
instance, and the `callback` given at construction has run, with the
proxy as its argument.

Nothing was kept alive. The only reference to the shop was the name
`shop`, and deleting it was enough.

```{verify}
:id: weak-function-proxy
:label: The proxy called the method, then raised once the shop was gone
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed weak-function-proxy
while_alive == "corner sells pear" and after_error is not None and collected == ["shop"]
```

```{hint}
:title: Plain functions too
`WeakFunctionProxy` over a plain function holds the function weakly
and behaves the same way: callable while the function exists, and a
`ReferenceError` after it is gone. A module level function is kept
alive by its module, so that case rarely arises, and the bound
method is the one that matters.
```

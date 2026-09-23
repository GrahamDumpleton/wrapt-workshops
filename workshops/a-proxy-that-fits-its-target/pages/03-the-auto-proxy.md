---
title: The auto proxy
requires: [verify:auto-works]
---

# The auto proxy

Now the same three in `AutoObjectProxy`.

```{cell-insert}
:id: insert-auto-works
:path: {{ notebook }}
:tags: [auto-works]
:run: true
auto_results = {
    "list": attempt(wrapt.AutoObjectProxy([1, 2, 3]), list),
    "call": attempt(wrapt.AutoObjectProxy(fetch_price), lambda proxy: proxy("apple")),
    "next": attempt(wrapt.AutoObjectProxy(countdown()), next),
}

for kind, result in auto_results.items():
    print(f"{kind}: {result}")
```

All three work, from one class and no subclass. When an
`AutoObjectProxy` is constructed it looks at the target, finds which
of the special methods it has, and gives the proxy those and only
those, so a proxy over the list iterates, one over the function is
callable and one over the generator resumes, while a proxy over a
number would still be none of them. The proxy is shaped by its
target rather than by a class written ahead of time, which is
exactly what is needed when the target's kind is decided at runtime.

```{verify}
:id: auto-works
:label: The auto proxy iterated, called and resumed
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed auto-works
auto_results == {"list": [1, 2, 3], "call": 0.5, "next": 3}
```

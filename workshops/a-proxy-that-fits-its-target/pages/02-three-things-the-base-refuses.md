---
title: Three things the base refuses
requires: [verify:base-refuses]
---

# Three things the base refuses

Wrap each target in `BaseObjectProxy` and use it the way its kind is
used: iterate the list, call the function, resume the generator.

```{cell-insert}
:id: insert-base-refuses
:path: {{ notebook }}
:tags: [base-refuses]
:run: true
base_results = {
    "list": attempt(wrapt.BaseObjectProxy([1, 2, 3]), list),
    "call": attempt(wrapt.BaseObjectProxy(fetch_price), lambda proxy: proxy("apple")),
    "next": attempt(wrapt.BaseObjectProxy(countdown()), next),
}

for kind, result in base_results.items():
    print(f"{kind}: {result}")
```

Three refusals. `__iter__`, `__call__` and `__next__` are not on the
base class, and Python looks for each on the type, so the proxy is
not iterable, not callable and not an iterator, whatever it wraps.
The fix you know is a subclass defining the missing method, and it
is the right fix when you know which method is missing.

```{verify}
:id: base-refuses
:label: The base proxy refused all three
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed base-refuses
all(str(result).startswith("TypeError") for result in base_results.values())
```

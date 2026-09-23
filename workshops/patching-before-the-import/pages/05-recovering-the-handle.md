---
title: Recovering the handle
requires: [verify:recovered]
---

# Recovering the handle

The `?` patch on the first page returned `None`. The wrapper exists
now, on `shop.reports.summary`, and the way to find it without a
handle is `wrapt.find_wrapper` with a predicate: a function given
each entry of the chain, outermost first, that says whether it is
the one. A wrapper installed by `wrap_function_wrapper` keeps its
wrapper function as `_self_wrapper`, so the predicate asks for the
entry whose wrapper is `capture`.

```{cell-insert}
:id: insert-recovered
:path: {{ notebook }}
:tags: [recovered]
:run: true
target = wrapt.resolve_path("shop.reports", "summary")[2]

found = wrapt.find_wrapper(
    target,
    predicate=lambda entry: getattr(entry, "_self_wrapper", None) is capture,
)

print("found a         :", type(found).__name__)
print("is the wrapper  :", wrapt.is_wrapped_by(target, found))

wrapt.unwrap_object("shop.reports", "summary", found)
wrapt.unwrap_object("shop.invoices", "render", handles["render"])
wrapt.unwrap_object("shop.pricing", "fetch_price", handles["fetch_price"])
wrapt.unwrap_object("shop.shipping", "quote", patches.handles["quote"])

remaining = [
    type(wrapt.resolve_path(module, name)[2]).__name__
    for module, name in [
        ("shop.reports", "summary"),
        ("shop.invoices", "render"),
        ("shop.pricing", "fetch_price"),
        ("shop.shipping", "quote"),
    ]
]

print("all four now    :", remaining)
```

Found, confirmed, and removed, along with the three patches whose
hooks kept their handles. Every module is back to a plain function.

The predicate form is the fallback. Where a deferred patch may need
removing, the better shape is the one the hook pages used: a hook of
your own that makes the patch and keeps what `wrap_function_wrapper`
returns, so nothing has to be searched for later.

```{verify}
:id: recovered
:label: The deferred patch's handle was found and every patch is out
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed recovered
type(found).__name__ == "FunctionWrapper" and remaining == ["function", "function", "function", "function"]
```

```{hint}
:title: Why resolve_path and not shop.reports.summary
For a module attribute the two are the same object, since a module
does no descriptor binding, and `shop.reports.summary` would have
done here. For a method on a class they are not, and `resolve_path`
is the form that works for both, so it is the one to write.
```

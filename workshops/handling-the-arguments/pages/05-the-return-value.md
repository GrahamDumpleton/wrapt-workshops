---
title: The return value
requires: [verify:return-changed]
---

# The return value

Everything so far has returned what `wrapped` returned. Nothing
requires that. The value a wrapper returns is the value the caller
gets, and the wrapper can transform it, wrap it in something else, or
not call `wrapped` at all.

The cell applies two decorators to one plain function by calling them,
rather than with `@`, so that both versions exist side by side.

```{cell-insert}
:id: insert-return
:path: {{ notebook }}
:tags: [return]
:run: true
@wrapt.decorator
def in_cents(wrapped, instance, args, kwargs):
    return round(wrapped(*args, **kwargs) * 100)

@wrapt.decorator
def as_receipt(wrapped, instance, args, kwargs):
    def _execute(item, *_args, **_kwargs):
        return {"item": item, "price": wrapped(item, *_args, **_kwargs)}

    return _execute(*args, **kwargs)

def price_of(item):
    return PRICES[item]

cents = in_cents(price_of)
receipt = as_receipt(price_of)

apple_cents = cents("apple")
pear_receipt = receipt("pear")

print("in cents:", apple_cents)
print("receipt :", pear_receipt)
```

`in_cents` transforms the result. `as_receipt` builds a new value
around it, and uses the nested function from earlier to know which
item the caller asked about. A third kind, a wrapper that returns a
cached or stubbed value and never calls `wrapped`, is the shape of
every cache, and **Caching methods**, a later workshop, is built on
it.

One consequence to keep in mind. The decorated `receipt` still reports
`price_of`'s signature and docstring, which say nothing about
returning a dict. When a decorator changes what a function takes or
returns, the introspection that wrapt preserves so carefully is now
preserving the wrong thing, and **Changing the signature**, the last
of these workshops, is about telling it otherwise.

```{verify}
:id: return-changed
:label: One wrapper transformed the result and the other wrapped it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed return
apple_cents == 50 and pear_receipt == {"item": "pear", "price": 0.75}
```

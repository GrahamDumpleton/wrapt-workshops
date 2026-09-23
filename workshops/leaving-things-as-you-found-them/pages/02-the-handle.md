---
title: The handle
requires: [verify:the-handle]
---

# The handle

Install a patch and keep what comes back. Then ask wrapt whether the
patch is in place, twice: once handing it `Shop.buy`, which is what
`getattr` gives, and once handing it what `wrapt.resolve_path` finds
in the class namespace.

```{cell-insert}
:id: insert-the-handle
:path: {{ notebook }}
:tags: [the-handle]
:run: true
handle = wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", notify)

via_getattr = wrapt.is_wrapped_by(Shop.buy, handle)

parent, attribute, raw = wrapt.resolve_path(shop.cart, "Shop.buy")
via_path = wrapt.is_wrapped_by(raw, handle)

original = wrapt.unwrapped(raw)

print("handle is what the class holds:", handle is raw)
print("is_wrapped_by via getattr     :", via_getattr)
print("is_wrapped_by via resolve_path:", via_path)
print("chain                         :", chain(shop.cart, "Shop.buy"))
print("at the bottom                 :", original)
```

The handle is the very object the class namespace now holds, a
`FunctionWrapper` over the `function`, and `is_wrapped_by` finds it
there. It does not find it in `Shop.buy`, because reading a method
off the class runs the descriptor protocol and produces a fresh
bound wrapper each time, and a fresh object is not the handle.
`is_wrapped_by` matches by identity, never equality, since a proxy
delegates equality to what it wraps, so the object it is given has
to be the one that is stored. `resolve_path` is how to get that
object, for every question on this page and every removal after it.

`wrapt.wrapper_chain` yields the stack from the outermost wrapper
down to the original, which the `chain` helper prints as type names,
and `wrapt.unwrapped` is the last link, the original function, which
nothing on this page had to save.

```{verify}
:id: the-handle
:label: The handle is found through resolve_path and not through getattr
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed the-handle
handle is raw and via_path and not via_getattr and chain(shop.cart, "Shop.buy") == ["FunctionWrapper", "function"] and original is handle.__wrapped__
```

```{hint}
:title: Finding a patch you did not keep the handle for
`is_wrapped_by` and `wrapt.find_wrapper` both take a `predicate`
instead of a handle: a function given each entry of the chain that
says whether it is the one. A wrapper installed by
`wrap_function_wrapper` keeps the wrapper function as
`_self_wrapper`, so `predicate=lambda entry: getattr(entry,
"_self_wrapper", None) is notify` finds a patch by the wrapper it
runs. The workshop on deferred patches uses this, since a deferred
patch returns no handle.
```

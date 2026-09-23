---
title: The one thing removal refuses
requires: [verify:not-outermost]
---

# The one thing removal refuses

A wrapt wrapper buried under another wrapt wrapper can be spliced
out, because the wrapper above holds a real reference to what it
wraps and wrapt can point it elsewhere. A closure made with
`functools.wraps` is different: its `__wrapped__` is a note, not the
thing it calls. The closure calls whatever `func` it closed over,
and changing its `__wrapped__` changes nothing.

Install a wrapt patch, then put such a closure over it, the way the
first workshop patched by assignment, and try to remove the wrapt
patch from underneath.

```{cell-insert}
:id: insert-not-outermost
:path: {{ notebook }}
:tags: [not-outermost]
:run: true
handle = wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", notify)

def logged(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

Shop.buy = logged(Shop.__dict__["buy"])

print("chain:", chain(shop.cart, "Shop.buy"))

try:
    wrapt.unwrap_object(shop.cart, "Shop.buy", handle)
    refusal = "no error"
except wrapt.WrapperNotOutermostError as error:
    refusal = f"WrapperNotOutermostError: {error}"

print()
print(refusal)
```

`WrapperNotOutermostError`, naming what sits above: a `function`.
Splicing beneath it would have updated a `__wrapped__` that nothing
reads and left the closure calling the wrapper it closed over, so
the patch would have looked removed and kept running. wrapt refuses
rather than pretend. The fix is whoever owns the closure taking it
off first; here that is you, so take it off by following its
`__wrapped__` link, and remove the wrapt patch.

```{cell-insert}
:id: insert-closure-off
:path: {{ notebook }}
:tags: [closure-off]
:run: true
Shop.buy = Shop.__dict__["buy"].__wrapped__

print("closure off:", chain(shop.cart, "Shop.buy"))

wrapt.unwrap_object(shop.cart, "Shop.buy", handle)

print("patch out  :", chain(shop.cart, "Shop.buy"))
print("as shipped :", wrapt.resolve_path(shop.cart, "Shop.buy")[2] is original)
```

`Shop.buy` is the function the module defined, with nothing on it,
which is the state every page of this workshop ends in and the state
the next workshop's temporary patches return to by themselves.

```{verify}
:id: not-outermost
:label: Removal refused under the closure and succeeded once it was gone
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed closure-off
refusal.startswith("WrapperNotOutermostError") and chain(shop.cart, "Shop.buy") == ["function"] and wrapt.resolve_path(shop.cart, "Shop.buy")[2] is original
```

```{hint}
:title: The closure was assigned onto Shop.__dict__["buy"], not Shop.buy
`logged(Shop.buy)` would have wrapped what `getattr` gives, and
`getattr` on a class holding a `FunctionWrapper` gives a fresh bound
wrapper, so the closure would have closed over a copy. Reading the
namespace directly is the same rule as everywhere else on this page.
```

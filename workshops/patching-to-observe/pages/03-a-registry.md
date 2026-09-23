---
title: A registry
requires: [verify:registry]
---

# A registry

A tool that patches several targets needs to know what it has
patched, so that it installs each patch once and can take them all
out. The registry from the wrapt documentation is a dictionary from
target and name to handle. `instrument` wraps a target only if it is
not already in the registry, and `uninstrument` empties the registry,
removing each patch with `missing_ok=True`, since a shutdown path
should not fail because something else replaced an attribute in the
meantime.

Before any of it runs, a version check against the `__version__` in
{open}`shop/__init__.py`: patches are written against one version
of a library, and the honest thing when the version is wrong is to
patch nothing and say so.

```{cell-insert}
:id: insert-registry
:path: {{ notebook }}
:tags: [registry]
:run: true
registry = {}

def instrument(target, name):
    if (target, name) not in registry:
        registry[(target, name)] = wrapt.wrap_function_wrapper(target, name, recorder)

def uninstrument():
    while registry:
        (target, name), handle = registry.popitem()
        wrapt.unwrap_object(target, name, handle, missing_ok=True)

def instrument_shop():
    if not shop.__version__.startswith("1."):
        print(f"shop {shop.__version__} is not supported; patching nothing")
        return
    instrument(shop.pricing, "fetch_price")
    instrument(shop.cart, "Shop.buy")

instrument_shop()
instrument_shop()

installed = len(registry)
buy_chain = chain(shop.cart, "Shop.buy")

corner.buy("apple")

print("registry holds :", installed, "patches")
print("Shop.buy       :", buy_chain)
print("records so far :", len(recorder.calls))
```

Called twice, `instrument_shop` installed each patch once: the
registry knew, so the second call did nothing, and the chain on
`Shop.buy` holds one wrapper. Without the check, the second call
would have stacked a second recorder and every call would have been
counted twice. `wrapt.is_wrapped_by` with the handle is the other
way to ask, and the registry is the handle kept where the asking
happens.

```{verify}
:id: registry
:label: Each patch was installed once and the version check passed
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed registry
installed == 2 and buy_chain == ["FunctionWrapper", "function"] and len(recorder.calls) == 7
```

```{hint}
:title: What the version check protects
A patch names an attribute by its path, and the path is a promise the
library never made. A release that renames `fetch_price` or moves
`buy` to a base class turns the patch into a `PathResolutionError`
at best and, at worst, a wrapper on the wrong thing. Checking the
version, and refusing outside the range the patches were tested
against, is how an instrumentation package fails loudly instead.
```

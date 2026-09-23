---
title: As a call
requires: [verify:as-a-call]
---

# As a call

`wrap_function_wrapper` is a function, so the target and the name
can come from anywhere: a list, a configuration file, a loop over
the methods of a class. That is its strength. The cell patches two
methods from a list of targets, and keeps what each call returned,
under the name it patched.

```{cell-insert}
:id: insert-as-a-call
:path: {{ notebook }}
:tags: [as-a-call]
:run: true
targets = [
    (shop.cart, "Shop.tax"),
    (shop.cart, "Shop.empty"),
]

handles = {}

for target, name in targets:
    handles[name] = wrapt.wrap_function_wrapper(target, name, notify)

tax = Shop.tax(10)
fresh = Shop.empty()

print()
for name, handle in handles.items():
    print(f"{name:11} -> {type(handle).__name__}")
```

Two patches, two handles, and the calls are logged. Nothing about
this needed the targets to be known when the code was written, which
is what makes the call form right for an instrumentation library that
reads a list of things to patch, or for a test that patches whatever
the case under test needs. The handles are kept because a patch made
by code is usually a patch that code will want to take out again,
which is the workshop after next.

```{verify}
:id: as-a-call
:label: Both targets were patched from the list and the handles kept
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed as-a-call
tax == 1.0 and type(fresh) is Shop and set(handles) == {"Shop.tax", "Shop.empty"} and all(type(h).__name__ == "FunctionWrapper" for h in handles.values())
```

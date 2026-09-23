---
title: The method that dies at once
requires: [verify:dies-at-once]
---

# The method that dies at once

Take a weak reference to `shop.buy`, the standard library way, and
see how long it lasts.

```{cell-insert}
:id: insert-dies-at-once
:path: {{ notebook }}
:tags: [dies-at-once]
:run: true
ref = weakref.ref(shop.buy)
ref_alive = ref() is not None

try:
    weakref.proxy(shop.buy)("apple")
    proxy_error = None
except ReferenceError as exc:
    proxy_error = f"ReferenceError: {exc}"

weak_method = weakref.WeakMethod(shop.buy)
via_weak_method = weak_method()("apple")

print("weakref.ref alive:", ref_alive)
print("weakref.proxy    :", proxy_error)
print("WeakMethod       :", via_weak_method)
```

The reference is dead before the next line, and the proxy raises on
its first call, while the shop is alive and well. `shop.buy` is not
an attribute stored on the shop. Each time it is read, Python makes a
new bound method object pairing the function with the shop, and that
object is discarded as soon as nothing holds it, which is
immediately. The weak reference pointed at a thing that lived for
one expression.

`weakref.WeakMethod` knows this and holds the shop and the function
separately, but it hands back a reference to dereference and call,
not something callable in place of the method. What is wanted is a
proxy.

```{verify}
:id: dies-at-once
:label: The weak reference was dead at once and WeakMethod needs dereferencing
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed dies-at-once
not ref_alive and proxy_error is not None and via_weak_method == "corner sells apple"
```

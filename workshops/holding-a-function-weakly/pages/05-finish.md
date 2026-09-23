---
title: What you know now
requires: [quiz:why-dead]
---

# What you know now

A bound method is made on each access and discarded, so a weak
reference to one is dead at once and `weakref.proxy` on one raises
on its first call. `WeakFunctionProxy` holds the instance and the
underlying function weakly, rebinds them on each call, raises
`ReferenceError` once the instance is gone and runs its callback
when that happens. A registry built from it never keeps its objects
alive and never calls into a dead one.

```{quiz}
:id: why-dead
:title: Why the reference was dead
:shuffle: true
question: "Why was `weakref.ref(shop.buy)()` already `None` on the next line, while `shop` was still alive?"
options:
  - text: "`shop.buy` makes a new bound method object each time it is read, and that object was discarded as soon as the expression finished."
    correct: true
  - text: "Weak references to methods are not allowed, so `weakref.ref` returned a dead reference."
    explanation: "The reference was made without error. It pointed at a real object, which simply did not live past the expression that made it."
  - text: "The shop was collected, because `weakref.ref` does not hold it."
    explanation: "`shop` was still bound and `shop.buy(\"apple\")` still worked. What died was the bound method object, not the shop."
  - text: "Bound methods are cached on the instance and cleared by the garbage collector."
    explanation: "They are not cached at all. Each read of `shop.buy` builds a fresh one from the function and the instance, which is why nothing holds the previous one."
explanation: "A bound method is a temporary pairing of function and instance. Holding it weakly holds nothing, so `WeakFunctionProxy` holds the two parts instead and pairs them again on each call."
```

## Where this goes next

The last of these workshops turns to a question every proxy meets
sooner or later: what happens when someone pickles it, or copies it.
The base class refuses, on purpose, and a subclass says how.

**Saving and restoring a proxy** is next.

Press Finish below to move on.

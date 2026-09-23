---
title: What you know now
requires: [quiz:why-no-iter]
---

# What you know now

A proxy is a second object, and the questions about which object
this is come back honest: `is`, `id()` and `type()` name the proxy.
Everything that goes through an attribute, `__class__` included, and
so `isinstance`, follows the target.

An operator returns whatever the target returned, unwrapped. An
in-place operator keeps the proxy, updating the target in place when
it can and wrapping the new value when it cannot.

`BaseObjectProxy` leaves `__iter__` and `__call__` off on purpose,
because their presence on a type is what says an object is iterable
or callable, and a proxy must claim only what its target can do.
`ObjectProxy` forwards `__iter__` and exists only for code written
before wrapt 2.0.0; new code does not use it.

```{quiz}
:id: why-no-iter
:title: Why iteration fails
:shuffle: true
question: "`len(proxy)` works on a `BaseObjectProxy` over a list, and `iter(proxy)` raises `TypeError`. Why the difference?"
options:
  - text: "`__len__` is forwarded like the other special methods, and `__iter__` is left off the class so that a proxy never claims to be iterable when its target is not."
    correct: true
  - text: "Iteration needs `__next__`, which no proxy can forward."
    explanation: "A proxy can forward `__next__` as easily as `__len__`. The base class leaves `__iter__` off by choice, not because it cannot be written."
  - text: "Lists are iterated through a C level fast path that skips the proxy."
    explanation: "`iter()` looks for `__iter__` on the proxy's type, finds none, and raises before any list code is reached."
  - text: "`__iter__` is forwarded, but only for `ObjectProxy` subclasses that also define `__len__`."
    explanation: "`ObjectProxy` forwards `__iter__` unconditionally, which is why new code does not use it. `BaseObjectProxy` never does, whatever else is defined."
explanation: "Whether a type has `__iter__` is how Python, and `isinstance` against `Iterable`, decide whether an object is iterable. A base class for wrapping anything must not carry it, so a proxy over something iterable defines it itself."
```

## Where this goes next

An assignment through a proxy lands on the target, which is right
until the proxy needs a count, a label or a cache of its own. The
next workshop is about where a proxy keeps what belongs to it, and
how it says so.

**What belongs to the proxy** is next.

Press Finish below to move on.

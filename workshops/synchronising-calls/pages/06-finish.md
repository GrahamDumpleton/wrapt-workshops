---
title: What you know now
requires: [quiz:which-lock]
---

# What you know now

`@wrapt.synchronized` runs the decorated function with a lock held,
made on the first call and kept on the object that `instance` points
to when there is one and on the function when there is not:

- an instance method locks per instance,

- a class method locks on the class, as does a decorated class,

- a static method or a function locks on the function.

`with wrapt.synchronized(obj):` takes the lock belonging to `obj`,
which is the same lock a decorated method on `obj` uses, and any
object that accepts attributes can be the context. The automatic lock
is an `RLock`, so synchronised code may call synchronised code on the
same object. `wrapt.synchronized(lock)` uses a lock or semaphore of
your own instead.

The standard library version is a lock in `__init__`, a `with` in
every method, and a decision, per class, about where the lock for a
class method goes.

```{quiz}
:id: which-lock
:title: Which lock
:shuffle: true
question: "`Account.deposit` and `Account.audit` are both instance methods decorated with `@wrapt.synchronized`. A thread calls `alpha.deposit(1)` while another calls `beta.audit()`. What happens?"
options:
  - text: "They run at the same time, because the two calls take locks on two different instances."
    correct: true
  - text: "They take turns, because both methods are on the same class and share its lock."
    explanation: "An instance method locks on the instance, not the class. Only a class method or a decorated class puts the lock on the class."
  - text: "They take turns, because deposit and audit are different methods and each method has one lock."
    explanation: "The lock is not per method. Two decorated methods on one instance share that instance's lock, and two instances do not."
  - text: "They run at the same time only if audit has not been called before, since the lock is made on the first call."
    explanation: "When the lock is made does not change who shares it. beta's lock is made on beta, whenever that happens, and alpha never uses it."
explanation: "instance is alpha for one call and beta for the other, so the two calls take two different locks and do not wait for each other. Two calls on alpha, whichever methods, would share alpha's lock."
```

## Where this goes next

Everything here was threads. The next workshop is coroutines, where a
synchronous wrapper on an `async def` times the wrong thing, an
`async def` wrapper fixes it, one decorator serves both, and
`wrapt.synchronized` switches to an `asyncio.Lock` by itself.

**Wrapping async functions** is next.

Press Finish below to move on.

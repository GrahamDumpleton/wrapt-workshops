---
title: What you know now
requires: [quiz:why-per-instance]
---

# What you know now

`functools.lru_cache` on a method makes `self` part of every key, and
a key is held, hashed and counted, so:

- every instance shares one `maxsize` budget,

- every instance that has called the method stays alive until it is
  evicted or the cache is cleared, and

- an instance that cannot be hashed cannot be cached.

`wrapt.lru_cache` stores a `functools.lru_cache` on each instance as
an attribute, created on the first call, so each instance has its own
budget, goes when its last reference goes, and is never hashed.
`cache_info()` and `cache_clear()` on a bound method operate on that
instance's cache. On a function, a class method or a static method
there is one shared cache, as before. Instances that are pickled
need a `__getstate__` that drops the `_lru_cache_` attributes.

```{quiz}
:id: why-per-instance
:title: Why the instance goes away
:shuffle: true
question: "With `wrapt.lru_cache` on a method, why is an instance freed when its last name is deleted, when with `functools.lru_cache` it was not?"
options:
  - text: "wrapt.lru_cache uses weak references for self in its cache keys."
    explanation: "There is no self in the keys. The cache belongs to the instance, so the instance is not part of what it stores."
  - text: "The cache is an attribute of the instance rather than of the method, so nothing outside the instance holds a reference to it."
    correct: true
  - text: "wrapt.lru_cache clears the cache automatically whenever an instance's reference count drops."
    explanation: "Nothing is cleared. The cache is freed along with the instance because it is part of the instance's own dictionary."
  - text: "wrapt.lru_cache only caches the arguments after self, so self is never stored anywhere."
    explanation: "That is true of the keys, but the reason is where the cache lives, not what it stores. A shared cache keyed without self would be wrong, since two instances would share results."
explanation: "The standard library's cache is one object on the class, holding keys that include every instance. wrapt's cache is on each instance, keyed by the other arguments, and dies with it."
```

## Where this goes next

The next decorator is a lock. `wrapt.synchronized` serialises calls,
and the interesting question is the same as this workshop's: where
the lock lives. On an instance method it is per instance, on a class
method per class, and the context manager form shares it.

**Synchronising calls** is next.

Press Finish below to move on.

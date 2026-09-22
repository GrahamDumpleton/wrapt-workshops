---
title: What you know now
requires: [quiz:why-first-call]
---

# What you know now

An argument checker is a state class:

```python
class TypeChecker:
    def __init__(self):
        self.signature = None

    @wrapt.decorator
    def __call__(self, wrapped, instance, args, kwargs):
        if self.signature is None:
            self.signature = inspect.signature(wrapped)
        bound = self.signature.bind(*args, **kwargs)
        bound.apply_defaults()
        ...
        return wrapped(*args, **kwargs)
```

The signature is computed once, from `wrapped` on the first call,
when `wrapped` is already bound and `self` or `cls` is already gone,
so the same class checks a function, an instance method, a class
method and a static method. Binding resolves positional and keyword
arguments to names, and applying defaults checks what the caller left
out. A `ValueChecker` takes its constraints from the decoration site
through a static method with an optional positional-only first
parameter. The type checker goes on top.

```{quiz}
:id: why-first-call
:title: Why the first call
:shuffle: true
question: "Why does TypeChecker compute the signature from `wrapped` inside the wrapper, on the first call, rather than from the function in `check()` when the decorator is applied?"
options:
  - text: "Because inspect.signature is slow, and deferring it saves time when the function is never called."
    explanation: "It is computed once either way. The timing matters for what it sees, not for how long it takes."
  - text: "Because at decoration time a method is still a plain function with self in its signature, and by the first call wrapped is bound and self is gone, so args binds to it directly."
    correct: true
  - text: "Because annotations are not evaluated until the function is first called."
    explanation: "Annotations are available on the function object from the moment it is defined, and the checker reads them from the signature either way."
  - text: "Because wrapt only supplies wrapped inside the wrapper, and check() never sees the function."
    explanation: "check() receives the function as its argument and could inspect it. It would just see the wrong signature for a method."
explanation: "In the class body, before the class exists, a method is a function whose first parameter is self. The wrapper runs after descriptor binding, and wrapt hands it the bound method, whose signature matches args exactly. Reading it there removes every special case."
```

## Where this goes next

The next decorator is a cache, and the interesting part is not the
caching but what caching a method does to the instances: the standard
library's `lru_cache` keeps them alive, shares one budget across all
of them, and refuses the unhashable ones. `wrapt.lru_cache` keeps a
cache per instance and has none of those problems.

**Caching methods** is next.

Press Finish below to move on.

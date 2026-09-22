---
title: What you know now
requires: [quiz:which-branch]
---

# What you know now

A universal decorator branches on two tests:

```python
@wrapt.decorator
def universal(wrapped, instance, args, kwargs):
    if instance is None:
        if inspect.isclass(wrapped):
            ...  # a class
        else:
            ...  # a function or a static method
    else:
        if inspect.isclass(instance):
            ...  # a class method
        else:
            ...  # an instance method
    return wrapped(*args, **kwargs)
```

A decorator that supports fewer cases raises at the call when it is
used elsewhere, with a message that says what was wrong.

Decorators stack in the usual order, wrapt ones and closures in any
mix, and each layer's `__wrapped__` is the layer below.
`wrapt.wrapper_chain()` walks the layers and `wrapt.unwrapped()`
returns the innermost object, through wrapt wrappers and
`functools.wraps` closures alike.

```{quiz}
:id: which-branch
:title: Which branch
:shuffle: true
question: "Inside a universal decorator's wrapper, `instance` is `None` and `inspect.isclass(wrapped)` is `False`. What was decorated?"
options:
  - text: "A class, called to make an instance."
    explanation: "A class gives instance None too, but then `inspect.isclass(wrapped)` is True: the wrapper forwards `__class__` from the class, so the test sees through it."
  - text: "A class method, called on the class."
    explanation: "A class method arrives with instance set to the class, and `inspect.isclass(instance)` is the test for it."
  - text: "A plain function, or a static method, which the wrapper cannot and need not tell apart."
    correct: true
  - text: "An instance method called through the class with an explicit self, which wrapt could not bind."
    explanation: "wrapt normalises that call: it moves the explicit self into instance, so the wrapper sees an ordinary method call."
explanation: "instance None rules out both kinds of method, and the class test rules out a class. What is left is a function, whether it lives at module level or as a static method in a class, and the same code is right for both."
```

## Where this goes next

That is the end of the first two movements: what wrapt does and how a
wrapper works. What follows is five decorators worth having written or
used once. The first checks arguments, types against annotations and
values against constraints, and it is the state class from **Keeping
state** doing real work.

**Validating arguments** is next.

Press Finish below to move on.

---
title: What you know now
requires: [quiz:why-the-signature-survives]
---

# What you know now

A wrapt decorator is one function of four arguments:

```python
@wrapt.decorator
def timer(wrapped, instance, args, kwargs):
    return wrapped(*args, **kwargs)
```

`wrapped` is the function being decorated, `instance` is what it is
bound to, and `args` and `kwargs` are the call's arguments as a tuple
and a dict, spread out by your wrapper when it makes the call. There
is no inner function and no `functools.wraps`.

The decorated name is a `FunctionWrapper`, a proxy holding the
original and your wrapper. Every attribute it does not define is
looked up on the original, so the name, the docstring, the signature,
the source and even `__class__` are the original's rather than copies.
`type()` is the one question that tells the two apart, and
`inspect.signature(..., follow_wrapped=False)` is the one the closure
version gets wrong.

```{quiz}
:id: why-the-signature-survives
:title: Why the signature survives
:shuffle: true
question: "Why does `inspect.signature(fetch_price, follow_wrapped=False)` still report `(item, currency='USD')` for the wrapt version?"
options:
  - text: "wrapt copies the signature onto the wrapper when the decorator is applied."
    explanation: "Nothing is copied. The page that set an attribute on the original after decoration and read it through the wrapper showed that the wrapper asks the original every time."
  - text: "The decorated name is a proxy that forwards attribute lookups to the original, so there is no second function with parameters of its own to find."
    correct: true
  - text: "wrapt.decorator rewrites your wrapper function to take the same parameters as the function it decorates."
    explanation: "Your wrapper keeps its four parameters. It is not the object bound to the decorated name, so its parameters are never what inspect sees."
  - text: "inspect ignores follow_wrapped for functions decorated with wrapt."
    explanation: "It honours it. Asked not to follow the link, inspect reads `__code__` and `__defaults__` off the object it was given, and the proxy forwards those to the original."
explanation: "A FunctionWrapper defines almost nothing of its own. inspect asks it for `__code__` and `__defaults__`, the proxy hands the question to the original function, and the answer is the original's signature."
```

## Where this goes next

`instance` was `None` on every page here. The next workshop puts one
decorator on a function, an instance method, a class method, a static
method and a class, and reads what `instance` holds in each case,
which is where wrapt does something a closure decorator cannot.

**What instance tells you** is next.

Press Finish below to move on.

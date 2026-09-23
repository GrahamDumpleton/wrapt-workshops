---
title: What you know now
requires: [quiz:which-proxy]
---

# What you know now

`BaseObjectProxy` has no `__call__`, so a proxy over a function
cannot be called until something adds it. `CallableObjectProxy` is
that, and a subclass that overrides `__call__` intercepts every call
while the name, the docstring, the signature and `isinstance` still
answer for the function. `wrapt.partial` is a callable proxy holding
bound arguments under `_self_args` and `_self_kwargs`, with the same
signature `functools.partial` reports and the function still
underneath.

```{quiz}
:id: which-proxy
:title: Which proxy
:shuffle: true
question: "You want to wrap a function so that calls to it are logged, and code that receives the wrapper must not be able to tell it from the function. Which base class?"
options:
  - text: "`wrapt.CallableObjectProxy`, with `__call__` overridden to log and then call `self.__wrapped__`."
    correct: true
  - text: "`wrapt.BaseObjectProxy`, since it forwards everything."
    explanation: "It forwards everything except `__call__`, which it leaves off on purpose. A proxy over a function needs a class that has it, or has to define it."
  - text: "`functools.partial`, with no bound arguments."
    explanation: "A `partial` is a different kind of object: no `__name__`, not a function to `isinstance`. It binds arguments, it does not stand in."
  - text: "`unittest.mock.Mock` with `wraps`."
    explanation: "A mock records calls, but it is a mock to `isinstance` and every attribute on it is another mock. It is not the function to the code that receives it."
explanation: "`CallableObjectProxy` is the base proxy plus `__call__`. Overriding `__call__` on a subclass is the intercept, and the proxy answers every other question with the function's own answers."
```

## Where this goes next

Every wrapt decorator is a callable proxy too, of a kind that also
knows how to bind itself to an instance when it is used as a method.
The next workshop takes that class, `FunctionWrapper`, out of the
decorator and reads what it does.

**Under the decorator** is next.

Press Finish below to move on.

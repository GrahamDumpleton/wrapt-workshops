---
title: What you know now
requires: [quiz:boolean-or-callable]
---

# What you know now

`wrapt.decorator(enabled=...)` switches a decorator off:

- **A boolean** is read once, when the decorator is applied. `False`
  returns the original function untouched, so `type()` says
  `function` and no wrapper runs, ever.

- **A callable** is called on every call of the decorated function,
  and a false result bypasses the wrapper for that call. The
  decorated name is a `FunctionWrapper` either way.

- **Any other object** has its truth value taken on every call, so a
  settings object with `__bool__` is a switch.

The standard library has nothing for this: a closure decorator that
wants a switch writes it into itself, once per decorator.

```{quiz}
:id: boolean-or-callable
:title: Boolean or callable
:shuffle: true
question: "A logging decorator is defined with `enabled=LOGGING`, where `LOGGING` was `False` at import time. Later the program sets `LOGGING = True`. What happens on the next call of a function decorated before the change?"
options:
  - text: "The wrapper runs, because enabled is checked on every call."
    explanation: "A boolean is not checked on every call. It was read once, when the decorator was applied, and no wrapper was created."
  - text: "Nothing changes: the decorated name is the original function, and there is no wrapper to run."
    correct: true
  - text: "The wrapper runs from the next time the decorated function is looked up, since the FunctionWrapper re-reads the flag when bound."
    explanation: "There is no FunctionWrapper. With `enabled=False` the decorator returned the original function and kept nothing."
  - text: "It raises, because a disabled decorator cannot be re-enabled."
    explanation: "Nothing raises. The change is simply invisible, because the decision was made when the decorator was applied."
explanation: "A boolean decides at definition time. To have a change of `LOGGING` respected at runtime, pass a callable that reads it, `enabled=lambda: LOGGING`, and accept a FunctionWrapper and a check on every call in exchange."
```

## Where this goes next

Every decorator in this collection so far has been applied to one
kind of thing at a time. The next workshop writes one decorator that
does the right thing on a function, an instance method, a class
method, a static method and a class, using the values of `instance`
and `wrapped` to tell them apart, then stacks decorators and walks the
resulting chain with wrapt's tools for doing so.

**One decorator for everything** is next.

Press Finish below to move on.

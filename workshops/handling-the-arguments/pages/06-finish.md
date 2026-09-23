---
title: What you know now
requires: [quiz:why-not-starred]
---

# What you know now

`args` and `kwargs` arrive as a tuple and a dict, exactly as the
caller wrote them, and wrapt never binds them into the wrapper's
signature, so a decorated function can have a parameter called
`wrapped` or `instance` without a collision. A wrapper written with
`*args, **kwargs` is wrong, and fails on the first call.

When a wrapper wants an argument by name:

- `args[0]` is the first positional argument, which is not the first
  parameter when the caller used a keyword, and not the instance,
  which is in `instance`.

- A nested function with the parameters you care about and `*_args,
  **_kwargs` for the rest, called with `*args, **kwargs`, has Python
  bind the one argument you need, whichever way it was passed.

- `inspect.signature(wrapped).bind(*args, **kwargs)` with
  `apply_defaults()` gives every argument by name, and needs no
  special case for methods because `wrapped` is already bound.

The return value is the wrapper's to decide: forward it, transform it,
wrap it, or replace it.

```{quiz}
:id: why-not-starred
:title: Why the four plain names
:shuffle: true
question: "Why does a wrapt wrapper receive the call's arguments as two plain parameters, args and kwargs, rather than as *args, **kwargs?"
options:
  - text: "Because a tuple and a dict are faster to pass than spread arguments."
    explanation: "Speed is not the reason. The call is spread out again inside the wrapper anyway, when it calls wrapped(*args, **kwargs)."
  - text: "So the wrapper can modify the arguments before forwarding them."
    explanation: "A wrapper can build a new tuple or dict either way. The shape is about what wrapt does before the wrapper runs, not what the wrapper does after."
  - text: "So the call's arguments are never bound to the wrapper's parameters, and a decorated function can have parameters named wrapped or instance."
    correct: true
  - text: "Because wrapt.decorator needs to inspect the arguments to find the instance."
    explanation: "The instance comes from the descriptor protocol, when the method is looked up, not from the arguments of the call."
explanation: "If wrapt spread the call into the wrapper's signature, a keyword argument called wrapped or instance would land on the wrapper's own parameter of that name. Handing over the tuple and the dict untouched keeps the two sets of names apart."
```

## Where this goes next

Every wrapper so far has forgotten everything between calls. The next
workshop gives a decorator state, a count or a cache that outlives one
call, and shows where wrapt keeps it so that the decorated function
can reach it, which is the pattern the rest of these workshops are
built on.

**Keeping state** is next.

Press Finish below to move on.

---
title: What you know now
requires: [quiz:why-the-class]
---

# What you know now

Python resolves a special method on the type, never on the instance,
so `proxy.__getitem__ = f` stores a function that nothing will call.
A special method is intercepted by defining it on a
`BaseObjectProxy` subclass, doing the work, and calling the target's
version through `self.__wrapped__`, with the proxy's own state under
`_self_` names. Everything not defined still passes through, so only
the behaviour that changes is written.

```{quiz}
:id: why-the-class
:title: Why the class
:shuffle: true
question: "Why did `plain.__getitem__ = hijacked` leave `plain[\"currency\"]` unchanged?"
options:
  - text: "The proxy forwarded the assignment to the dictionary, which ignored it."
    explanation: "The assignment stayed on the proxy: the cell showed `__getitem__` in its `__self_dict__`. It was stored, and never looked at."
  - text: "Python looks a special method up on the type of the object, so an attribute on the instance is never consulted."
    correct: true
  - text: "wrapt blocks assignment to names beginning with double underscores."
    explanation: "Nothing was blocked. The function was stored, and `plain.__getitem__(...)` as an ordinary attribute lookup found it. Subscripting simply does not look there."
  - text: "`__getitem__` on a proxy is read only."
    explanation: "It was assigned without error. The rule at work is Python's own lookup of special methods, and it applies to every object, proxy or not."
explanation: "`plain[key]` is `type(plain).__getitem__(plain, key)`. The lookup goes to the class, and the only way to change it is to define the method on a class, which for a proxy means a subclass."
```

## Where this goes next

One special method never came up, because it is not on
`BaseObjectProxy` at all: `__call__`. A proxy over a function needs
it, wrapt ships proxies that add it, and one of them is a partial
that keeps the function's signature. That is the next workshop.

**Calling through a proxy** is next.

Press Finish below to move on.

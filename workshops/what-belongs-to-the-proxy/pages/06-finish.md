---
title: What you know now
requires: [quiz:where-it-lands]
---

# What you know now

A proxy has two dictionaries. Plain assignment through it fills the
target's, which `vars()` and `__dict__` show, so a proxy that only
stands in leaks nothing. State the proxy keeps to itself is named
with the `_self_` prefix, which its `__setattr__` stores on the proxy,
and `__self_dict__` is the proxy's own dictionary for reading it
back. A method defined on the proxy class is found before anything is
forwarded, and calls through `self.__wrapped__` to intercept an
ordinary method.

When the proxy's own attribute must carry a name other code chose,
`__self_setattr__` stores it on the proxy under that name, and works
on every Python version wrapt supports.

```{quiz}
:id: where-it-lands
:title: Where each one lands
:shuffle: true
question: "A `BaseObjectProxy` subclass runs `self.total = 0`, `self._self_total = 0` and `self.__self_setattr__(\"total\", 0)`. Which of these ends up on the target?"
options:
  - text: "Only `self.total = 0`."
    correct: true
  - text: "`self.total = 0` and `self.__self_setattr__(\"total\", 0)`, since both use the plain name."
    explanation: "`__self_setattr__` stores on the proxy whatever the name. It exists precisely so that a plain name can stay on the proxy."
  - text: "All three; the proxy forwards every assignment."
    explanation: "A `_self_` name is stored on the proxy by its `__setattr__`, and `__self_setattr__` bypasses forwarding altogether. Only the plain assignment is forwarded."
  - text: "None of them; a subclass's `__init__` writes to the proxy."
    explanation: "Where an assignment lands depends on the name, not on where the code runs. A plain name in `__init__` is forwarded like one anywhere else."
explanation: "Plain assignment is forwarded. The `_self_` prefix and `__self_setattr__` both store on the proxy, one by naming convention and one by bypassing the convention."
```

## Where this goes next

`Counted` intercepted `buy` by defining a method of the same name. A
special method such as `__getitem__` or `__enter__` is intercepted
the same way, on the class, and setting one on an instance does
nothing, for a reason worth seeing. That is the next workshop.

**Intercepting special methods** is next.

Press Finish below to move on.

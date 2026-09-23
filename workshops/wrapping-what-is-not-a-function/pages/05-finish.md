---
title: What you know now
requires: [quiz:self-prefix]
---

# What you know now

`wrapt.wrap_object(target, name, factory, args=(), kwargs=None)`
calls the factory with the original and the extra arguments, installs
what it returns, and returns it as the handle. The factory is usually
a `BaseObjectProxy` subclass, and three things about a proxy are
enough to write one:

- **`self.__wrapped__`** is the original, stored by
  `super().__init__(wrapped)`.

- **Names starting with `_self_`** are the proxy's own; every other
  attribute is forwarded to the original, `__class__` included, so
  `isinstance` and `==` see the original and only `type()` sees the
  proxy.

- **A special method** is intercepted only if the proxy class
  defines it. Most, `__getitem__` among them, pass through
  otherwise. The few whose presence says what an object is,
  `__call__`, `__iter__` and their kin, are not on the base class
  and exist only if the proxy defines them.

Beneath every wrap function are `resolve_path`, which finds the
parent, the name and the real original, and `apply_patch`, which
sets the replacement. A replacement that is not a wrapt proxy has no
handle.

```{quiz}
:id: self-prefix
:title: Where the attribute lands
:shuffle: true
question: "A proxy's `__init__` does `self.reads = []` instead of `self._self_reads = []`. What happens when the proxy wraps a dictionary?"
options:
  - text: "It works the same: the underscore prefix is a naming convention only."
    explanation: "The prefix is what BaseObjectProxy checks to decide whether an attribute is the proxy's own. Without it, the assignment is forwarded."
  - text: "The assignment is forwarded to the dictionary, which has no such attribute to set, so it raises AttributeError."
    correct: true
  - text: "The list is stored on the proxy but is invisible to the proxy's own methods."
    explanation: "Nothing is stored on the proxy. Forwarded assignment goes to the wrapped object, or fails there."
  - text: "It creates a key named reads in the dictionary."
    explanation: "Attribute assignment and item assignment are different things. The forwarded setattr on a dict raises; it does not become d[\"reads\"]."
explanation: "BaseObjectProxy forwards attribute assignment as well as lookup, the way a FunctionWrapper forwarded an attribute set on the decorated function to the original in the Decorators with wrapt workshops. The _self_ prefix is how a proxy keeps state of its own."
```

## Where this goes next

Proxies are a subject of their own: what passes through and what
does not, the special methods in full, lazy proxies that import on
first use, and the function wrappers built on them. A further set
of workshops on them is planned for this repository.

The next workshop is about a value no wrap function so far can
reach, because it lives on each object rather than on the class: the
attribute `__init__` sets.

**Patching instance attributes** is next.

Press Finish below to move on.

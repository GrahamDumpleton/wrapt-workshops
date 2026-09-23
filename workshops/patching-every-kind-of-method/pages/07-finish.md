---
title: What you know now
requires: [quiz:instance-for-init]
---

# What you know now

`wrapt.wrap_function_wrapper(target, "dotted.path", wrapper)` patches
any function or method, and the wrapper's `instance` says what it
landed on:

- **An instance method, or a dunder method**, gives the object the
  call was bound to, with `args` holding only what the caller passed.
  On `__init__` it is the new object before its body has run.

- **A class method** gives the class the call came through.

- **A static method, or a plain function**, gives `None`.

- **A method of a nested class**, reached through a dotted path, gives
  the nested object, since the patch lands where the method is
  defined.

The target can be a module, a class, one object, or a module's name
as a string, which is imported if it has to be. And `wrapped` is
already bound, so the wrapper never passes `instance` itself.

```{quiz}
:id: instance-for-init
:title: The wrapper on __init__
:shuffle: true
question: "A wrapper is patched onto `Shop.__init__` and reads `instance.name` before calling `wrapped(*args, **kwargs)`. What happens on `Shop(\"Market\")`?"
options:
  - text: "It reads \"Market\", because Python sets the attributes from the arguments before calling __init__."
    explanation: "Python creates the object empty and calls __init__ to fill it. The arguments are still only arguments until the body of __init__ runs."
  - text: "It raises AttributeError, because the wrapper runs before the body of __init__ has set name."
    correct: true
  - text: "instance is None, since the object does not exist yet when __init__ is called."
    explanation: "The object exists, made by __new__, and __init__ is bound to it like any instance method. It is empty, not absent."
  - text: "It reads the name of the previous shop, since instance is the class until __init__ returns."
    explanation: "instance is the new object, not the class. A class method would give the class; __init__ is an instance method."
explanation: "The wrapper on __init__ receives the freshly made object as instance, with nothing set on it yet. A wrapper that wants what the constructor set reads it after wrapped(*args, **kwargs) returns."
```

## Where this goes next

Every patch here was a call to `wrap_function_wrapper`. The next
workshop spells the same patch three ways, as that call, as a
decorator on the wrapper that installs the patch when its module is
imported, and as a reusable wrapper made once and applied anywhere,
and says when each reads best.

**Three ways to spell a patch** is next.

Press Finish below to move on.

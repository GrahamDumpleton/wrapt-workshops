---
title: What you know now
requires: [quiz:which-base]
---

# What you know now

`BaseObjectProxy` never claims a special method its target might not
have, so a proxy over a list, a function or a generator needs
`__iter__`, `__call__` or `__next__` added by a subclass.
`AutoObjectProxy` reads the target at construction and generates a
class carrying the methods that target has, so one class fits every
kind of target, at the cost of a new class for every proxy made.

```{quiz}
:id: which-base
:title: Which base
:shuffle: true
question: "A function is given an object of unknown kind, a file, a list or a callback, and must return a proxy over it that the caller can use as they would the original. Which base?"
options:
  - text: "`AutoObjectProxy`, since the special methods needed depend on what arrives."
    correct: true
  - text: "`BaseObjectProxy`, with `__iter__`, `__call__` and `__next__` all defined on a subclass."
    explanation: "Defining all three makes the proxy claim to be iterable and callable whatever it wraps. A proxy over a callback would say it is iterable, and code checking for that would be misled."
  - text: "`BaseObjectProxy` as it is, since it forwards everything."
    explanation: "It forwards everything except the special methods that say what an object is. A proxy over the list would not iterate and one over the callback would not call."
  - text: "`CallableObjectProxy`, since a callback is the hardest case."
    explanation: "That solves the callback and makes the file and the list claim to be callable too. Only a proxy shaped by its target gets all three right."
explanation: "When the target's kind is decided at runtime, `AutoObjectProxy` gives the proxy the methods that target has and no others, and the cost of the generated class is the price of that."
```

## Where this goes next

`AutoObjectProxy` reads its target when it is made, which means the
target has to exist by then. The next workshop is about a proxy whose
target does not, built on this one: a callback in place of an object,
run the first time the proxy is used, and the import that happens
only when it is needed.

**Wrapping what does not exist yet** is next.

Press Finish below to move on.

---
title: What you know now
requires: [quiz:why-isinstance]
---

# What you know now

A delegating class with `__getattr__` forwards attribute reads and
nothing else. `isinstance` reads `__class__` and finds the delegate's.
Special methods are looked up on the type, so `len`, `==`, `str` and
the rest go around `__getattr__` and find nothing. An assignment
lands on the delegate and the original never sees it.

`wrapt.BaseObjectProxy` forwards attribute reads, attribute writes
and `__class__`, and defines the special methods to call the wrapped
object's, so to the code that receives it the proxy is the object.
The original is on `__wrapped__`. `type()` still names the proxy and
`repr()` still announces it, which is deliberate.

```{quiz}
:id: why-isinstance
:title: Why isinstance says yes
:shuffle: true
question: "Why is `isinstance(proxy, Shop)` true for the wrapt proxy when it was false for the delegate?"
options:
  - text: "The proxy forwards the `__class__` attribute to the shop, and `isinstance` reads `__class__`."
    correct: true
  - text: "`BaseObjectProxy` is a subclass of `Shop`."
    explanation: "It is not, and it cannot be: it is one class that wraps anything. `type(proxy)` shows its real type has nothing to do with `Shop`."
  - text: "wrapt registers the proxy as a virtual subclass of every class it wraps."
    explanation: "Nothing is registered. `__class__` is an attribute, attributes are forwarded, and that is the whole mechanism."
  - text: "`isinstance` follows `__wrapped__` the way `inspect.signature` does."
    explanation: "`isinstance` knows nothing about `__wrapped__`. It asks for `__class__`, and the proxy hands the question to the shop."
explanation: "`__class__` is an attribute like any other, and the proxy forwards it. `type()` reads the real type directly and is the one question that is not fooled."
```

## Where this goes next

`type(proxy)` named the proxy, `proxy is shop` would be false, and
`iter(proxy)` would fail even though the proxy has a length. The
next workshop is about the lines a transparent proxy cannot cross,
and the one it draws on purpose.

**What does not pass through** is next.

Press Finish below to move on.

---
title: On the instance
requires: [verify:on-the-instance]
---

# On the instance

The obvious way to intercept `__getitem__` on one proxy is to set it
on that proxy. Try it.

```{cell-insert}
:id: insert-on-the-instance
:path: {{ notebook }}
:tags: [on-the-instance]
:run: true
plain = wrapt.BaseObjectProxy(settings)

def hijacked(key):
    return "hijacked"

plain.__getitem__ = hijacked

value = plain["currency"]
landed = "__getitem__" in plain.__self_dict__

print("plain['currency']        :", value)
print("stored on the proxy      :", landed)
print("the function, if asked   :", plain.__getitem__("currency"))
```

The assignment landed on the proxy, not on the dictionary, and it
changed nothing. `plain["currency"]` still reads the dictionary,
while `plain.__getitem__(...)`, looked up as an ordinary attribute,
finds the function.

That is not a proxy rule. For any object, Python resolves a special
method by looking on the type, skipping the instance entirely, so
`plain[key]` becomes `type(plain).__getitem__(plain, key)` and the
attribute stored on the instance is never consulted. The same is
true of `len`, `with`, `+=` and the rest. A special method has to be
defined on a class, which for a proxy means a subclass.

```{hint}
:title: Why it landed on the proxy
An earlier workshop said a plain name assigned through a proxy is
forwarded to the target. A name the proxy's own class already
defines is the one exception, and `BaseObjectProxy` defines
`__getitem__` along with nearly every other special method. For such
a name the proxy's `__setattr__` steps aside and lets ordinary Python
assignment happen, which is what you would get on any object: the
function goes into the instance's own dictionary, here
`__self_dict__`, and the type is still what `[]` consults. Nothing
about the result is wrapt's doing: set `__getitem__` on an instance
of any class that defines one and the class's method still answers
`[]`, with the function sitting unused in the instance dictionary.
The exception is also why the cell did not raise: a dictionary
cannot take attributes, so a forwarded assignment would have failed
before there was anything to see.
```

```{verify}
:id: on-the-instance
:label: Setting __getitem__ on the instance changed nothing
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed on-the-instance
value == "USD" and landed
```

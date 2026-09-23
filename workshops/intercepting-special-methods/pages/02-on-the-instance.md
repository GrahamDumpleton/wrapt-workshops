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

The assignment happened, and it changed nothing. `plain["currency"]`
still reads the dictionary, while `plain.__getitem__(...)`, looked up
as an ordinary attribute, finds the function.

That is not a proxy rule. For any object, Python resolves a special
method by looking on the type, skipping the instance entirely, so
`plain[key]` becomes `type(plain).__getitem__(plain, key)` and the
attribute stored on the instance is never consulted. The same is
true of `len`, `with`, `+=` and the rest. A special method has to be
defined on a class, which for a proxy means a subclass.

```{verify}
:id: on-the-instance
:label: Setting __getitem__ on the instance changed nothing
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed on-the-instance
value == "USD" and landed
```

---
title: Two objects
requires: [quiz:predict-type, verify:two-objects]
---

# Two objects

The proxy and the shop are two objects, and Python has questions
that are about the object rather than about what it does. Predict
one before the cell runs.

```{quiz}
:id: predict-type
:title: Predict type()
:shuffle: true
question: "What does `type(proxy)` return?"
options:
  - text: "`Shop`, because the proxy forwards everything."
    explanation: "`type()` does not read an attribute. It reads the object's real type directly, and nothing a proxy does can change that."
  - text: "The proxy class, `wrapt.BaseObjectProxy`."
    correct: true
  - text: "`object`, because the proxy defines almost nothing of its own."
    explanation: "The proxy is an instance of `BaseObjectProxy`, which is a class of its own; it defines a great deal, all of it forwarding."
explanation: "`type()` reads the real type and names the proxy. `__class__` is an attribute, and the proxy forwards it, which is what `isinstance` reads."
```

```{cell-insert}
:id: insert-two-objects
:path: {{ notebook }}
:tags: [two-objects]
:run: true
same_object = proxy is shop
proxy_type = type(proxy)
proxy_class = proxy.__class__

print("proxy is shop      :", same_object)
print("same id            :", id(proxy) == id(shop))
print("type(proxy)        :", proxy_type)
print("proxy.__class__    :", proxy_class)
print("type(proxy) is Shop:", proxy_type is Shop)
print("isinstance Shop    :", isinstance(proxy, Shop))
```

`is` and `id()` are false and different: they are about which object
this is, and it is not the shop. `type()` reads the real type without
asking the object, so it names the proxy class. `__class__` is an
attribute, attributes are forwarded, and `isinstance` reads
`__class__`, which is why it says yes.

So a check written as `type(x) is Shop` sees a proxy for what it is,
and `isinstance(x, Shop)` does not. Code that wants to be fooled
should use `isinstance`, and code that must tell the difference has
`type()` and `__wrapped__`.

```{verify}
:id: two-objects
:label: Identity and type() name the proxy, __class__ names the shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed two-objects
same_object is False and proxy_type is wrapt.BaseObjectProxy and proxy_class is Shop
```

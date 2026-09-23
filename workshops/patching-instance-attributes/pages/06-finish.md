---
title: What you know now
requires: [quiz:where-the-proxy-lives]
---

# What you know now

`wrapt.wrap_object_attribute(module, "Class.attribute", factory)`
patches a value that lives on each instance:

- **It installs a descriptor on the class**, an `AttributeWrapper`,
  which on every read fetches the instance's own value and passes it
  through the factory. The instances are untouched, so shops made
  before and after are covered alike, and so is a value set again.

- **It composes with what was there.** A property keeps computing
  beneath it, a class default is the fallback when an instance has no
  value, and a second application stacks over the first. Reading the
  attribute on the class with nothing to fall back on gives
  `wrapt.MISSING`.

- **The descriptor is the handle.** `unwrap_object` restores what was
  beneath it or deletes the slot the wrap created.

```{quiz}
:id: where-the-proxy-lives
:title: Where the proxy lives
:shuffle: true
question: "After `wrap_object_attribute(\"shop.cart\", \"Shop.name\", Tagged)`, a shop does `self.name = \"Shop 2\"` in one of its methods. What does the next `shop.name` return?"
options:
  - text: "\"Shop 2\" as a plain string, since assigning replaced the proxy in the shop's dictionary."
    explanation: "There was never a proxy in the shop's dictionary. The proxy is made on each read, by the descriptor on the class."
  - text: "Tagged(\"Shop 2\"): the write stored the plain string on the instance and the read passed the new value through the factory."
    correct: true
  - text: "Tagged(\"Corner Store\"): the descriptor cached the value it wrapped the first time."
    explanation: "Nothing is cached. Every read fetches the current value from the instance and wraps it afresh."
  - text: "It raises, because a wrapped attribute is read only."
    explanation: "The descriptor delegates writes to the instance's dictionary, or to a property's setter, so assignment works as before."
explanation: "The proxy lives nowhere: it is made on each read. The instance holds the plain value, the descriptor on the class wraps whatever it finds there, and a write goes to the instance as it always did."
```

## Where this goes next

That was the last mechanism. The final workshop puts them to work:
a wrapper that counts and times a library's calls, a registry that
installs each patch once and removes them all, a version check before
patching, and deferral so it applies whether the library is imported
before or after. Then where wrapture takes that.

**Patching to observe** is next.

Press Finish below to move on.

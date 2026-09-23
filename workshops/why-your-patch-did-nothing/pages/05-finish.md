---
title: What you know now
requires: [quiz:which-patch-reaches]
---

# What you know now

A patch rebinds one name in one namespace. Every reference copied
out of that name before the patch still points at the original:

- **`from module import name`** copies the reference into the
  importing module when it loads, so a patch on `module.name` made
  afterwards never reaches that importer. Patch the alias too, at
  the module where the name is looked up, or patch before the
  importer loads.

- **`import module` and `module.name` at the call** looks the name
  up each time, so the patch is seen.

- **A method called through an object** is looked up on the class at
  call time, so a patch on `Class.method` reaches every object and
  every module holding the class.

- **A bound method saved in a variable**, a callback registered
  early, a default argument, is a reference taken before the patch,
  and sees nothing.

```{quiz}
:id: which-patch-reaches
:title: Which patch reaches the caller
:shuffle: true
question: "A module `app` did `from shop.cart import Shop` at import time and calls `Shop(\"x\").buy(item)` in a request handler. You patch `Shop.buy` on `shop.cart` after `app` was imported. Does the handler see the patch?"
options:
  - text: "No: app took its reference to Shop before the patch, so the patch on shop.cart does not reach it."
    explanation: "app holds the class, and the class is the same object shop.cart holds. The patch changed an attribute of that class, and the handler looks buy up on it at call time."
  - text: "Yes: app holds the class, the patch is an attribute of the class, and buy is looked up on the class at call time."
    correct: true
  - text: "Only for shops created after the patch, since existing objects keep their own copy of buy."
    explanation: "Objects hold no copy of their methods. Every call looks buy up on the class, so shops made before the patch see it too."
  - text: "Only if app also did from shop.cart import buy."
    explanation: "There is no module level buy to import. The method lives on the class, and the class is what app imported."
explanation: "from shop.cart import Shop copies a reference to the class, not to its methods. The patch changed Shop.buy on that one class object, and a call through any shop looks buy up on it at call time, so the patch is seen wherever the class is held."
```

## Where this goes next

The way round a `from` import that has already happened is to be
there first: patch the original module before its importers load,
whatever order the program imports things in. The next workshop is
about doing that without knowing the order, with a patch that waits
for its module to be imported.

**Patching before the import** is next.

Press Finish below to move on.

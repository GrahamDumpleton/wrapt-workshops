---
title: What you know now
requires: [quiz:install-twice]
---

# What you know now

An instrumentation tool, from the mechanisms of the workshops before
this one:

- **A wrapper with state**, a class whose `__call__` has the wrapper
  signature, installed by `wrap_function_wrapper` on every target,
  recording in `finally` so a call that raised is timed too.

- **A registry** from target and name to handle, so each patch is
  installed once and `uninstrument` can remove them all, with
  `missing_ok=True` on the way out.

- **A version check** before patching, so the patches apply only to
  the library they were written against, and say so otherwise.

- **A post import hook**, so the same registration works whether the
  library is imported before the tool or after.

```{quiz}
:id: install-twice
:title: Installing twice
:shuffle: true
question: "A tool without a registry calls `wrap_function_wrapper(shop.cart, \"Shop.buy\", recorder)` at start-up, and a second copy of the tool, loaded by mistake, does the same. What does the recorder see for one call of `buy`?"
options:
  - text: "One record: wrapt notices the same wrapper is already installed and does not install it again."
    explanation: "wrapt installs what it is asked to install. Two calls make two wrappers, one over the other; knowing what is already there is the registry's job."
  - text: "Two records, one from each wrapper, so every count and total is doubled."
    correct: true
  - text: "One record, since the recorder is the same object and only appends once per call."
    explanation: "The recorder's __call__ runs once per wrapper, and there are two wrappers on the chain, so it appends twice."
  - text: "It raises, because a target cannot hold two wrappers with the same wrapper function."
    explanation: "Stacking is allowed and useful; two parties patching the same target is normal. The mistake is one party doing it twice, and only the party can know."
explanation: "Two wrappers on the chain means the recorder runs twice per call. is_wrapped_by with the handle, or a registry that keeps the handle, is how a tool finds out it has already patched a target."
```

## Where this goes next

That is the end of **Monkey patching with wrapt**. You can patch any
function, method or attribute of code you did not write, correctly
on every kind of method, before or after its module is imported,
for a block or for good, and take it out again with nothing left
behind.

A tool that does this at scale, with recording, a lifecycle for
every patch, and somewhere to send the events, is what
[wrapture](https://wrapture.readthedocs.io) is, and the
[wrapture workshops](https://github.com/GrahamDumpleton/wrapture-workshops)
teach it from the first binding to tracing a web application. And
`BaseObjectProxy`, which the eighth workshop only introduced, has a
set of workshops of its own planned for this repository.

Press Finish below.

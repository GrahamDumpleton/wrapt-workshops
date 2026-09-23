---
title: What you know now
requires: [quiz:why-refuse]
---

# What you know now

`BaseObjectProxy` defines `__reduce__`, `__copy__` and
`__deepcopy__` to raise `NotImplementedError`, because rebuilding a
proxy means rebuilding the target and whatever the subclass keeps
under its `_self_` names, and only the subclass knows the second. A
subclass defines the three, each returning a new proxy from the
target and its own state, and pickle, copy, deepcopy and every
serialiser that follows the pickle protocol then work.

```{quiz}
:id: why-refuse
:title: Why the base class refuses
:shuffle: true
question: "Why does `BaseObjectProxy` raise from `__reduce__` rather than pickling the target and wrapping it again on the way back?"
options:
  - text: "Because a subclass may keep state of its own under `_self_` names, and a proxy rebuilt from the target alone would come back without it."
    correct: true
  - text: "Because targets cannot be pickled through a proxy."
    explanation: "The subclass on these pages pickled its target through `__reduce__` without difficulty. The target was never the problem."
  - text: "Because `pickle` cannot import the proxy class."
    explanation: "It imported `StatsProxy` from the notebook and rebuilt it. Any class `pickle` can find by name works, proxy or not."
  - text: "Because the C extension has no `__reduce__`."
    explanation: "Both implementations define it, and define it to raise. The refusal is a decision, not a gap."
explanation: "The base class cannot see what a subclass added, and a silent guess would produce a proxy that came back different. Raising puts the decision where the knowledge is."
```

## Where this goes next

That is the end of **Object proxies with wrapt**. Press Finish below
for where to go from here.

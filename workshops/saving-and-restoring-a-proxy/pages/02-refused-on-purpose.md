---
title: Refused on purpose
requires: [verify:refused]
---

# Refused on purpose

A proxy over the statistics with a label of its own, and three
attempts to duplicate it.

```{cell-insert}
:id: insert-refused
:path: {{ notebook }}
:tags: [refused]
:run: true
class StatsProxy(wrapt.BaseObjectProxy):
    def __init__(self, wrapped, label):
        super().__init__(wrapped)
        self._self_label = label

totals = StatsProxy(stats, "totals")

refusals = {}

for name, attempt in [("pickle", pickle.dumps), ("copy", copy.copy), ("deepcopy", copy.deepcopy)]:
    try:
        attempt(totals)
        refusals[name] = None
    except NotImplementedError as exc:
        refusals[name] = f"NotImplementedError: {exc}"

for name, message in refusals.items():
    print(f"{name:>8}: {message}")
```

Three refusals, each naming the method to define. `pickle` asks an
object for `__reduce__`, `copy.copy` for `__copy__` and
`copy.deepcopy` for `__deepcopy__`, and `BaseObjectProxy` defines
all three to raise.

It could have guessed. Pickling the target and wrapping it again on
the way back would work for a bare proxy. But `totals` has a label
the target knows nothing about, and a guess that dropped it would be
a proxy that came back silently different. So the base class
declines, and the subclass, which knows what it keeps, says how.

```{verify}
:id: refused
:label: pickle, copy and deepcopy all raised NotImplementedError
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed refused
len(refusals) == 3 and all(message is not None for message in refusals.values())
```

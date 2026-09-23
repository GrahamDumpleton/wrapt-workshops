---
title: Reduce
requires: [verify:reduce]
---

# Reduce

`__reduce__` returns the callable that rebuilds the object and the
arguments to call it with. For this proxy that is the class itself,
the target and the label, which is everything there is.

```{cell-insert}
:id: insert-reduce
:path: {{ notebook }}
:tags: [reduce]
:run: true
class StatsProxy(wrapt.BaseObjectProxy):
    def __init__(self, wrapped, label):
        super().__init__(wrapped)
        self._self_label = label

    def __reduce__(self):
        return (StatsProxy, (self.__wrapped__, self._self_label))

totals = StatsProxy(stats, "totals")

restored = pickle.loads(pickle.dumps(totals))

print("type     :", type(restored).__name__)
print("label    :", restored._self_label)
print("wrapped  :", restored.__wrapped__)
print("same dict:", restored.__wrapped__ is stats)
print("equal    :", restored == totals)
```

The round trip brings back a `StatsProxy` with its label and a
dictionary equal to the original, and not the same dictionary,
because `pickle` rebuilt that too, as it would have for the
dictionary alone. Both halves of the proxy survived because
`__reduce__` named both.

Nothing here is specific to `pickle`. `dill` and the other
serialisers that follow the pickle protocol ask the same question
and get the same answer, so defining `__reduce__` once covers them.

```{verify}
:id: reduce
:label: The proxy round tripped through pickle with its label and its target
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed reduce
type(restored).__name__ == "StatsProxy" and restored._self_label == "totals" and restored.__wrapped__ == stats and restored.__wrapped__ is not stats
```

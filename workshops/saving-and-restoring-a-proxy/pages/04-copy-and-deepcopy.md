---
title: Copy and deepcopy
requires: [verify:copies]
---

# Copy and deepcopy

The two copies follow the same idea, each building a new proxy from
a copy of the target and the same label. `__copy__` copies the
target shallowly and `__deepcopy__` deeply, passing the `memo`
dictionary on so that shared objects inside the target are copied
once.

```{cell-insert}
:id: insert-copies
:path: {{ notebook }}
:tags: [copies]
:run: true
class StatsProxy(wrapt.BaseObjectProxy):
    def __init__(self, wrapped, label):
        super().__init__(wrapped)
        self._self_label = label

    def __reduce__(self):
        return (StatsProxy, (self.__wrapped__, self._self_label))

    def __copy__(self):
        return StatsProxy(copy.copy(self.__wrapped__), self._self_label)

    def __deepcopy__(self, memo):
        return StatsProxy(copy.deepcopy(self.__wrapped__, memo), self._self_label)

totals = StatsProxy(stats, "totals")

shallow = copy.copy(totals)
deep = copy.deepcopy(totals)

shallow["fig"] = 5

print("shallow label :", shallow._self_label, "wrapped:", shallow.__wrapped__)
print("deep label    :", deep._self_label, "wrapped:", deep.__wrapped__)
print("original      :", stats)
print("new dicts     :", shallow.__wrapped__ is not stats, deep.__wrapped__ is not stats)
```

Each copy is a `StatsProxy` with the label, over a dictionary of
its own, so adding to the shallow copy left the original alone. This
is the complete proxy: what it forwards, the base class handles;
what it keeps, the three methods know how to save.

```{verify}
:id: copies
:label: Both copies kept the label and got a dictionary of their own
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed copies
shallow._self_label == "totals" and deep._self_label == "totals" and shallow.__wrapped__ is not stats and deep.__wrapped__ is not stats and "fig" not in stats and shallow["fig"] == 5
```

---
title: Two more
requires: [verify:timed-lock, verify:tracked-list]
---

# Two more

The same shape on two other special methods. First a lock whose
proxy records how long each `with` block held it.

```{cell-insert}
:id: insert-timed-lock
:path: {{ notebook }}
:tags: [timed-lock]
:run: true
class Timed(wrapt.BaseObjectProxy):
    def __init__(self, wrapped):
        super().__init__(wrapped)
        self._self_held = []

    def __enter__(self):
        self._self_start = time.perf_counter()
        return self.__wrapped__.__enter__()

    def __exit__(self, *exc):
        self._self_held.append(time.perf_counter() - self._self_start)
        return self.__wrapped__.__exit__(*exc)

lock = Timed(threading.Lock())

with lock:
    time.sleep(0.02)

print("held for   :", [f"{held:.3f}s" for held in lock._self_held])
print("locked now :", lock.locked())
```

`__enter__` notes the time and lets the real lock acquire;
`__exit__` records the duration and lets the real lock release, and
`lock.locked()` passes through to say it did.

Now a list whose proxy records what `+=` appended. This is the
in-place operator from the previous workshop, seen from the proxy's
side: the method returns `self`, so the name stays bound to the
proxy.

```{cell-insert}
:id: insert-tracked-list
:path: {{ notebook }}
:tags: [tracked-list]
:run: true
class Tracked(wrapt.BaseObjectProxy):
    def __init__(self, wrapped):
        super().__init__(wrapped)
        self._self_added = []

    def __iadd__(self, other):
        self._self_added.append(list(other))
        self.__wrapped__ += other
        return self

stock = ["apple"]
tracked = Tracked(stock)

tracked += ["pear", "fig"]

print("stock         :", stock)
print("added         :", tracked._self_added)
print("still a proxy :", isinstance(tracked, wrapt.BaseObjectProxy))
print("still the list:", tracked.__wrapped__ is stock)
```

The list was extended in place, the proxy noted what was added, and
`tracked` is still the proxy over the same list.

```{verify}
:id: timed-lock
:label: The lock proxy recorded one held duration and released the lock
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed timed-lock
len(lock._self_held) == 1 and lock._self_held[0] >= 0.01 and not lock.locked()
```

```{verify}
:id: tracked-list
:label: The list proxy recorded the addition and stayed a proxy over the same list
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed tracked-list
stock == ["apple", "pear", "fig"] and tracked._self_added == [["pear", "fig"]] and isinstance(tracked, wrapt.BaseObjectProxy) and tracked.__wrapped__ is stock
```

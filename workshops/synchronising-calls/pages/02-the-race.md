---
title: The race
requires: [verify:race-fixed]
---

# The race

`bump` reads the counter, spins for a moment, and writes back one
more. Four threads each bump it two thousand times, so the total
should be eight thousand.

```{cell-insert}
:id: insert-race
:path: {{ notebook }}
:tags: [race]
:run: true
def bump(times):
    for _ in range(times):
        value = counter["total"]
        for _ in range(20):
            pass
        counter["total"] = value + 1

counter["total"] = 0
elapsed = run_threads((bump, (2000,)), (bump, (2000,)), (bump, (2000,)), (bump, (2000,)))
racy_total = counter["total"]

print(f"{racy_total} of 8000 in {elapsed}ms")
```

It comes up short, by a lot. Whenever Python switches threads between
the read and the write, the thread that resumes writes a stale value
over whatever the others did in the meantime, and those updates are
lost.

The standard library fix is a `threading.Lock` held around the read
and the write, kept in a global or on an object where every caller
can find it.

```{cell-insert}
:id: insert-stdlib
:path: {{ notebook }}
:tags: [stdlib]
:run: true
lock = threading.Lock()

def bump_with_lock(times):
    for _ in range(times):
        with lock:
            value = counter["total"]
            for _ in range(20):
                pass
            counter["total"] = value + 1

counter["total"] = 0
elapsed = run_threads((bump_with_lock, (2000,)), (bump_with_lock, (2000,)))

print(f"{counter['total']} of 4000 in {elapsed}ms")
```

`wrapt.synchronized` does the same for a whole function, with a lock
it makes on the first call and keeps on the function.

```{cell-insert}
:id: insert-synchronized
:path: {{ notebook }}
:tags: [synchronized]
:run: true
@wrapt.synchronized
def bump(times):
    for _ in range(times):
        value = counter["total"]
        for _ in range(20):
            pass
        counter["total"] = value + 1

counter["total"] = 0
elapsed = run_threads((bump, (2000,)), (bump, (2000,)), (bump, (2000,)), (bump, (2000,)))
safe_total = counter["total"]

print(f"{safe_total} of 8000 in {elapsed}ms")
print("the lock:", vars(bump.__wrapped__))
```

Eight thousand exactly, and the last line shows where the lock went:
`_synchronized_lock`, an `RLock`, in the original function's own
dictionary. Because the lock is around the whole call, each thread
runs its two thousand bumps to the end before the next starts, which
is coarser than the hand written version and the reason it cost about
the same.

```{verify}
:id: race-fixed
:label: The race lost updates and synchronized lost none
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed synchronized
racy_total < 8000 and safe_total == 8000
```

```{hint}
:title: If the racy total came out at 8000
The race is real but not certain: every switch has to land between a
read and a write to lose an update. If no update was lost, run the
first cell on this page again. If it keeps coming out exact, check
that the setup cell ran, since it is the setup cell that makes the
switches frequent enough to see.
```

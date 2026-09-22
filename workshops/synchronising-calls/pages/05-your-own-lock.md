---
title: Your own lock
requires: [verify:explicit-locks]
---

# Your own lock

Two things remain. `deposit_twice`, defined on the previous page, is
a synchronised method that calls another synchronised method on the
same object, and it works.

```{cell-insert}
:id: insert-reentrant
:path: {{ notebook }}
:tags: [reentrant]
:run: true
vault.deposit_twice(5)

print("balance:", vault.balance)
print("lock   :", type(vars(vault)["_synchronized_lock"]).__name__)
```

It works because the automatic lock is an `RLock`, which a thread that
already holds it can take again. A plain `threading.Lock` in the same
place would stop dead on the inner call, waiting for a lock its own
thread holds, so a synchronised method calling another on the same
object, or a synchronised function calling itself, is safe only with
a reentrant lock.

Which matters when supplying your own. `wrapt.synchronized(lock)`
takes any object with `acquire()` and `release()` and uses it instead
of making one, in both forms. That is how two unrelated functions
share a lock, and how a semaphore limits how many callers run at
once.

```{cell-insert}
:id: insert-explicit
:path: {{ notebook }}
:tags: [explicit]
:run: true
ledger_lock = threading.RLock()

@wrapt.synchronized(ledger_lock)
def read_ledger():
    time.sleep(0.02)

@wrapt.synchronized(ledger_lock)
def write_ledger():
    time.sleep(0.02)

shared_ms = run_threads((read_ledger, ()), (write_ledger, ()))

at_most_two = threading.Semaphore(2)

@wrapt.synchronized(at_most_two)
def download(item):
    time.sleep(0.02)

limited_ms = run_threads((download, ("apple",)), (download, ("pear",)), (download, ("fig",)))

print(f"read and write on one lock: {shared_ms}ms")
print(f"three downloads, two at a time: {limited_ms}ms")
```

The read and the write share `ledger_lock` and take turns. The three
downloads share a semaphore of two, so two run together and the third
waits: forty milliseconds rather than sixty or twenty. A
`threading.Lock` would work in `ledger_lock`'s place, at the cost of
reentrancy.

```{verify}
:id: explicit-locks
:label: The reentrant call worked and the explicit lock and semaphore serialised
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed explicit
vault.balance == 11 and shared_ms >= 30 and limited_ms >= 30
```

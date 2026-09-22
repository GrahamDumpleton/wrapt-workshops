---
title: The context manager form
requires: [verify:shared-with-block]
---

# The context manager form

Not every critical section is a whole method. `wrapt.synchronized`
is also a context manager: `with wrapt.synchronized(obj):` takes the
lock that belongs to `obj`, making one if there is none yet. Given
`self`, that is the same lock a decorated method on the same object
uses, so a block in an undecorated method and a decorated method
exclude each other.

```{cell-insert}
:id: insert-vault
:path: {{ notebook }}
:tags: [vault]
:run: true
class Vault:
    def __init__(self):
        self.balance = 0

    @wrapt.synchronized
    def deposit(self, amount):
        balance = self.balance
        time.sleep(0.02)
        self.balance = balance + amount

    def audit(self):
        with wrapt.synchronized(self):
            time.sleep(0.02)
            return self.balance

    @wrapt.synchronized
    def deposit_twice(self, amount):
        self.deposit(amount)
        self.deposit(amount)

vault = Vault()

mixed_ms = run_threads((vault.deposit, (1,)), (vault.audit, ()))

print(f"deposit and audit together: {mixed_ms}ms")
print("locks on the vault        :", [name for name in vars(vault) if name.endswith("_lock")])
```

Forty milliseconds, not twenty: the audit waited for the deposit, or
the other way round, because both took the one `_synchronized_lock`
on the vault. There is one lock attribute, made by whichever ran
first and found by the other.

Any object that accepts attribute assignment can be the context,
including one that exists only to be a lock: two functions that both
do `with wrapt.synchronized(shared):` on the same `shared` object are
mutually exclusive, and the object need not be involved in either.
Built-in immutable types, an `int` or a `str` say, do not accept
attributes and cannot be used.

```{verify}
:id: shared-with-block
:label: The block and the decorated method excluded each other
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed vault
mixed_ms >= 30 and vault.balance == 1
```

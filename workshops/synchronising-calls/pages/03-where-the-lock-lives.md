---
title: Where the lock lives
requires: [verify:per-instance-lock, verify:locks-found]
---

# Where the lock lives

On a method, the lock has to be somewhere that every call on the same
object finds and calls on other objects do not. `wrapt.synchronized`
uses `instance` for that, when there is one, and `wrapped` when there
is not:

- an instance method locks on the instance, so each object has a lock
  of its own,

- a class method locks on the class,

- a decorated class locks on the class, one lock for every call of
  it,

- a static method and a plain function lock on the function.

`deposit` sleeps in the middle of its read and write, so two deposits
on one account take twice as long as one, and two on different
accounts do not.

```{cell-insert}
:id: insert-accounts
:path: {{ notebook }}
:tags: [accounts]
:run: true
class Account:
    def __init__(self, name):
        self.name = name
        self.balance = 0

    @wrapt.synchronized
    def deposit(self, amount):
        balance = self.balance
        time.sleep(0.02)
        self.balance = balance + amount

    @wrapt.synchronized
    @classmethod
    def open(cls, name):
        return cls(name)

    @wrapt.synchronized
    @staticmethod
    def rate():
        return 0.01

@wrapt.synchronized
class Ledger:
    pass

alpha = Account("alpha")
beta = Account("beta")

same_instance_ms = run_threads((alpha.deposit, (1,)), (alpha.deposit, (1,)))
two_instances_ms = run_threads((alpha.deposit, (1,)), (beta.deposit, (1,)))

print(f"two deposits on alpha       : {same_instance_ms}ms, balance {alpha.balance}")
print(f"one on alpha and one on beta: {two_instances_ms}ms")
```

Around forty milliseconds for the two on one account, since the
second waits for the first, and around twenty for one on each, since
they run at the same time. The balance is right either way. Without
the lock, two deposits on one account would have read the same
balance and one would have been lost, like the counter.

```{verify}
:id: per-instance-lock
:label: Calls on one account were serialised and on two ran in parallel
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed accounts
same_instance_ms > two_instances_ms and alpha.balance == 3 and beta.balance == 1
```

## Reading the locks

The locks are attributes named `_synchronized_lock`, and each can be
read off the object it was put on.

```{cell-insert}
:id: insert-locks
:path: {{ notebook }}
:tags: [locks]
:run: true
Account.open("gamma")
Account.rate()
Ledger()

instance_lock = vars(alpha)["_synchronized_lock"]

print("on alpha            :", type(instance_lock).__name__)
print("on beta, the same?  :", vars(beta)["_synchronized_lock"] is instance_lock)
print("on the class        :", "_synchronized_lock" in vars(Account))
print("on the static method:", "_synchronized_lock" in vars(Account.rate.__wrapped__))
print("on Ledger           :", "_synchronized_lock" in vars(Ledger.__wrapped__))
```

Each account has an `RLock` of its own. The class method put one on
`Account`, the static method put one on its own function, and calling
`Ledger` put one on the `Ledger` class. The locks are made on the
first call, so `beta` had none until it was used.

That is the whole answer to where the lock should be kept: with the
thing it protects, found through `instance`, with no field to declare
and no `__init__` to touch.

```{verify}
:id: locks-found
:label: The locks are on the instances, the class, the function and Ledger
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed locks
type(instance_lock).__name__ == "RLock" and vars(beta)["_synchronized_lock"] is not instance_lock and "_synchronized_lock" in vars(Account) and "_synchronized_lock" in vars(Ledger.__wrapped__)
```

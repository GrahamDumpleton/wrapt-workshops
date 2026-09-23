---
title: Operators
requires: [quiz:predict-inplace, verify:operators]
---

# Operators

Wrap a number, and add to it. The proxy forwards `__add__`, so the
addition happens on the number. The question is what comes back.

```{quiz}
:id: predict-inplace
:title: Predict the in-place operator
:shuffle: true
question: "After `n = wrapt.BaseObjectProxy(1)` and then `n += 1`, what is `type(n)`?"
options:
  - text: "`int`, because `n + 1` is an `int` and `n += 1` is the same thing spelled shorter."
    explanation: "For an immutable target `n += 1` cannot change the number in place, so the proxy makes the new number and hands it back wrapped, which keeps `n` a proxy."
  - text: "The proxy class, holding `2`."
    correct: true
  - text: "It raises, because a proxy over an `int` has no `__iadd__`."
    explanation: "`BaseObjectProxy` defines `__iadd__`. When the target has no in-place form of its own, the proxy computes the result and wraps it."
explanation: "A plain operator returns whatever the target returns, unwrapped. An in-place operator on a proxy keeps the proxy: the target is updated in place if it can be, and replaced with a wrapped result if it cannot."
```

```{cell-insert}
:id: insert-operators
:path: {{ notebook }}
:tags: [operators]
:run: true
n = wrapt.BaseObjectProxy(1)

total = n + 1

print("n + 1        :", total, type(total))
print("1 + n        :", 1 + n, type(1 + n))

n += 1

print("after n += 1 :", n, type(n))
print("n.__class__  :", n.__class__)
print("n == 2       :", n == 2)
```

`n + 1` is a plain `int`. The proxy asked the number to add, the
number returned a new number, and the proxy passed that back as it
was: the result of an operation belongs to the target, and wrapping
it would be a guess about what the caller wanted.

`n += 1` is different. Python calls `__iadd__` and rebinds `n` to
whatever it returns, and the proxy returns itself, holding the new
number, so the name `n` stays a proxy. For a mutable target such as a
list the target is changed in place; for an immutable one the proxy
swaps in the new value. Either way the proxy survives the statement,
which is what a caller who did not know there was a proxy would
expect.

```{verify}
:id: operators
:label: A plain operator returns an int, an in-place one keeps the proxy
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed operators
type(total) is int and type(n) is wrapt.BaseObjectProxy and n == 2
```

```{hint}
:title: The class the in-place result is wrapped in
When an in-place operator has to wrap a new value, the proxy asks its
`__object_proxy__` attribute for the class to use, which is the base
proxy class by default. A subclass can point it at itself so that its
own behaviour survives `+=`, which is a detail for a proxy that
overrides operators, and nothing here needs it.
```

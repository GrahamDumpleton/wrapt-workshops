---
title: The line drawn on purpose
requires: [verify:drawn-on-purpose]
---

# The line drawn on purpose

Everything so far was a line the proxy could not cross. This one it
chooses not to. Wrap a list and iterate over it, wrap a function and
call it.

```{cell-insert}
:id: insert-drawn-on-purpose
:path: {{ notebook }}
:tags: [drawn-on-purpose]
:run: true
try:
    iter(wrapt.BaseObjectProxy([1, 2]))
    iter_error = None
except TypeError as exc:
    iter_error = f"TypeError: {exc}"

items = list(wrapt.ObjectProxy([1, 2]))

try:
    wrapt.BaseObjectProxy(fetch_price)("apple")
    call_error = None
except TypeError as exc:
    call_error = f"TypeError: {exc}"

print("iter over BaseObjectProxy:", iter_error)
print("iter over ObjectProxy    :", items)
print("call a BaseObjectProxy   :", call_error)
```

Both fail, and the proxy has a length, an `__eq__` and a hundred
other forwarded methods. `__iter__` and `__call__` are left off
`BaseObjectProxy` deliberately. Python decides whether an object is
iterable or callable by whether its type has the method, and so does
`isinstance` against `collections.abc.Iterable` and `Callable`. A
base class that wraps anything must not carry them, or a proxy over
a number would claim to be iterable and a proxy over a dictionary
would claim to be callable. A proxy that wraps something iterable
defines `__iter__` itself, and one that wraps something callable
defines `__call__`, or uses one of the classes wrapt ships that do,
which a later workshop covers.

The middle line shows `wrapt.ObjectProxy`, which does forward
`__iter__`. It is the older class, kept so that code written before
wrapt 2.0.0 keeps working, and that is its only difference from
`BaseObjectProxy`. New proxies derive from `BaseObjectProxy`.

```{verify}
:id: drawn-on-purpose
:label: BaseObjectProxy refuses iteration and calling, ObjectProxy iterates
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed drawn-on-purpose
iter_error is not None and items == [1, 2] and call_error is not None
```

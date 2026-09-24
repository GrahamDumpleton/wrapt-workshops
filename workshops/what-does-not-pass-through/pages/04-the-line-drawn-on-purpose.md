---
title: The line drawn on purpose
requires: [verify:drawn-on-purpose]
---

# The line drawn on purpose

Everything so far was a line the proxy could not cross. This one it
chooses not to. Wrap a list and iterate over it, wrap a function and
call it, then wrap the list in a proxy that says it can be iterated.

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

try:
    wrapt.BaseObjectProxy(fetch_price)("apple")
    call_error = None
except TypeError as exc:
    call_error = f"TypeError: {exc}"

class IterableProxy(wrapt.BaseObjectProxy):
    def __iter__(self):
        return iter(self.__wrapped__)

items = list(IterableProxy([1, 2]))

print("iter over BaseObjectProxy:", iter_error)
print("call a BaseObjectProxy   :", call_error)
print("iter over IterableProxy  :", items)
```

The first two fail, and the proxy has a length, an `__eq__` and a
hundred other forwarded methods. `__iter__` and `__call__` are left
off `BaseObjectProxy` deliberately. Python decides whether an object
is iterable or callable by whether its type has the method, and so
does `isinstance` against `collections.abc.Iterable` and `Callable`.
A base class that wraps anything must not carry them, or a proxy over
a number would claim to be iterable and a proxy over a dictionary
would claim to be callable.

The third line is the answer. A proxy that wraps something iterable
defines `__iter__` itself, in three lines, forwarding to
`__wrapped__`, and now the claim is true for that class alone. One
that wraps something callable defines `__call__` the same way, or
uses one of the classes wrapt ships that do, which a later workshop
covers.

```{hint}
:title: If you see wrapt.ObjectProxy
`wrapt.ObjectProxy` is the older name, kept only so that code
written before wrapt 2.0.0 keeps working. Its one difference from
`BaseObjectProxy` is that it forwards `__iter__` unconditionally,
which was a mistake in the original design: every instance claims
to be iterable, whatever it wraps. Do not use it and do not derive
from it. For wrapt 2.0.0 and later, use `wrapt.BaseObjectProxy` and
define `__iter__` yourself, as above.
```

```{verify}
:id: drawn-on-purpose
:label: BaseObjectProxy refuses iteration and calling, and a subclass with __iter__ iterates
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed drawn-on-purpose
iter_error is not None and call_error is not None and items == [1, 2]
```

---
title: A call counter
requires: [verify:call-counter]
---

# A call counter

Override `__call__` on a subclass and every call goes through your
code first. This one counts, then calls the function through
`self.__wrapped__`.

```{cell-insert}
:id: insert-call-counter
:path: {{ notebook }}
:tags: [call-counter]
:run: true
class Counting(wrapt.CallableObjectProxy):
    def __init__(self, wrapped):
        super().__init__(wrapped)
        self._self_calls = 0

    def __call__(self, *args, **kwargs):
        self._self_calls += 1
        return self.__wrapped__(*args, **kwargs)

counted = Counting(fetch_price)

counted("apple")
counted("pear", currency="EUR")

print("calls     :", counted._self_calls)
print("__name__  :", counted.__name__)
print("__doc__   :", counted.__doc__)
print("signature :", inspect.signature(counted))
print("a function:", isinstance(counted, types.FunctionType))
```

Two calls counted, and every question about the function answered
by the function: the name, the docstring, the real signature and
`isinstance` against `FunctionType`. Nothing was copied onto the
proxy, so nothing can go stale, and the count lives under a `_self_`
name where the function never sees it.

This is a decorator with state, written as a proxy. The
`@wrapt.decorator` form in **Decorators with wrapt** builds on the
same base, with a `FunctionWrapper` in place of `CallableObjectProxy`,
which the next workshop opens up.

```{verify}
:id: call-counter
:label: The counter saw two calls and still answers for the function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed call-counter
counted._self_calls == 2 and counted.__name__ == "fetch_price" and str(inspect.signature(counted)) == "(item, currency='USD')" and isinstance(counted, types.FunctionType)
```

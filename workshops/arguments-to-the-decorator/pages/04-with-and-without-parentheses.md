---
title: With and without parentheses
requires: [verify:dual-use-works]
---

# With and without parentheses

The decorator workshops ended their arguments workshop on a decorator
that works both as `@debug` and as `@debug(prefix="###")`. The
standard library answer is to test what was passed, `callable(arg)`,
which cannot tell a bare use from a callable setting, or to make the
settings keyword only and check the first parameter against `None`.

wrapt takes the second answer and finishes it. The first parameter is
`wrapped=None`, the settings are keyword only, and when `wrapped` is
missing the function returns `wrapt.partial` of itself with the
settings filled in, to be called with the function when it arrives.

```{cell-insert}
:id: insert-dual
:path: {{ notebook }}
:tags: [dual]
:run: true
def debug(wrapped=None, *, prefix=">>>"):
    if wrapped is None:
        return wrapt.partial(debug, prefix=prefix)

    @wrapt.decorator
    def wrapper(wrapped, instance, args, kwargs):
        return f"{prefix} {wrapped(*args, **kwargs)}"

    return wrapper(wrapped)

@debug
def bare():
    return "no parentheses"

@debug(prefix="###")
def configured():
    return "with parentheses"

bare_result = bare()
configured_result = configured()

print(bare_result)
print(configured_result)
```

Both work. Follow each through:

- `@debug` hands `debug` the function, so `wrapped` is `bare`, the
  `if` is skipped, and the last line applies the wrapt decorator to
  it and returns the result. `wrapper(wrapped)` is what `@wrapper`
  above the `def` would have done.

- `@debug(prefix="###")` calls `debug` with no function, so `wrapped`
  is `None` and the partial comes back. Python applies the partial to
  `configured`, which calls `debug(configured, prefix="###")`, and
  now the first path runs.

Look at what the partial is, and then at the case the standard
library version could not get right.

```{cell-insert}
:id: insert-partial
:path: {{ notebook }}
:tags: [partial]
:run: true
pending = debug(prefix="###")

print("type     :", type(pending).__name__)
print("name     :", pending.__name__)
print("signature:", inspect.signature(pending))
print()

shout = debug(str.upper)
print(shout("no guessing"))
```

`wrapt.partial` returns a `PartialCallableObjectProxy`, a
`functools.partial` built on wrapt's proxy, so the pending decorator
still has `debug`'s name, docstring and signature rather than a
partial's. And `debug(str.upper)` is not ambiguous: a callable passed
positionally can only be the function, because every setting is
keyword only, so `str.upper` is decorated and the prefixed shout is
the result. Nothing tested whether the argument was callable.

```{verify}
:id: dual-use-works
:label: Both forms work and the pending decorator is a PartialCallableObjectProxy
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed partial
bare_result == ">>> no parentheses" and configured_result == "### with parentheses" and type(pending).__name__ == "PartialCallableObjectProxy" and pending.__name__ == "debug"
```

```{hint}
:title: functools.partial would also work
The `if` could return `functools.partial(debug, prefix=prefix)` and
both forms would still decorate correctly. What changes is what the
pending decorator looks like from outside: a `functools.partial` has
no `__name__` and its own docstring, so a tool reading it sees a
partial, not `debug`. `wrapt.partial` keeps it introspectable, which
is the same reason the decorated function is a proxy rather than a
copy.
```

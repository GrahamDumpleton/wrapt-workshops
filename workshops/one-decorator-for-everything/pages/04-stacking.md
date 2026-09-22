---
title: Stacking
requires: [verify:stacked]
---

# Stacking

Decorators stack, wrapt ones like any others: the one nearest the
function is applied first and runs innermost. Two wrapt decorators
that each record when they enter and leave show the order.

```{cell-insert}
:id: insert-stack
:path: {{ notebook }}
:tags: [stack]
:run: true
@wrapt.decorator
def outer(wrapped, instance, args, kwargs):
    log.append("outer in")
    try:
        return wrapped(*args, **kwargs)
    finally:
        log.append("outer out")

@wrapt.decorator
def inner(wrapped, instance, args, kwargs):
    log.append("inner in")
    try:
        return wrapped(*args, **kwargs)
    finally:
        log.append("inner out")

@outer
@inner
def greet(name):
    log.append("greet")
    return f"Hello, {name}"

log.clear()
greet("Ada")

print(log)
print("signature:", inspect.signature(greet))
```

`outer` wraps a `FunctionWrapper`, the one `inner` made, and its
`wrapped` argument is that wrapper rather than `greet` itself. Nothing
in `outer` needs to know, because a `FunctionWrapper` is callable and
answers every question the way the original would, so the signature
is still `greet`'s through both layers.

## With a closure in the stack

A wrapt decorator can also sit above or below a closure decorator
built with `functools.wraps`. Here a `functools.wraps` closure goes
between the two wrapt decorators.

```{cell-insert}
:id: insert-mixed
:path: {{ notebook }}
:tags: [mixed]
:run: true
def stdlib(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        log.append("stdlib in")
        try:
            return func(*args, **kwargs)
        finally:
            log.append("stdlib out")

    return wrapper

@outer
@stdlib
@inner
def greet(name):
    log.append("greet")
    return f"Hello, {name}"

log.clear()
greet("Ada")

print(log)
print("greet is a               :", type(greet).__name__)
print("greet.__wrapped__ is a   :", type(greet.__wrapped__).__name__)
print("one level further        :", type(greet.__wrapped__.__wrapped__).__name__)
print("signature                :", inspect.signature(greet))
print("without following        :", inspect.signature(greet, follow_wrapped=False))
```

Three layers, in and out in order. Each layer's `__wrapped__` is the
layer below: the outer `FunctionWrapper` holds the closure, the
closure's `__wrapped__` attribute, set by `functools.wraps`, points at
the inner `FunctionWrapper`, and that holds `greet`. `inspect`
follows the whole chain, so the signature is right. Asked not to
follow it, `inspect` reads the outer proxy, which forwards to the
closure, and the closure's own signature is `(*args, **kwargs)`: the
closure in the middle is the one layer that cannot answer for itself.

```{verify}
:id: stacked
:label: Three layers ran in order around greet
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed mixed
log == ["outer in", "stdlib in", "inner in", "greet", "inner out", "stdlib out", "outer out"] and type(greet.__wrapped__).__name__ == "function"
```

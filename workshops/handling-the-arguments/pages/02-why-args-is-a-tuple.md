---
title: Why args is a tuple
requires: [verify:signature-fixed]
---

# Why args is a tuple

A closure wrapper is written `def wrapper(*args, **kwargs)`, and the
stars are what collect the call's arguments. It is natural to write
the wrapt wrapper the same way. See what happens.

```{cell-insert}
:id: insert-wrong
:path: {{ notebook }}
:tags: [wrong]
:run: true
@wrapt.decorator
def wrong(wrapped, instance, *args, **kwargs):
    return wrapped(*args, **kwargs)

@wrong
def double(x):
    return x * 2

try:
    double(21)
    problem = "no error"
except TypeError as error:
    problem = str(error)

print(problem)
```

`double() takes 1 positional argument but 2 were given`. wrapt always
calls the wrapper with four positional values: the function, the
instance, the tuple and the dict. Written with stars, `*args`
collected the tuple and the dict as two items, and `wrapped(*args)`
passed both of them to `double`. The wrapper's signature is always the
four plain names, and wrapt never spreads the call's arguments into
it.

The reason is names. If wrapt bound the call's keyword arguments into
the wrapper's parameters, a decorated function with a parameter called
`wrapped` or `instance` would collide with the wrapper's own. Handing
the arguments over untouched means a decorated function can have any
parameter names at all.

```{cell-insert}
:id: insert-collision
:path: {{ notebook }}
:tags: [collision]
:run: true
@pass_through
def attach(wrapped, instance):
    return f"attached {wrapped} to {instance}"

attached = attach(wrapped="a label", instance="a box")
print(attached)
```

Both keyword arguments reached `attach`, because they travelled in
`kwargs` and never met the wrapper's parameters of the same name.

The price of that guarantee is the subject of the next two pages: when
a wrapper does want an argument by name, it has to bind the arguments
itself.

```{verify}
:id: signature-fixed
:label: The starred wrapper failed and the plain one kept the names apart
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed collision
"positional" in problem and attached == "attached a label to a box"
```

```{hint}
:title: The closure version has a cousin of this problem
A closure wrapper written `def wrapper(self, *args, **kwargs)` to reach
the instance collides in its own way: a keyword argument called `self`
lands on the wrapper's parameter, and the decorator only works on
methods. wrapt's four fixed names, with `instance` separate and the
arguments untouched, avoid both.
```

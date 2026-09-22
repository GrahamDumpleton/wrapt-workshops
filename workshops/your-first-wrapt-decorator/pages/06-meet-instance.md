---
title: Meet instance
requires: [verify:instance-is-none]
---

# Meet instance

One of the four arguments has done nothing so far. `instance` is the
object the wrapped function was bound to when it was called. A plain
function is bound to nothing, so print it and see what arrives.

```{cell-insert}
:id: insert-instance
:path: {{ notebook }}
:tags: [instance]
:run: true
seen = {}

@wrapt.decorator
def show_instance(wrapped, instance, args, kwargs):
    seen["instance"] = instance
    print("instance:", instance)
    return wrapped(*args, **kwargs)

@show_instance
def greet(name):
    return f"Hello, {name}!"

greeting = greet("Alice")
print(greeting)
```

`None`. For a plain function it always is, and a decorator written
only for plain functions can ignore it.

It stops being `None` the moment the decorator lands on a method, and
what it holds then, and what that means for `args`, is the reason
wrapt has the signature it has. That is the next workshop.

```{verify}
:id: instance-is-none
:label: instance is None for a plain function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed instance
"instance" in seen and seen["instance"] is None and greeting == "Hello, Alice!"
```

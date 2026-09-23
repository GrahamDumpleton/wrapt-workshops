---
title: A callback in place of an object
requires: [verify:callback-runs-once]
---

# A callback in place of an object

Give `LazyObjectProxy` a function that makes the shop, and watch
when it runs.

```{cell-insert}
:id: insert-callback
:path: {{ notebook }}
:tags: [callback]
:run: true
made = []

def make_shop():
    made.append("made")
    print("make_shop ran")
    return Shop("lazy")

lazy = wrapt.LazyObjectProxy(make_shop)
print("after construction:", made)

name = lazy.name
print("after first use   :", made)

name_again = lazy.name
print("after second use  :", made)
print("name              :", name)
```

Nothing happens at construction. The first attribute read runs the
callback, and the proxy keeps what it returned as its target from
then on, so the second read finds it there and the callback is not
run again. Everything else is the proxy you know: `lazy` is a
`Shop` to `isinstance`, and assignment through it lands on the shop
the callback made.

```{verify}
:id: callback-runs-once
:label: The callback ran once, on first use
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed callback
made == ["made"] and name == "lazy" and isinstance(lazy, Shop)
```

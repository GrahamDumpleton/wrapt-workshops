---
title: A class per instance
requires: [verify:class-per-instance]
---

# A class per instance

Special methods live on a type, and the type is what an
`AutoObjectProxy` has to shape. Look at the types of two of them,
and time making one against making a base proxy.

```{cell-insert}
:id: insert-class-per-instance
:path: {{ notebook }}
:tags: [class-per-instance]
:run: true
first = wrapt.AutoObjectProxy([1])
second = wrapt.AutoObjectProxy([2])

same_class = type(first) is type(second)

print("same class:", same_class)
print("bases     :", [cls.__name__ for cls in type(first).__mro__[:3]])

base_time = timeit.timeit(lambda: wrapt.BaseObjectProxy(PRICES), number=1000)
auto_time = timeit.timeit(lambda: wrapt.AutoObjectProxy(PRICES), number=1000)
ratio = auto_time / base_time

print(f"BaseObjectProxy: {base_time:.4f}s for 1000")
print(f"AutoObjectProxy: {auto_time:.4f}s for 1000")
print(f"ratio          : {ratio:.0f}x")
```

Two proxies over two lists have two different classes. Each
`AutoObjectProxy` generates a subclass for its own instance, with the
special methods its target turned out to have, and that is where the
time goes: making a class is far more work than making an instance,
and the ratio printed is the price of not knowing the target's kind
in advance.

So the rule. When you know what you are wrapping, derive from
`BaseObjectProxy` and write the special methods it needs, which is
cheap and says exactly what the proxy is. When you do not, or when
the same code wraps many kinds of thing, `AutoObjectProxy` fits
whatever it is given, and the cost is paid once per proxy made.

```{verify}
:id: class-per-instance
:label: Each auto proxy has its own class and costs more to make
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed class-per-instance
not same_class and ratio > 5
```

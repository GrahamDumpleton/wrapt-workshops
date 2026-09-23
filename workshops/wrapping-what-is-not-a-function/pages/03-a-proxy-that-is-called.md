---
title: A proxy that is called
requires: [verify:counting-proxy]
---

# A proxy that is called

The same shape wraps a function, with `__call__` as the special
method. `__call__` is one of the methods the base class leaves out,
so `Counting` must define it for the proxy to be callable at all,
and it counts each call under a label. The label comes
from the factory's arguments: `wrap_object` passes anything in `args`
and `kwargs` to the factory after the original.

```{cell-insert}
:id: insert-counting
:path: {{ notebook }}
:tags: [counting]
:run: true
class Counting(wrapt.BaseObjectProxy):
    def __init__(self, wrapped, label):
        super().__init__(wrapped)
        self._self_label = label
        self._self_count = 0

    def __call__(self, *args, **kwargs):
        self._self_count += 1
        return self.__wrapped__(*args, **kwargs)

counter = wrapt.wrap_object(shop.pricing, "fetch_price", Counting, args=("prices",))

shop.pricing.fetch_price("apple")
shop.pricing.fetch_price("pear")

print("label :", counter._self_label)
print("count :", counter._self_count)
print("name  :", shop.pricing.fetch_price.__name__)
print("chain :", chain(shop.pricing, "fetch_price"))

wrapt.unwrap_object(shop.pricing, "fetch_price", counter)

print("after :", chain(shop.pricing, "fetch_price"))
```

Two calls counted, and the function's name still comes through the
proxy. The cell takes the patch out with the handle `wrap_object`
returned, as the lifecycle workshop taught, and the same
`unwrap_object` works because the factory returned a wrapt proxy.

This is a plain `BaseObjectProxy` with a `__call__`, not a
`FunctionWrapper`, and the difference matters on a class: a
`FunctionWrapper` is a descriptor and binds like a method, a
`BaseObjectProxy` is not and does not. For patching functions and
methods, `wrap_function_wrapper` and the `FunctionWrapper` it
installs are the right tool; `wrap_object` with a proxy of your own
is for everything else, or for a callable where you want to hold
state on the proxy and never need binding.

```{verify}
:id: counting-proxy
:label: The counting proxy took its label from args and counted two calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed counting
counter._self_label == "prices" and counter._self_count == 2 and chain(shop.pricing, "fetch_price") == ["function"]
```

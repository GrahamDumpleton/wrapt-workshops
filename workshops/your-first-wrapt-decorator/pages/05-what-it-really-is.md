---
title: What it really is
requires: [verify:proxy-seen]
---

# What it really is

Ask what `fetch_price` is, in the two ways Python offers, and compare
the answers.

```{cell-insert}
:id: insert-type
:path: {{ notebook }}
:tags: [type]
:run: true
print("type(fetch_price)     :", type(fetch_price))
print("fetch_price.__class__ :", fetch_price.__class__)
print("a FunctionWrapper?    :", isinstance(fetch_price, wrapt.FunctionWrapper))
print("a function?           :", isinstance(fetch_price, types.FunctionType))
print("the original          :", fetch_price.__wrapped__)
print("the same object?      :", fetch_price is fetch_price.__wrapped__)
```

`type()` tells the truth: `fetch_price` is a `FunctionWrapper`, an
object wrapt built holding two things, the original function and your
wrapper function. `__class__` says `function`, and `isinstance` agrees,
because `__class__` is an attribute, and attributes are forwarded.

That is the whole mechanism. A `FunctionWrapper` is a proxy. Any
attribute it does not define itself is looked up on the original
function it holds, so `__name__`, `__doc__`, `__code__` and
`__class__` are all the original's, not copies of them. Calling it
runs your wrapper with the original as `wrapped`. That is why nothing
had to be repaired: there was never a second function with a name and
a signature of its own to hide.

Because nothing is copied, nothing can go stale. Set an attribute on
the original after decoration and read it through the wrapper.

```{cell-insert}
:id: insert-forwarding
:path: {{ notebook }}
:tags: [forwarding]
:run: true
fetch_price.__wrapped__.category = "fruit"

print("through the wrapper:", fetch_price.category)
```

A copy taken at decoration time would not have it. The proxy asks the
original, and the original has it.

```{verify}
:id: proxy-seen
:label: fetch_price is a FunctionWrapper that forwards to the original
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed forwarding
type(fetch_price).__name__ == "FunctionWrapper" and fetch_price.category == "fruit"
```

```{hint}
:title: About the module name in the type
`type()` prints `_wrappers.FunctionWrapper`, from the C extension wrapt
installs on the platforms it has wheels for. The same class exists in
pure Python and behaves the same, so nothing here depends on which
one loaded; `wrapt.FunctionWrapper` names whichever it is.
```

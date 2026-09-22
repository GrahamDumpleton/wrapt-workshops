---
title: Walking the chain
requires: [verify:chain-walked]
---

# Walking the chain

Following `__wrapped__` by hand works for three layers and gets old.
wrapt has two functions for it. `wrapt.wrapper_chain()` yields the
object it is given and then each `__wrapped__` in turn, outermost
first, ending at the innermost object. `wrapt.unwrapped()` returns
that innermost object directly. Both see through wrapt wrappers,
`functools.wraps` closures, and anything else that sets
`__wrapped__`.

```{cell-insert}
:id: insert-chain
:path: {{ notebook }}
:tags: [chain]
:run: true
chain = [type(layer).__name__ for layer in wrapt.wrapper_chain(greet)]
original = wrapt.unwrapped(greet)

print("chain   :", chain)
print("original:", original, original.__qualname__)
print("the same as inspect.unwrap?", original is inspect.unwrap(greet))
```

Four objects: the outer wrapper, the closure, the inner wrapper and
`greet` itself. `inspect.unwrap()` in the standard library gets to the
same place, and wrapt's functions add a chain to look at on the way,
a traversal limit so a broken proxy cannot loop forever, and the
same behaviour on every object that honours the convention.

Two things to know. The chain is walked by reading `__wrapped__`,
which on a lazy object proxy causes it to materialise. And the chain
is what a monkey patching tool uses to find a particular wrapper and
remove it from the middle of a stack, which wrapt's `find_wrapper()`
and `unwrap_object()` do, and which belongs to another collection.

```{verify}
:id: chain-walked
:label: The chain has four layers and ends at the original greet
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed chain
chain == ["FunctionWrapper", "function", "FunctionWrapper", "function"] and original.__qualname__ == "greet" and original is inspect.unwrap(greet)
```

```{hint}
:title: About the chain's second entry
The closure is a `function`, and so is the original `greet`, so the
chain reads as two wrappers and two functions. Only the last is not a
wrapper: the closure is a function that happens to carry a
`__wrapped__` attribute, which is all `functools.wraps` gives it.
```

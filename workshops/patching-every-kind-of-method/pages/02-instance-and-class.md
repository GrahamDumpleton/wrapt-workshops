---
title: The object and the class
requires: [quiz:predict-instance, verify:instance-and-class]
---

# The object and the class

`Shop.buy` is an instance method and `Shop.empty` is a class method.
Patch both with `notify` and call each. Before the cell runs, predict
what `instance` holds each time.

```{quiz}
:id: predict-instance
:title: Predict instance
:shuffle: true
question: "After patching `Shop.buy` and `Shop.empty`, what does the wrapper's `instance` hold for `corner.buy(\"apple\")` and then for `Shop.empty()`?"
options:
  - text: "The shop, then None: a class method has no instance to bind to."
    explanation: "A class method binds to the class, and wrapt passes that as instance. None is for static methods and plain functions."
  - text: "None both times, because a patch is applied from outside the class and cannot know what the call was bound to."
    explanation: "The FunctionWrapper wrapt installs is a descriptor, exactly like the one @wrapt.decorator installs, so lookup binds it and the wrapper knows."
  - text: "The shop, then the class Shop."
    correct: true
  - text: "The shop both times, since empty is looked up through the class the shop belongs to."
    explanation: "empty is called as Shop.empty(), through the class, and a class method is bound to the class whichever way it is reached."
explanation: "A patched method is bound on lookup the same way a decorated one is. corner.buy binds to corner, and Shop.empty, a class method, binds to Shop, so those are what the wrapper receives as instance."
```

Now the cell. It keeps the two records `notify` makes under names of
their own, so the check can read them without calling anything again.

```{cell-insert}
:id: insert-instance-and-class
:path: {{ notebook }}
:tags: [instance-and-class]
:run: true
wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", notify)
wrapt.wrap_function_wrapper(shop.cart, "Shop.empty", notify)

corner.buy("apple")
fresh = Shop.empty()

buy_seen = seen[-2]
empty_seen = seen[-1]

print()
print("buy   saw instance:", buy_seen[1], "with args", buy_seen[2])
print("empty saw instance:", empty_seen[1], "with args", empty_seen[2])
```

`buy` saw the shop and `("apple",)`: the shop is in `instance`, not
at the front of `args`, because `wrapped` arrived already bound to it.
`empty` saw the class `Shop` and no arguments at all. Both are what a
decorator would have seen, and **What instance tells you**, in the
**Decorators with wrapt** workshops, is where that table comes from.
The difference here is only that the wrapper arrived from outside,
after the class was made.

```{verify}
:id: instance-and-class
:label: The wrapper saw the shop for buy and the class for empty
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed instance-and-class
buy_seen[0] == "buy" and buy_seen[1] is corner and buy_seen[2] == ("apple",) and empty_seen[0] == "empty" and empty_seen[1] is Shop and empty_seen[2] == () and type(fresh) is Shop
```

```{hint}
:title: Why the shop is not in args
A `FunctionWrapper` is a descriptor. Looking `buy` up on `corner`
binds it, the bound result knows which object it was bound to, and
that object is what the wrapper receives as `instance`, with `args`
holding only what the caller passed. A call through the class,
`Shop.buy(corner, "apple")`, is recognised and normalised to the same
thing.
```

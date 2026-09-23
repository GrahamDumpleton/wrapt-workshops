---
title: Never pass instance yourself
requires: [verify:never-pass-instance]
---

# Never pass instance yourself

Every wrapper so far called `wrapped(*args, **kwargs)`. A wrapper
that has just been handed `instance` and knows `buy` is a method may
be tempted to pass it along, the way a plain function would need
`self`. `wrong` does exactly that, on `Shop.buy`, over the patch
already there.

```{cell-insert}
:id: insert-never-pass-instance
:path: {{ notebook }}
:tags: [never-pass-instance]
:run: true
def wrong(wrapped, instance, args, kwargs):
    return wrapped(instance, *args, **kwargs)

wrong_handle = wrapt.wrap_function_wrapper(shop.cart, "Shop.buy", wrong)

try:
    corner.buy("fig")
    problem = "no error"
except TypeError as error:
    problem = str(error)

print("problem:", problem)

wrapt.unwrap_object(shop.cart, "Shop.buy", wrong_handle)

print("after  :", corner.buy("fig"))
```

`buy` was given three positional arguments and takes two. By the time
the wrapper runs, `wrapped` is bound to the shop and will pass it as
`self` by itself, so the wrapper's `instance` is for reading, never
for passing. The same rule applies to a class method, where `wrapped`
is bound to the class, and to a static method, where passing `None`
would be just as wrong.

The cell also takes the broken patch out again, with the handle
`wrap_function_wrapper` returned and `wrapt.unwrap_object`, so the
call afterwards is logged once, by `notify`, and works. The workshop
after next, **Leaving things as you found them**, is about that
handle and everything it can do.

```{verify}
:id: never-pass-instance
:label: Passing instance raised TypeError and the broken patch is gone
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed never-pass-instance
"positional argument" in problem and seen[-1][0] == "buy" and seen[-1][2] == ("fig",) and corner.basket[-1] == "fig"
```

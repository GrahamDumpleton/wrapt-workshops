---
title: The ordering rule
requires: [quiz:predict-inside, verify:ordering]
---

# The ordering rule

The class method on the second page had `@show_context` above
`@classmethod`. Put it the other way round, so that `@classmethod` is
on top and the wrapt decorator is inside it, and predict what the
wrapper sees.

```{quiz}
:id: predict-inside
:title: Predict the inside-out order
:shuffle: true
question: "With `@classmethod` above `@show_context`, what does the wrapper see when `Shop.open_inside(\"High Street\")` is called?"
options:
  - text: "instance is Shop and args is ('High Street',), the same as with the decorator outside."
    explanation: "It would be, if classmethod passed the binding on. It does not: classmethod.__get__() assumes it wraps a plain function and never asks the wrapper to bind."
  - text: "A TypeError, because a classmethod object is not callable."
    explanation: "That is what a closure decorator gets when it is placed above @classmethod, since it is handed the classmethod object and tries to call it. Here the order is the other way round and the call goes through, wrongly."
  - text: "instance is None and args is (Shop, 'High Street')."
    correct: true
  - text: "instance is None and args is ('High Street',), with the class lost."
    explanation: "The class is not lost. It arrives as the first positional argument, exactly where a wrapper does not expect it."
explanation: "classmethod passes the class as a plain first argument to what it wraps, and never binds the wrapper, so the wrapper sees a plain function call with the class in args[0]."
```

```{cell-insert}
:id: insert-ordering
:path: {{ notebook }}
:tags: [ordering]
:run: true
class Shop:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"Shop({self.name!r})"

    @show_context
    @classmethod
    def open_outside(cls, name):
        return cls(name)

    @classmethod
    @show_context
    def open_inside(cls, name):
        return cls(name)

calls.clear()

Shop.open_outside("High Street")
Shop.open_inside("High Street")
```

Outside, `instance` is the class and `args` is `('High Street',)`.
Inside, `instance` is `None` and `args` is `(Shop, 'High Street')`:
the wrapper was called as if `open_inside` were a plain function with
the class as its first argument. Nothing failed, which is the worst
part. A wrapper that expects `instance` to hold the class for a class
method silently gets the wrong answer.

So the rule is: **a wrapt decorator goes outside `@classmethod`,
never inside.** The same placement is right for `@staticmethod`, so
the rule is simply always outside.

The cause is in `classmethod` rather than wrapt. `classmethod.__get__()`
assumes the thing it wraps is a plain function and does not apply the
descriptor protocol to it, so a `FunctionWrapper` inside a
`classmethod` is never told it is being bound. Python 3.9 fixed this,
and Python 3.13 reverted the fix because too much code relied on the
old behaviour, which is why the rule still applies on 3.14.

Note that this is the opposite of the rule in the decorator workshops,
where a closure decorator goes under `@classmethod` and
`@staticmethod`, closest to the `def`. Both rules come from the same
fact: a closure wrapper is a plain function, which is what
`classmethod` expects to wrap, and a wrapt wrapper is a descriptor,
which needs to be the one doing the binding.

```{verify}
:id: ordering
:label: Outside gives the class as instance; inside gives None with the class in args
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed ordering
len(calls) == 2 and calls[0][1] is Shop and calls[0][2] == ("High Street",) and calls[1][1] is None and calls[1][2] == (Shop, "High Street")
```

```{hint}
:title: The Python issue behind this
The report is [bpo-19072](https://bugs.python.org/issue19072). wrapt's
known issues page tells the story, including the 3.9 fix and the 3.13
reversal, and gives the same advice: always outside.
```

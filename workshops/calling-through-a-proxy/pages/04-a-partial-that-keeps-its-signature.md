---
title: A partial that keeps its signature
requires: [quiz:predict-partial, verify:wrapt-partial]
---

# A partial that keeps its signature

`functools.partial` binds some arguments of a function and gives back
something callable with the rest. Look at what that something is.

```{cell-insert}
:id: insert-functools-partial
:path: {{ notebook }}
:tags: [functools-partial]
:run: true
by_functools = functools.partial(fetch_price, "apple")

print("call      :", by_functools())
print("signature :", inspect.signature(by_functools))
print("type      :", type(by_functools))
print("__name__  :", getattr(by_functools, "__name__", "no __name__"))
print("a function:", isinstance(by_functools, types.FunctionType))
```

The signature is right, `(currency='USD')`, because `inspect` knows
about `functools.partial` and removes the bound parameters. But the
result is a `partial` object: it has no `__name__` and no docstring
of its own, and it is not a function to `isinstance`. Code that
inspects what it is handed sees a different kind of thing.

`wrapt.partial` binds arguments the same way and returns a callable
proxy over the function, with the bound arguments kept under
`_self_` names. Predict one answer before the cell runs.

```{quiz}
:id: predict-partial
:title: Predict the signature
:shuffle: true
question: "What does `inspect.signature(wrapt.partial(fetch_price, \"apple\"))` report?"
options:
  - text: "`(item, currency='USD')`, the whole signature, because the proxy forwards everything to the function."
    explanation: "The proxy answers for the function in most things, but a partial has consumed `item`, and reporting it would make callers pass it twice. wrapt removes the bound parameters as `functools.partial` does."
  - text: "`(currency='USD')`, the same as for `functools.partial`."
    correct: true
  - text: "`(*args, **kwargs)`, since `__call__` on the proxy takes anything."
    explanation: "The signature reported is derived from the function's own with the bound parameters removed, not from the proxy's `__call__`."
explanation: "A partial has used up the arguments it binds, so both forms report the parameters that remain. The difference is in what else the object is."
```

```{cell-insert}
:id: insert-wrapt-partial
:path: {{ notebook }}
:tags: [wrapt-partial]
:run: true
by_wrapt = wrapt.partial(fetch_price, "apple")

print("call      :", by_wrapt())
print("signature :", inspect.signature(by_wrapt))
print("type      :", type(by_wrapt))
print("__name__  :", by_wrapt.__name__)
print("a function:", isinstance(by_wrapt, types.FunctionType))
print("bound     :", by_wrapt._self_args, by_wrapt._self_kwargs)
```

Same call, same signature, and the rest is the function's: the
name, and `isinstance` says function, because underneath the proxy
it is one. The bound arguments are on `_self_args` and
`_self_kwargs`, where the function does not see them, which is the
`_self_` rule from the previous workshop at work inside wrapt itself.

```{verify}
:id: wrapt-partial
:label: The wrapt partial keeps the signature, the name and the function underneath
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed wrapt-partial
by_wrapt() == 0.5 and str(inspect.signature(by_wrapt)) == "(currency='USD')" and by_wrapt.__name__ == "fetch_price" and by_wrapt._self_args == ("apple",)
```

```{hint}
:title: A partial over a bound method
The class behind `wrapt.partial` is `PartialCallableObjectProxy`,
and its `__call__` is what applies the bound arguments. The wrapt
documentation's known issues page has a section on the signature it
reports for a partial over a bound method, where `self` is already
gone before the partial binds anything.
```

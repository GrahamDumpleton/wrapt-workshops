---
title: The trap
requires: [quiz:predict-attribute, verify:attribute-forwarded]
---

# The trap

The standard library `@count_calls` you may have written keeps its
count as an attribute of the inner function, which the decorator
returns, so the count is on the decorated name.

```{cell-insert}
:id: insert-stdlib
:path: {{ notebook }}
:tags: [stdlib]
:run: true
def count_calls(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        wrapper.call_count += 1
        return func(*args, **kwargs)

    wrapper.call_count = 0
    return wrapper

@count_calls
def greet(name):
    return f"Hello, {name}"

greet("Ada")
greet("Grace")

print("greet.call_count:", greet.call_count)
```

The decorated name is the inner function, so an attribute set on it
stays on it. A wrapt decorated name is a `FunctionWrapper`, a proxy
that forwards attribute lookups to the original. Predict what it does
with an attribute assignment.

```{quiz}
:id: predict-attribute
:title: Predict where the attribute lands
:shuffle: true
question: "`fetch_price` is decorated with a wrapt decorator. After `fetch_price.count = 0`, where is the `count` attribute?"
options:
  - text: "On the FunctionWrapper, like any attribute set on any object."
    explanation: "A FunctionWrapper forwards assignment the same way it forwards lookup, so the attribute goes where a lookup would find it, on the original."
  - text: "Nowhere: a FunctionWrapper refuses attribute assignment with an AttributeError."
    explanation: "Assignment succeeds. It just does not land where the closure version put it."
  - text: "On the original function, because the proxy forwards assignment as well as lookup."
    correct: true
  - text: "On both, so that lookups through either see the same value."
    explanation: "There is one copy, on the original. The wrapper sees it only because every lookup on the wrapper is forwarded there."
explanation: "A proxy that forwarded lookups but kept assignments for itself would let `wrapper.__doc__ = ...` and `wrapper.__doc__` disagree. wrapt forwards both, so the original function is where the attribute lands."
```

Now the cell.

```{cell-insert}
:id: insert-trap
:path: {{ notebook }}
:tags: [trap]
:run: true
@wrapt.decorator
def pass_through(wrapped, instance, args, kwargs):
    return wrapped(*args, **kwargs)

@pass_through
def fetch_price(item):
    """Look up the price of an item."""
    return PRICES[item]

fetch_price.count = 0

print("fetch_price.count:", fetch_price.count)
print("on the original :", vars(fetch_price.__wrapped__))

landed_on_original = "count" in vars(fetch_price.__wrapped__)
```

`fetch_price.count` reads back as `0`, so nothing looks wrong, and
`vars(fetch_price.__wrapped__)` shows where it went: the original
function's own dictionary. That is the right behaviour for
`fetch_price.__doc__ = "..."`, which should change the docstring
everyone sees, and the wrong place for a decorator's state, which now
lives on a function that knows nothing about the decorator and is
shared with any other decorator that picks the same name.

There is a way to keep an attribute on the wrapper itself. A name
starting with `_self_` is the proxy's own and is never forwarded.

```{cell-insert}
:id: insert-self-prefix
:path: {{ notebook }}
:tags: [self-prefix]
:run: true
fetch_price._self_note = "kept on the wrapper"

print("fetch_price._self_note:", fetch_price._self_note)
print("on the original?      :", hasattr(fetch_price.__wrapped__, "_self_note"))

kept_on_wrapper = not hasattr(fetch_price.__wrapped__, "_self_note")
```

That is the answer for a flag or a label that belongs to one decorated
function. It is not where a decorator's state belongs, because the
wrapper function that would update it has no way to reach the
`FunctionWrapper` it is running inside: it receives `wrapped`, the
original, and not the proxy. The next page puts the state where the
wrapper can reach it.

```{verify}
:id: attribute-forwarded
:label: count landed on the original and _self_note stayed on the wrapper
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed self-prefix
landed_on_original and kept_on_wrapper
```

```{hint}
:title: If the check fails
`landed_on_original` is false when the `count` attribute is not in
the original function's `vars()`, which means the cell that set it did
not run on a wrapt decorated `fetch_price`. Run the two cells on this
page in order.
```

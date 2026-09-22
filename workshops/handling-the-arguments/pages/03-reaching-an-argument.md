---
title: Reaching an argument
requires: [verify:normalised]
---

# Reaching an argument

Suppose the wrapper wants the first argument. The obvious spelling is
`args[0]`.

```{cell-insert}
:id: insert-first
:path: {{ notebook }}
:tags: [first]
:run: true
@wrapt.decorator
def first_argument(wrapped, instance, args, kwargs):
    print("first argument:", args[0])
    return wrapped(*args, **kwargs)

@first_argument
def fetch_price(item, currency="USD"):
    """Look up the price of an item."""
    return f"{PRICES[item]} {currency}"

fetch_price("apple")

try:
    fetch_price(item="apple")
    problem = "no error"
except IndexError as error:
    problem = f"IndexError: {error}"

print(problem)
```

The positional call works and the keyword call raises `IndexError`,
because `item` travelled in `kwargs` and `args` was empty. `args[0]`
is the first positional argument, which is only sometimes the first
parameter. A closure wrapper has the same trap, and the usual fix
there, naming the parameter in the wrapper as `def wrapper(item,
*args, **kwargs)`, is exactly the binding wrapt keeps out of the
wrapper's signature.

The pattern wrapt's documentation gives instead is a nested function
with the parameters you care about, called with the arguments so that
Python does the binding.

```{cell-insert}
:id: insert-normalise
:path: {{ notebook }}
:tags: [normalise]
:run: true
@wrapt.decorator
def normalise_item(wrapped, instance, args, kwargs):
    def _execute(item, *_args, **_kwargs):
        return wrapped(item.strip().lower(), *_args, **_kwargs)

    return _execute(*args, **kwargs)

@normalise_item
def fetch_price(item, currency="USD"):
    """Look up the price of an item."""
    return f"{PRICES[item]} {currency}"

normalised = [
    fetch_price("  Apple "),
    fetch_price(item="PEAR", currency="EUR"),
    fetch_price("Fig", "GBP"),
]
print(normalised)
```

All three are found, whichever way `item` was passed. `_execute`
names the one parameter the wrapper cares about and mops up the rest
with `*_args, **_kwargs`, and `_execute(*args, **kwargs)` has Python
bind the call to it, positionally or by keyword, exactly as it would
bind the call to `fetch_price`. The wrapper then forwards `item`
changed and everything else as it came.

The underscored names are deliberate: `_execute` has its own
positional and keyword collections, and calling them `args` and
`kwargs` would shadow the wrapper's.

One thing to document when you use this: `_execute` binds by name, so
the decorated function's parameter has to be called `item`. That is a
restriction the next page removes.

```{verify}
:id: normalised
:label: args[0] failed on the keyword call and the nested function bound item both ways
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed normalise
problem.startswith("IndexError") and normalised == ["0.5 USD", "0.75 EUR", "2.0 GBP"]
```

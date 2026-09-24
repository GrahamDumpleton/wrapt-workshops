---
title: What it gets wrong
requires: [quiz:predict-delegate, verify:delegate-report]
---

# What it gets wrong

Now ask the delegate the questions that code receiving a shop might
ask. Six are listed below. Before running anything, predict which of
them come out the same as for the shop itself.

```{quiz}
:id: predict-delegate
:title: Predict the delegate
:type: multi
question: "Which of these give the same answer for `delegate` as for `shop`? Pick every one that applies."
options:
  - text: "`isinstance(delegate, Shop)`"
    explanation: "`isinstance` reads `__class__`, and the delegate's is `Delegate`. Nothing about `__getattr__` changes that."
  - text: "`delegate.buy(\"pear\")`"
    correct: true
  - text: "`len(delegate)`"
    explanation: "Python looks special methods up on the type, never through `__getattr__`, and `Delegate` has no `__len__`."
  - text: "`delegate == shop`"
    explanation: "Equality is `__eq__`, another special method found on the type. `Delegate` has none, so Python falls back to identity, and the delegate is not the shop."
  - text: "`delegate.name`"
    correct: true
  - text: "`str(delegate)`"
    explanation: "`str` looks for `__str__` on the type as well. `Delegate` only has the default from `object`, which prints a class name and an address."
explanation: "Only what goes through `__getattr__` is forwarded: plain attribute reads, including methods. `isinstance` and the special methods never get there."
```

You have already seen `delegate.buy` and `delegate.name` work on the
previous page. The report below runs the other four.

```{cell-insert}
:id: insert-delegate-report
:path: {{ notebook }}
:tags: [delegate-report]
:run: true
def report(candidate):
    result = {}
    result["isinstance"] = isinstance(candidate, Shop)
    try:
        result["len"] = len(candidate)
    except TypeError as exc:
        result["len"] = f"TypeError: {exc}"
    result["equal"] = candidate == shop
    result["str"] = str(candidate)
    return result

delegate_report = report(delegate)

for key, value in delegate_report.items():
    print(f"{key:>10}: {value}")
```

Four questions, and the delegate gets all four wrong. `isinstance`
says no, because the delegate's `__class__` is `Delegate`. `len`
raises, because Python finds special methods on the type, and
`Delegate` has no `__len__`; `__getattr__` is never consulted for
them. `==` is false for the same reason, falling back to identity,
and `str` prints a `Delegate` at an address rather than
`Shop('corner')`. The two that do work, `buy` and `name`, are the
only ones that go through `__getattr__`.

There is a fifth failure, and it is the one that bites in real code. Assign
an attribute through the delegate and see where it lands.

```{cell-insert}
:id: insert-delegate-assign
:path: {{ notebook }}
:tags: [delegate-assign]
:run: true
delegate.name = "market"

print("delegate.name:", delegate.name)
print("shop.name    :", shop.name)
```

The delegate now has a `name` of its own, found before `__getattr__`
is ever called, and the shop still says `corner`. Any code that
updates the object through the delegate is talking to a copy that
nothing else can see.

Each of these can be fixed by hand: a `__class__` property, a
`__len__`, an `__eq__`, a `__str__`, a `__setattr__`. That is the
point. A transparent proxy needs all of them, and every other special
method Python might look up, and the next page shows what it looks
like when someone has already written them.

```{verify}
:id: delegate-report
:label: The delegate fails isinstance, len, equality and str, and keeps the assignment
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed delegate-assign
delegate_report["isinstance"] is False and str(delegate_report["len"]).startswith("TypeError") and delegate_report["equal"] is False and delegate.name == "market" and shop.name == "corner"
```

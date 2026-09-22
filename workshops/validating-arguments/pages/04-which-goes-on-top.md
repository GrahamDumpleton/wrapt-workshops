---
title: Which goes on top
requires: [quiz:predict-order, verify:order-matters]
---

# Which goes on top

Both checkers on one function. They stack like any decorators, and
one of the two orders is wrong. Predict which before running it.

```{quiz}
:id: predict-order
:title: Predict the wrong order
:shuffle: true
question: "`price_of(item: str, quantity: int = 1)` has both checkers, and is called as `price_of(\"apple\", \"3\")`, with a string where an int belongs. Which order reports a clear error, and what does the other do?"
options:
  - text: "value_checker on top reports clearly. With type_checker on top, the TypeError is swallowed and the constraint runs on the string."
    explanation: "Nothing is swallowed. Each checker raises, and the first to run is the one that reports. The question is which sees the string first."
  - text: "Either order reports 'Argument quantity must be int', because the type check runs first regardless of where it is placed."
    explanation: "The outermost decorator runs first. Put value_checker on top and is_positive sees the string before the type check does."
  - text: "type_checker on top reports 'must be int, got str'. With value_checker on top, is_positive compares the string with 0 and raises its own TypeError about '>' instead."
    correct: true
  - text: "Both orders raise the same TypeError from the '>' comparison, because the type checker only checks annotated parameters and quantity's annotation is a default."
    explanation: "quantity is annotated as int, so the type checker checks it. Its default is a separate thing from its annotation."
explanation: "The outer decorator runs first. With the type checker outside, a wrong type is reported as a wrong type and never reaches a constraint that was written for the right one. With the value checker outside, the constraint runs on the wrong type and fails in whatever way it happens to fail."
```

```{cell-insert}
:id: insert-order
:path: {{ notebook }}
:tags: [order]
:run: true
@type_checker
@value_checker(quantity=is_positive)
def price_of(item: str, quantity: int = 1) -> float:
    return PRICES[item] * quantity

@value_checker(quantity=is_positive)
@type_checker
def price_of_reversed(item: str, quantity: int = 1) -> float:
    return PRICES[item] * quantity

order_problems = {}

for function in (price_of, price_of_reversed):
    try:
        function("apple", "3")
    except Exception as exc:
        order_problems[function.__name__] = f"{type(exc).__name__}: {exc}"
        print(f"{function.__name__:18}", order_problems[function.__name__])
```

Type checking on top. A wrong type is then reported as a wrong type,
and the constraints, which were written assuming the right type,
never see anything else. The other way round, `is_positive` compares
a string with zero and raises a `TypeError` of its own, about `>`,
which is true but tells the caller nothing about what they did.

The rule generalises: order decorators so that the cheapest and most
general check runs first and the ones that assume it passed run
inside it.

```{verify}
:id: order-matters
:label: The type checker on top reported the type; underneath it did not
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed order
order_problems["price_of"] == "TypeError: Argument 'quantity' must be int, got str" and "not supported between" in order_problems["price_of_reversed"]
```

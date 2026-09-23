---
title: Where assignment goes wrong
requires: [quiz:predict-tax, verify:assignment-breaks, verify:restored]
---

# Where assignment goes wrong

`Shop` in {open}`shop/cart.py` has two more methods. `tax` is a
static method and `empty` is a class method, and the class holds them
as a `staticmethod` object and a `classmethod` object. Read them off
the class the two ways Python offers: from the class namespace,
`Shop.__dict__`, which is what the class holds, and with `getattr`,
which is what `Shop.tax` and `Shop.empty` give you.

```{cell-insert}
:id: insert-two-views
:path: {{ notebook }}
:tags: [two-views]
:run: true
raw_tax = Shop.__dict__["tax"]
raw_empty = Shop.__dict__["empty"]

print("in the class namespace:", type(raw_tax).__name__, "and", type(raw_empty).__name__)
print("through getattr       :", type(Shop.tax).__name__, "and", type(Shop.empty).__name__)
```

The namespace holds a `staticmethod` and a `classmethod`. `getattr`
triggers the descriptor protocol and hands back what those produce
on lookup through the class: a plain `function` for the static
method, and a bound `method` for the class method. Assignment
patches what `getattr` gave you, and puts the result back in the
namespace as a plain function. Predict what that does to `tax`.

```{quiz}
:id: predict-tax
:title: Predict the static method
:shuffle: true
question: "After `Shop.tax = logged(Shop.tax)`, what happens to `Shop(\"Corner Store\").tax(10)`, a call through an instance?"
options:
  - text: "It is logged and returns 1.0, since the static method never used self anyway."
    explanation: "The wrapper is a plain function now, not a static method, so lookup through an instance binds it and passes the shop as the first argument."
  - text: "It raises TypeError, because the wrapper is now a plain function that binds to the shop and receives it as an extra argument."
    correct: true
  - text: "It raises AttributeError, because assignment removed tax from the class."
    explanation: "Assignment replaced the attribute with the wrapper. It is still there, just no longer a static method."
  - text: "It works, because functools.wraps copies the staticmethod back onto the wrapper."
    explanation: "functools.wraps copies the name, docstring and a few other attributes. It does not know what kind of method the original was, and it could not make the wrapper one."
explanation: "In the class namespace, a plain function is an instance method. Lookup through an instance binds it, so the wrapper receives the shop and then 10, passes both to a function that takes one, and Python raises."
```

Now the cell. It patches both, prints what the namespace holds now,
and makes the calls that go wrong, each caught so the notebook can
carry on.

```{cell-insert}
:id: insert-breaks
:path: {{ notebook }}
:tags: [breaks]
:run: true
Shop.tax = logged(Shop.tax)
Shop.empty = logged(Shop.empty)

print("in the class namespace now:", type(Shop.__dict__["tax"]).__name__, "and", type(Shop.__dict__["empty"]).__name__)
print("through the class         :", Shop.tax(10))

try:
    Shop("Corner Store").tax(10)
    tax_problem = "no error"
except TypeError as error:
    tax_problem = str(error)
print("through an instance       :", tax_problem)

kiosk_empty = Kiosk.empty()
print("Kiosk.empty() made a      :", type(kiosk_empty).__name__)
```

Three things went wrong, one of them quietly. The namespace now holds
two plain functions. `Shop.tax(10)` still works, because a plain
function looked up on the class is not bound to anything, and a
static method reached through an instance raises, because now it is.
And `Kiosk.empty()` made a `Shop`: the wrapper holds the bound method
`getattr` produced, bound to `Shop` at the moment of the patch, so a
subclass calling it gets the wrong class back and no error to say so.

The same flaw is in the usual way of undoing a patch. Save
`Shop.tax` before patching and assign it back afterwards, and what
you restore is the plain function `getattr` gave you, not the
`staticmethod` the class held. The only way back is the raw object
from the namespace, which the first cell on this page kept.

```{cell-insert}
:id: insert-restore
:path: {{ notebook }}
:tags: [restore]
:run: true
Shop.tax = raw_tax
Shop.empty = raw_empty
Shop.buy = Shop.__dict__["buy"].__wrapped__
shop.pricing.fetch_price = shop.pricing.fetch_price.__wrapped__

print("restored:", type(Shop.__dict__["tax"]).__name__, "and", type(Shop.__dict__["empty"]).__name__)
print("Kiosk.empty() made a:", type(Kiosk.empty()).__name__)
```

The two patches from the previous page are taken out too, by
following the `__wrapped__` link `functools.wraps` left, so the next
page starts from the shop as shipped. Putting things back by hand is
part of the cost of patching by hand.

```{verify}
:id: assignment-breaks
:label: The static method raised through an instance and Kiosk.empty() made a Shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed breaks
"positional argument" in tax_problem and type(kiosk_empty) is Shop
```

```{verify}
:id: restored
:label: The class holds its staticmethod and classmethod again
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed restore
type(Shop.__dict__["tax"]) is staticmethod and type(Shop.__dict__["empty"]) is classmethod and type(Shop.__dict__["buy"]).__name__ == "function" and not hasattr(shop.pricing.fetch_price, "__wrapped__")
```

```{hint}
:title: If the restore check fails
The restore cell follows one `__wrapped__` link on `buy` and on
`fetch_price`, so it works once. Running the page's cells a second
time, after the restore, patches the restored objects again and the
restore then follows a link that is not there. Restart the kernel and
run the notebook from the top if that has happened.
```

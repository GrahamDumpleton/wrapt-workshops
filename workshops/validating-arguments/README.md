# Validating arguments

Build two argument checkers as state classes. A `TypeChecker`
compares each argument against its annotation, with the signature
taken from the bound `wrapped` on the first call so that methods need
no special case, and a `ValueChecker` takes constraint callables by
parameter name. Apply both to functions and every kind of method
without changing a line, then find the one stacking order that
reports errors properly.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

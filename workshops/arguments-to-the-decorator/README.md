# Arguments to the decorator

Give a wrapt decorator settings of its own, three ways: a function
that takes the settings and returns the decorator, a class whose
`__call__` is the wrapper, and a decorator that works with and without
parentheses through `wrapt.partial`. Each sits beside the standard
library shape it replaces.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

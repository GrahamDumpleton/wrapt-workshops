# One decorator for everything

Write one decorator that does the right thing on a function, an
instance method, a class method, a static method and a class, telling
them apart from `instance` and `wrapped` alone, and have it refuse
what it does not support. Then stack wrapt decorators with each other
and with a `functools.wraps` closure, and walk the chain with
`wrapt.wrapper_chain()` and `wrapt.unwrapped()`.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

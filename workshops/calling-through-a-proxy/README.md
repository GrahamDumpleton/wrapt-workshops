# Calling through a proxy

`BaseObjectProxy` refuses to be called, so a proxy over a function
uses `CallableObjectProxy`, and a subclass of it counts calls while
still being the function to `inspect` and `isinstance`. Then
`wrapt.partial` beside `functools.partial`: the same signature, and a
partial that is still the function underneath.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

# Changing the signature

A decorator that supplies an argument the caller no longer passes
leaves `inspect.signature()` and `help()` describing a parameter
nobody should pass. Fix what introspection sees with
`wrapt.with_signature`, from a prototype function and from a factory
that derives the new signature from the old, on a function and on a
method, and stacked under another decorator.

Ten minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

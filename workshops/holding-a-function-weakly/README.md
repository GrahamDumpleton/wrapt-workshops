# Holding a function weakly

A weak reference to a bound method is dead before the next line,
because the method object is made on each access and thrown away.
`WeakFunctionProxy` holds the instance and the function weakly,
rebinds on each call, raises `ReferenceError` once the instance is
gone and runs a callback when it goes, which is what a registry that
must not keep its objects alive needs.

Ten minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

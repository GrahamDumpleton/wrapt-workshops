# What does not pass through

The lines a transparent proxy cannot cross: identity, `type()`, and an
operator that returns a plain value. Then the one line
`wrapt.BaseObjectProxy` draws on purpose, leaving `__iter__` and
`__call__` off so a proxy never claims to be something its target is
not, and a subclass that defines `__iter__` itself when its target is
iterable.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

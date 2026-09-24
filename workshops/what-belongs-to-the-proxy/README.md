# What belongs to the proxy

An assignment through a proxy lands on the target, so a proxy that
counts needs somewhere of its own. The `_self_` prefix, the two
dictionaries a proxy has and `__self_dict__` for reading its own, and
`__self_setattr__` in `__init__` for an override that only some
instances should have. `unittest.mock.Mock` with `wraps` for
comparison.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

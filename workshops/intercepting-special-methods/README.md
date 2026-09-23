# Intercepting special methods

Set `__getitem__` on a proxy instance and watch nothing change,
because Python looks special methods up on the type. Then define it
on a `BaseObjectProxy` subclass over a settings dictionary and record
every key read, and do the same with `__enter__` and `__exit__` on a
lock and `__iadd__` on a list.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

# Synchronising calls

See a counter come up short under threads, then serialise the calls
with `wrapt.synchronized`. Find where the lock lives for a function,
an instance method, a class method, a static method and a class,
share it with the context manager form, and supply a lock or a
semaphore of your own.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own and starts a few threads, each for a few
milliseconds.

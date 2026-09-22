# Keeping state

Give a decorator state that outlives one call. Find out where an
attribute set on a wrapt decorated function really lands, then build
the state class wrapt's own examples use: a class whose `__call__` is
the wrapper, with `bind_state_to_wrapper` making its state reachable
through the decorated function, and a static method giving it optional
arguments.

Twenty minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

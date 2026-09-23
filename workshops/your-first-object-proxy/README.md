# Your first object proxy

Write the delegating class you would write today, a `__getattr__` that
forwards to the object it holds, and find the four things it gets
wrong. Then wrap the same object in `wrapt.BaseObjectProxy` and see it
get all four right without a method written, and meet `__wrapped__`.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

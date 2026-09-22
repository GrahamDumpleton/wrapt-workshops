# Handling the arguments

What a wrapper does with the call's arguments. See why wrapt hands
them over as a tuple and a dict rather than binding them to names,
why reading `args[0]` is wrong, how a nested function binds the one
argument you care about, how `inspect.signature` binds all of them by
name with no special case for methods, and what a wrapper can do with
the return value.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

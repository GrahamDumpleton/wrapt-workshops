# Patches that last a block

Patches that remove themselves. `unittest.mock.patch` first, which
replaces wholesale, then `wrapt.scoped_function_wrapper` for a `with`
block, several at once and from a list with `ExitStack`, and
`transient_function_wrapper` for a function call, read in two steps
and lasting the call even when it raises. What each does when
something inside the block interferes, and where wrapture takes
testing with patches next.

Fifteen minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

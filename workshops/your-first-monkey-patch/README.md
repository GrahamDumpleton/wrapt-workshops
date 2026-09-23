# Your first monkey patch

Patch a function and a method by assignment, the way you already know,
and see it work. Do the same to a static method and a class method and
watch what `getattr` handed you break both, one loudly and one
quietly. Then `wrapt.wrap_function_wrapper` on all of them, reading the
class namespace rather than asking `getattr`, so each method stays its
own kind, and meet the handle it returns.

Fifteen minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

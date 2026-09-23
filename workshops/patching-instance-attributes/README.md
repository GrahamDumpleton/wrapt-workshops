# Patching instance attributes

The value that lives on each object rather than on its class, set in
`__init__`, which no wrap function so far can reach.
`wrapt.wrap_object_attribute` installs a descriptor on the class that
passes every read through a factory of yours: over a property, over a
class default, stacked twice, and removed with its handle leaving the
class as shipped.

Fifteen minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

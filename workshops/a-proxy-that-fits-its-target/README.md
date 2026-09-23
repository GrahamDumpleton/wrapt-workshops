# A proxy that fits its target

`BaseObjectProxy` refuses to iterate, call or resume a generator, and
`AutoObjectProxy` does all three, because it reads its target when it
is made and adds the special methods that target has. The cost is a
class per instance, measured, and the rule for when each is right.

Ten minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

# Saving and restoring a proxy

`pickle`, `copy.copy` and `copy.deepcopy` all refuse a proxy, with
`NotImplementedError`, because the base class cannot know what state
a subclass added. Define `__reduce__` on a proxy with a label of its
own and round trip it through pickle with both the target and the
label intact, then `__copy__` and `__deepcopy__` the same way.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

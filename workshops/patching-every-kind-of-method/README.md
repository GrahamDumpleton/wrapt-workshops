# Patching every kind of method

Put one wrapper on every kind of target there is: an instance method,
a class method, a static method, `__init__` and `__len__`, and a method
of a nested class through a dotted path. Predict what `instance` holds
before each cell shows it. Patch a module by naming it as a string,
break the one rule about `instance` to see why it is a rule, and patch
one object without touching the others of its class.

Fifteen minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

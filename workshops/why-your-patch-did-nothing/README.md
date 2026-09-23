# Why your patch did nothing

A patch applied correctly that changed nothing. A shipped module that
imported the function by name holds its own reference, and the patch
on the original module never reaches it. See the line responsible,
patch the alias too, and see why a method looked up through the class
at call time is the safer target than a function, and a bound method
saved in a variable is not.

Fifteen minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

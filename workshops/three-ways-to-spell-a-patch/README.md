# Three ways to spell a patch

The same patch three ways. `wrap_function_wrapper` as a call, from a
list of targets, keeping the handles. `patch_function_wrapper` as a
decorator on the wrapper in a shipped file of patches, installed by
importing the file, with `enabled` as its switch. `function_wrapper`
turning a wrapper into a decorator to apply in place or to hand to
`wrap_object` as the factory. When each reads best.

Ten minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

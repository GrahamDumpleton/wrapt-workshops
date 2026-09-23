# Wrapping what is not a function

A patch on a dictionary a module reads its settings from.
`wrapt.wrap_object` with a factory of your own, a `BaseObjectProxy`
subclass that records which keys are read, and the three things about
proxies a patch needs to know. A callable proxy counting calls with
arguments to the factory, and the two steps beneath every wrap
function, `resolve_path` and `apply_patch`, with what a replacement
that is not a proxy gives up.

Fifteen minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

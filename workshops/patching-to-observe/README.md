# Patching to observe

The mechanisms put to work. A wrapper with state that counts and times
a library's calls, a registry that installs each patch once and
removes them all, a version check before patching, and a post import
hook so the patches apply whether the library is imported before or
after. The shape of every instrumentation agent, and where wrapture
takes it.

Twenty minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

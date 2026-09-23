# Patching before the import

A patch that waits for its module, on three shipped modules nothing
else imports. The `?` on the module name, a post import hook with
`when_imported` that receives the module and fires at once for one
already imported, and the string form that keeps the patch module
itself unimported until the target is. Then the handle a deferred
patch does not return, recovered with `find_wrapper` and a predicate.

Twenty minutes, in a notebook with the code being patched open beside
it. The workshop installs wrapt into an environment of its own.

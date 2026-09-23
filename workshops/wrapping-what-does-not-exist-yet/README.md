# Wrapping what does not exist yet

`LazyObjectProxy` takes a callback in place of a target and runs it
the first time the proxy is used. `wrapt.lazy_import` over a shipped
module that announces its import, one attribute of a module, and the
`interface` hint a lazy proxy needs to be callable before the import
has happened.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own and ships the package it imports.

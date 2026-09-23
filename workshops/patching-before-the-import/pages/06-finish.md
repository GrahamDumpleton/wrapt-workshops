---
title: What you know now
requires: [quiz:hook-timing]
---

# What you know now

Three ways for a patch to wait for its module:

- **A `?` on the module name**, in `wrap_function_wrapper` or
  `patch_function_wrapper`: applied at once if the module is
  imported, on import otherwise. Returns no handle.

- **A post import hook**, `@wrapt.when_imported(name)` or
  `wrapt.register_post_import_hook(hook, name)`: the hook receives
  the module, before the import returns to whoever asked for it, and
  fires during registration if the module is already imported. The
  hook can keep the handle.

- **The string form**, `"package.module:function"` as the hook: the
  patch module is not imported until the target is.
  `discover_post_import_hooks` reads such registrations from entry
  points.

A handle a deferred patch did not return is recovered with
`wrapt.find_wrapper` and a predicate on `_self_wrapper`.

```{quiz}
:id: hook-timing
:title: When the hook runs
:shuffle: true
question: "A program's first module registers `@wrapt.when_imported(\"requests\")` with a hook that patches `Session.get`. Later, another module does `from requests import Session` and calls `Session().get(url)`. Is the call seen by the patch?"
options:
  - text: "No: from requests import Session copies Session before any hook can run."
    explanation: "The hook runs as part of importing requests, before the from statement finishes, so by the time Session is copied its get is already patched."
  - text: "Yes: the hook runs when requests is imported, before the from statement returns, and get is looked up on the class at call time anyway."
    correct: true
  - text: "Only if requests was already imported when the hook was registered, since a hook for an unimported module never fires."
    explanation: "A hook for an unimported module fires when it is imported. One for an already imported module fires at registration. Both cases are covered."
  - text: "No, because when_imported only works with the ? form of the module name."
    explanation: "The ? and the hook are two separate mechanisms. when_imported takes a plain module name and waits on its own."
explanation: "Registered first, the hook runs during the import of requests and before the importing module gets its Session, so every later reference sees the patch; and Session.get is a method, looked up on the class at call time, which would see it regardless."
```

## Where this goes next

Every patch in the workshops so far has wrapped a function or a
method with a function wrapper. The next workshop wraps something
else, a dictionary a module reads its settings from, with a proxy of
your own through `wrap_object`, and shows the two steps beneath every
wrap function.

**Wrapping what is not a function** is next.

Press Finish below to move on.

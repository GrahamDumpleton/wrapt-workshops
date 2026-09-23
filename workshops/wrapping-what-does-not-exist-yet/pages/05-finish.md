---
title: What you know now
requires: [quiz:when-it-runs]
---

# What you know now

`LazyObjectProxy` takes a callback in place of a target, runs it on
the first use of the proxy and never again, and is the proxy you
know from then on. `wrapt.lazy_import` is that with an import for
the callback, for a module or for one attribute of it. A lazy proxy
has nothing to read its special methods from until the callback has
run, so the `interface` argument says what to expect, and the
attribute form of `lazy_import` assumes a callable.

```{quiz}
:id: when-it-runs
:title: When the import runs
:shuffle: true
question: "`reports = wrapt.lazy_import(\"shop.reports\")` at the top of a module. When is `shop.reports` imported?"
options:
  - text: "The first time an attribute of `reports` is used, and not when the line runs."
    correct: true
  - text: "When the line runs, like any other import."
    explanation: "The cell checked `sys.modules` straight after making the proxy and the module was not there. Nothing is imported until the proxy is used."
  - text: "Every time an attribute of `reports` is used."
    explanation: "The callback runs once. After that the module is the proxy's target and every use goes straight to it."
  - text: "When the module containing the line is itself imported."
    explanation: "That is when the line runs, and the line only makes a proxy. The import waits for the first use."
explanation: "A lazy proxy runs its callback on first use and keeps the result. That is what makes it safe to name at the top of a module that the imported module would import back."
```

## Where this goes next

A proxy holds its target, and so keeps it alive. The next workshop is
about a proxy that must not, for a callback registry or a cache that
should let its objects go, and the bound method that dies the moment
it is made.

**Holding a function weakly** is next.

Press Finish below to move on.

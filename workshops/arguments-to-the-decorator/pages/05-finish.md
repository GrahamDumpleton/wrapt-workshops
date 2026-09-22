---
title: What you know now
requires: [quiz:where-settings-live]
---

# What you know now

Three shapes for a decorator with settings, and when each fits:

- **A function returning the decorator.** The outer function takes the
  settings, and the wrapper inside it, under `@wrapt.decorator`, reads
  them as closure variables. Two `def`s where the closure version
  needs three. Right for a setting or two.

- **A class whose `__call__` is the wrapper.** `__init__` takes the
  settings and keeps them on `self`, `__call__` carries the four
  wrapper arguments after `self`, and the class can have helper
  methods. Right for several settings, helpers, or state.

- **Optional settings.** `wrapped=None` first, keyword-only settings,
  and `wrapt.partial(...)` when the function has not arrived yet. Both
  `@debug` and `@debug(prefix="###")` work, with no test of what was
  passed, and the pending decorator is still introspectable.

Keyword-only settings, `def retry(*, max_attempts=3)`, are what make
the third shape unambiguous, and cost nothing in the first two.

```{quiz}
:id: where-settings-live
:title: Where the settings live
:shuffle: true
question: "In the class form, `@Retry(max_attempts=3)`, where do the settings live and how does the wrapper reach them?"
options:
  - text: "As closure variables of `__call__`, captured when the class was defined."
    explanation: "`__call__` closes over nothing. The settings are passed to `__init__` when the decorator is applied, long after the class was defined."
  - text: "On the `Retry` instance, reached through `self`, which `@wrapt.decorator` supplies when `__call__` runs as the wrapper."
    correct: true
  - text: "On the wrapped function, as attributes set by `__init__`."
    explanation: "`__init__` never sees the function. It runs when `Retry(max_attempts=3)` is evaluated, before the decorator is applied to anything."
  - text: "In `kwargs`, alongside the call's keyword arguments."
    explanation: "`kwargs` holds what the caller of `fetch_price` passed. The decorator's settings were fixed when it was applied, and the call knows nothing about them."
explanation: "`Retry(max_attempts=3)` is an instance holding the settings. Applying it, and every later call of the decorated function, runs `__call__` with that instance as self, so the settings are self.max_attempts and self.exceptions."
```

## Where this goes next

The settings were the decorator's own arguments. The other arguments,
the ones each call passes, arrive in the wrapper as `args` and
`kwargs`, a tuple and a dict, and are never bound to names. The next
workshop is about why, and about how a wrapper reaches an argument by
name anyway.

**Handling the arguments** is next.

Press Finish below to move on.

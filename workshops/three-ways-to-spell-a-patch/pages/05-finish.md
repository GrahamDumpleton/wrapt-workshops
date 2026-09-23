---
title: What you know now
requires: [quiz:which-spelling]
---

# What you know now

Three spellings of one patch:

- **`wrapt.wrap_function_wrapper(target, name, wrapper)`**, a call,
  for code that decides what to patch when it runs. It returns the
  handle.

- **`@wrapt.patch_function_wrapper(target, name)`** on the wrapper,
  for a file of patches that installs itself when imported. It
  returns the wrapper function, not a handle, and takes `enabled`,
  a callable asked on every call or a boolean read once, which still
  installs a wrapper that steps aside.

- **`@wrapt.function_wrapper`** on the wrapper, making a decorator
  without the extras of `@wrapt.decorator`, to apply in place on a
  plain function or instance method, or to hand to `wrapt.wrap_object`
  as the factory.

```{quiz}
:id: which-spelling
:title: Which spelling
:shuffle: true
question: "An instrumentation package reads the list of functions to patch from its configuration at start-up and must be able to switch the patches off again later. Which spelling fits?"
options:
  - text: "patch_function_wrapper, since it is the form meant for instrumentation."
    explanation: "Its target is written into the decorator, so it cannot come from a list, and it returns the wrapper rather than a handle to remove later."
  - text: "function_wrapper applied in place with assignment, since the targets are functions."
    explanation: "Assignment through getattr breaks static and class methods, and it gives you no handle for taking the patch out, only what you assigned over."
  - text: "wrap_function_wrapper, called for each entry in the list, keeping the handle each call returns."
    correct: true
  - text: "Any of them, since they all install the same FunctionWrapper."
    explanation: "They do, and the choice is still about where the target comes from and whether a handle comes back. Only the call takes a target from data and returns the handle."
explanation: "The call form takes its target and name from anywhere, which a list read at start-up is, and returns the handle that removal needs. The decorator forms fix the target where the wrapper is written."
```

## Where this goes next

Every spelling installs a wrapper, and two of them hand you the
wrapper back. The next workshop is about that handle: how to ask
whether a patch is still in place, how to see the chain of wrappers
on a target, and how to take one out, in any order, with nothing left
behind.

**Leaving things as you found them** is next.

Press Finish below to move on.

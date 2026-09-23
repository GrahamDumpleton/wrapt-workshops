---
title: What you know now
requires: [quiz:two-steps]
---

# What you know now

Two forms of patch that remove themselves:

- **`wrapt.scoped_function_wrapper(target, name, wrapper)`** is a
  single use context manager: the patch lasts the `with` block.
  Several go in one `with` statement, or through `ExitStack` when the
  list is only known at runtime.

- **`@wrapt.transient_function_wrapper(target, name)`** on a wrapper
  describes the patch and makes a decorator; applied to a function,
  the patch lasts each call of that function, raised or not.

Unlike `unittest.mock.patch`, both keep the original running beneath
a wrapper that knows what it landed on. On exit, a temporary wrapper
that was replaced wholesale raises `WrapperNotFoundError`, a wrapt
wrapper left on top is tolerated and the temporary one spliced out
beneath it, and a plain closure left on top raises
`WrapperNotOutermostError`.

```{quiz}
:id: two-steps
:title: The two steps
:shuffle: true
question: "`stub_price` is defined with `@wrapt.transient_function_wrapper(shop.pricing, \"fetch_price\")`. When is the patch on `fetch_price` in place?"
options:
  - text: "From the moment stub_price is defined, until the kernel restarts."
    explanation: "Defining stub_price only describes the patch. Nothing is installed until a function decorated with stub_price is called."
  - text: "During each call of a function decorated with @stub_price, and at no other time."
    correct: true
  - text: "During the first call of a decorated function only, after which the patch stays."
    explanation: "The patch is installed on the way into each call and removed on the way out, every time."
  - text: "Whenever stub_price itself is called."
    explanation: "stub_price is never called directly. It is applied as a decorator to the function whose calls the patch should cover."
explanation: "The outer decorator describes the patch and returns a decorator. Applying that decorator picks the function whose calls install the patch on entry and remove it on exit, however the call ends."
```

## Where this goes next

A temporary patch is the start of testing with patches, and
[wrapture](https://wrapture.readthedocs.io) is where that goes: a
library built on these helpers that gives a patch a lifecycle, records
what real code did, and lets a test assert on the calls, the order and
what did not happen. Its workshops **Testing by wrapping, not
replacing** and **Converting a mock test suite** pick up where this
page stops.

The next workshop is about a patch that was applied correctly and
changed nothing, because the caller had already taken its own
reference to the function.

**Why your patch did nothing** is next.

Press Finish below to move on.

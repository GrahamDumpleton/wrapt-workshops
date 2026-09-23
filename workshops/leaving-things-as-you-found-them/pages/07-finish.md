---
title: What you know now
requires: [quiz:restore-by-hand]
---

# What you know now

Every wrap function returns the wrapper it installed, and that object
is the handle for the patch:

- **`wrapt.is_wrapped_by(target_attribute, handle)`** says whether it
  is still in place, and **`wrapt.find_wrapper`** returns it, both
  matching by identity, both taking a `predicate` instead of a
  handle. Hand them the object `wrapt.resolve_path` returns, never
  what `getattr` gives, which is a fresh bound wrapper.

- **`wrapt.wrapper_chain`** yields the stack outermost first, ending
  at the original, and **`wrapt.unwrapped`** is the original.

- **`wrapt.unwrap_object(target, name, handle)`** removes the patch:
  restoring the original when the wrapper is outermost, deleting the
  slot when the wrap created it, splicing the wrapper out from
  beneath other wrapt wrappers, and refusing with
  `WrapperNotOutermostError` when a plain closure sits above.
  `WrapperNotFoundError` is the default when the patch is gone, and
  `missing_ok=True` is for cleanup that must not care.

```{quiz}
:id: restore-by-hand
:title: Restoring by hand
:shuffle: true
question: "Two tools have patched `Shop.buy`, the first with wrapt and the second by assignment over it. The first tool saved the original function before patching and now restores it with `Shop.buy = saved_original`. What happens to the second tool's patch?"
options:
  - text: "It is spliced out cleanly, since the first tool's patch was beneath it."
    explanation: "Assignment does no splicing. It writes one object over the attribute, whatever was there."
  - text: "It is gone: the assignment replaced the attribute wholesale, and the second tool's wrapper is no longer reachable from the class."
    correct: true
  - text: "It keeps working, because the second tool's wrapper closed over the first tool's wrapper, which still calls the original."
    explanation: "The second tool's wrapper still exists and still works if called, but nothing looks it up any more: the class now holds saved_original, so no call reaches it."
  - text: "Python raises, because an attribute holding a wrapper cannot be assigned over."
    explanation: "Assignment always succeeds. That is the problem: nothing stops one party from silently undoing another's patch."
explanation: "Restoring by assignment removes every patch above yours as well as your own, without an error. unwrap_object with the handle removes only yours, wherever it sits, and raises rather than guessing when the arrangement above is not one it can fix."
```

## Where this goes next

Everything here was removed by hand, with the handle. The next
workshop is about patches that remove themselves: one that lasts a
`with` block, one that lasts a function call, what each does when
something interferes, and how they compare with the
`unittest.mock.patch` you may already use.

**Patches that last a block** is next.

Press Finish below to move on.

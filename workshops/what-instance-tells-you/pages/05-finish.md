---
title: What you know now
requires: [quiz:telling-a-class]
---

# What you know now

`instance` is the object the wrapped function was bound to, and it
answers a question a closure decorator has to guess at:

| Decorator applied to | `instance` | `args` |
|----------------------|------------|--------|
| a plain function | `None` | the call's arguments |
| an instance method | the object | the arguments after `self` |
| a class method | the class | the arguments after `cls` |
| a static method | `None` | the call's arguments |
| a class | `None` | the constructor's arguments |

`self` and `cls` never appear in `args`, whether the method was called
on an object or through the class with the object passed explicitly,
and the wrapper calls `wrapped(*args, **kwargs)` because `wrapped` is
already bound. A wrapt decorator always goes outside `@classmethod`.

```{quiz}
:id: telling-a-class
:title: Telling a class from a function
:shuffle: true
question: "Inside the wrapper, instance is None. What tells you whether the decorator was applied to a class rather than a function or a static method?"
options:
  - text: "`isinstance(instance, type)`"
    explanation: "instance is None in all three cases, so there is nothing to test. The class is in wrapped, not in instance."
  - text: "`inspect.isclass(wrapped)`"
    correct: true
  - text: "`args[0]` being an instance of the class"
    explanation: "args holds the constructor's arguments, which can be anything. Nothing in the call tells you what wrapped is; wrapped itself does."
  - text: "`wrapped.__name__` starting with a capital letter"
    explanation: "A naming convention is not a test. wrapped is the class object, and inspect.isclass answers directly."
explanation: "When instance is None, wrapped is either a function or a class, and inspect.isclass(wrapped) separates the two. A static method looks exactly like a plain function, which is fine, because it is one."
```

## Where this goes next

Every decorator so far has been fixed: `show_context` always shows
everything. Real decorators take settings, `@retry(max_attempts=3)`,
and the next workshop gives a wrapt decorator arguments of its own in
three shapes, each beside the standard library version it replaces.

**Arguments to the decorator** is next.

Press Finish below to move on.

---
title: What you know now
requires: [quiz:why-bound]
---

# What you know now

`FunctionWrapper` is a callable proxy holding a function and a
wrapper, and it is what `@wrapt.decorator` builds. It records what
kind of thing it wrapped in `_self_binding`. Read through an
instance, its `__get__` returns a `BoundFunctionWrapper` carrying
`_self_instance` and `_self_parent`, bound the way the wrapped kind
binds, which is why the wrapper sees the shop for a method, the
class for a class method and `None` for a static method. A subclass
names its bound partner with `__bound_function_wrapper__`.

```{quiz}
:id: why-bound
:title: Why two classes
:shuffle: true
question: "Why does reading `shop.buy` return a `BoundFunctionWrapper` rather than the `FunctionWrapper` that is in the class?"
options:
  - text: "A `FunctionWrapper` is a descriptor, and its `__get__` returns a new object carrying the instance, the way a function's `__get__` returns a bound method."
    correct: true
  - text: "wrapt copies the wrapper into every instance when the class is created."
    explanation: "Nothing is copied, and the instances have nothing in their dictionaries. The bound wrapper is made on each read, by `__get__`, and points back at the one in the class as `_self_parent`."
  - text: "`BoundFunctionWrapper` is what `FunctionWrapper` becomes once it has been called once."
    explanation: "Calling changes nothing about the class. The bound form is about being read through an instance, and `Shop.__dict__[\"buy\"]` stays a `FunctionWrapper` however many calls are made."
  - text: "The class body replaced the `FunctionWrapper` with a bound one when `Shop` was defined."
    explanation: "The cell checked `bound._self_parent is Shop.__dict__[\"buy\"]`, and it was true: the class holds the unbound wrapper, and the bound one is made per read."
explanation: "The descriptor protocol is how a function becomes a method, and `FunctionWrapper` takes part in it, returning a bound wrapper that knows its instance and binds according to what was wrapped."
```

## Where this goes next

Every proxy so far declared its special methods by hand, or was a
class that came with them. The next workshop is about a proxy that
looks at its target when it is made and adds whatever that target
has, and what that convenience costs.

**A proxy that fits its target** is next.

Press Finish below to move on.

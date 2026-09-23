---
title: What you know now
requires: [quiz:why-getattr-fails]
---

# What you know now

A monkey patch replaces an attribute of a module or a class after the
fact, in the running process, without touching the source. By
assignment it works on a function and on an instance method, and it
breaks a static method and a class method, because `getattr` on a
class runs the descriptor protocol and hands back a plain function or
a bound method rather than the `staticmethod` or `classmethod` object
the class holds. Whatever you wrap around that, and whatever you
save to restore later, is the wrong thing.

`wrapt.wrap_function_wrapper(target, "Class.method", wrapper)` reads
the class namespace along the method resolution order, wraps the raw
object it finds, and installs a `FunctionWrapper` that binds the way
that object would. The wrapper is the four argument function from
`@wrapt.decorator`, `instance` follows the same rules, and the call
returns the wrapper it installed, which is the handle for the patch.

```{quiz}
:id: why-getattr-fails
:title: Why the class, not getattr
:shuffle: true
question: "Why does `Kiosk.empty()` return a `Shop` after `Shop.empty = logged(Shop.empty)`, and a `Kiosk` after `wrapt.wrap_function_wrapper(shop.cart, \"Shop.empty\", notify)`?"
options:
  - text: "wrapt copies the classmethod decorator onto the wrapper, and functools.wraps does not."
    explanation: "Nothing is copied either way. wrapt wraps the classmethod object itself, so there is no decorator to copy."
  - text: "The closure holds the bound method getattr produced, already bound to Shop, while the FunctionWrapper holds the classmethod object and binds it to whichever class the call came through."
    correct: true
  - text: "Assignment on Shop does not affect Kiosk, so Kiosk.empty() calls the original, which returns a Shop."
    explanation: "Kiosk inherits empty from Shop, so it sees the patched attribute either way. The original, unpatched, would have returned a Kiosk."
  - text: "wrap_function_wrapper patches Kiosk as well as Shop, so each class gets a wrapper bound to itself."
    explanation: "One patch was installed, on Shop, where empty is defined. Kiosk finds it through inheritance and the FunctionWrapper binds it to Kiosk on lookup."
explanation: "getattr(Shop, \"empty\") is a method object bound to Shop, and a closure around it stays bound to Shop forever. wrap_function_wrapper reads Shop.__dict__[\"empty\"], the classmethod object, and its FunctionWrapper runs the descriptor protocol on every lookup, so a lookup through Kiosk binds to Kiosk."
```

## Where this goes next

`Shop` had one method of each of the three kinds. The next workshop
puts one wrapper on every kind of target there is, dunder methods and
a method of a nested class among them, reads what `instance` holds in
each case, patches through a string path, and patches one object
without touching the others.

**Patching every kind of method** is next.

Press Finish below to move on.

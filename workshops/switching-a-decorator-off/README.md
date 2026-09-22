# Switching a decorator off

Use the `enabled` argument to `wrapt.decorator` to switch a decorator
off. With a boolean the decision is made once, when the decorator is
applied, and the original function comes back untouched. With a
callable or a settings object it is made on every call, and the
wrapper is bypassed when the answer is no. The standard library has no
answer to this at all.

Ten minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

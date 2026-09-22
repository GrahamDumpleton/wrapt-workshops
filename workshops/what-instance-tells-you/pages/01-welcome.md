---
title: Welcome
requires: [verify:setup-works]
---

# What instance tells you

A wrapt wrapper takes four arguments, and the second one, `instance`,
is the one that makes wrapt different. It holds the object the
wrapped function was bound to when it was called: nothing for a plain
function, the object for a method, the class for a class method.

A closure decorator has no such argument. When it lands on a method,
`self` turns up as the first positional argument, and the decorator
has to guess whether that first argument is an instance or just the
first argument. This workshop puts one decorator on five kinds of
target and reads what `instance` holds for each, so that you never
have to guess.

## The environment

wrapt is not installed in this JupyterLab, so the workshop needs an
environment of its own, inside the workshop directory, with a kernel
for it. The step below creates it, which takes a little while.

```{environment-create}
:id: create-env
:title: Create the workshop environment
```

```{hint}
:title: If the environment already exists
The step reports that it already exists and does nothing more, so it
is safe to click again. On a page without this step, a banner at the
top of the panel offers to create the environment instead, and an
environment created from the banner counts here. Restart, in the
panel's menu, removes the environment along with the notebook, and
this step creates it again.
```

## The notebook

The step below creates the notebook with the one decorator the whole
workshop uses. `show_context` records the name of the wrapped
function, `instance` and `args` in a list, prints them, and calls
through. Applied to a plain function first.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # What instance tells you
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    import wrapt

    calls = []

    @wrapt.decorator
    def show_context(wrapped, instance, args, kwargs):
        calls.append((wrapped.__name__, instance, args))
        print(f"{wrapped.__name__}: instance={instance!r} args={args!r}")
        return wrapped(*args, **kwargs)

    @show_context
    def greet(name):
        return f"Hello, {name}!"

    greeting = greet("Alice")
    print(greeting)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

`instance=None args=('Alice',)`. A plain function is bound to nothing,
and its arguments arrive in `args` exactly as the caller passed them.

```{verify}
:id: setup-works
:label: show_context records None for a plain function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
calls == [("greet", None, ("Alice",))] and greeting == "Hello, Alice!"
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "What instance tells you" from the
picker at the top right of the notebook, and run the cell again.
```

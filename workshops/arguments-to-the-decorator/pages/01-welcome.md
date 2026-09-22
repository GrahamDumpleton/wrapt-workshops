---
title: Welcome
requires: [verify:setup-works]
---

# Arguments to the decorator

A decorator that takes settings, `@retry(max_attempts=3)`, is a
different shape from one that does not. `retry(max_attempts=3)` runs
first, and whatever it returns is what gets applied to the function.
With closures that means three nested functions: one for the
settings, one for the function, one for the call.

wrapt removes a layer, and offers two other shapes besides. This
workshop writes the same `retry` in each of them, and ends on the
decorator that works both as `@debug` and as `@debug(prefix="###")`,
which wrapt handles without guessing.

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

The step below creates the notebook with the closure version of
`retry`, the one the decorator workshops built, for comparison. The
function it protects, `fetch_price`, fails twice and then succeeds,
counting its attempts as it goes.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Arguments to the decorator
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    import wrapt

    attempts = {"count": 0}

    def retry(max_attempts):
        def decorator(func):
            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                for attempt in range(1, max_attempts + 1):
                    try:
                        return func(*args, **kwargs)
                    except ConnectionError:
                        if attempt == max_attempts:
                            raise
                        print(f"attempt {attempt} failed, retrying")
            return wrapper
        return decorator

    @retry(3)
    def fetch_price(item):
        """Look up the price of an item from a flaky service."""
        attempts["count"] += 1
        if attempts["count"] < 3:
            raise ConnectionError("the price service is down")
        return 0.5

    price = fetch_price("apple")
    print("price:", price, "after", attempts["count"], "attempts")
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

Two failures, then the price. Count the `def`s: `retry` takes the
setting, `decorator` takes the function, `wrapper` takes the call.
Each layer exists because of when it runs, and the wrapper reads
`max_attempts` through two closures.

```{verify}
:id: setup-works
:label: The closure retry gets the price on the third attempt
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and price == 0.5 and attempts["count"] == 3
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Arguments to the decorator" from
the picker at the top right of the notebook, and run the cell again.
```

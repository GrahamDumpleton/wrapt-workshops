---
title: Welcome
requires: [verify:setup-works]
---

# Wrapping async functions

Calling an `async def` function does not run it. It makes a
coroutine, and the coroutine runs when something awaits it. A
decorator written for ordinary functions does not know that, so it
wraps the call that makes the coroutine and is finished before any
work happens. Nothing fails; the decorator just measures, logs or
guards the wrong thing.

This workshop starts with that silent failure, fixes it with a wrapper
that is itself `async def`, writes a timer that serves both kinds of
function, and then uses `wrapt.synchronized` on coroutines, where it
switches to an `asyncio.Lock` on its own and where one property of
that lock needs knowing about.

The kernel runs an event loop of its own, so cells here use
`await` at the top level, and never `asyncio.run()`, which cannot
start a loop inside a running one.

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

The step below creates the notebook with an `async def` version of
`fetch_price`, which sleeps for twenty milliseconds so that a timer
has something to see, and a dictionary for the timers to report into.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Wrapping async functions
    Each step of the workshop adds a cell below.
- code: |
    import asyncio
    import inspect
    import time

    import wrapt

    PRICES = {"apple": 0.5, "pear": 0.75, "fig": 2.0}

    async def fetch_price(item):
        """Look up the price of an item, slowly."""
        await asyncio.sleep(0.02)
        return PRICES[item]

    reported = {}

    price = await fetch_price("apple")

    print("wrapt:", wrapt.__version__)
    print("price:", price)
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
price of an apple, awaited at the top level.

```{verify}
:id: setup-works
:label: wrapt is importable and the coroutine was awaited
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and price == 0.5
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Wrapping async functions" from
the picker at the top right of the notebook, and run the cell again.
```

---
title: Welcome
requires: [verify:setup-works]
---

# Synchronising calls

A function that reads a value, works on it and writes it back is not
safe to call from two threads at once, and the standard fix is a lock:
make one, keep it somewhere, and take it around the critical section.
The boilerplate is small. The question of where to keep the lock is
not, because a method wants a lock per instance, a class method wants
one per class, and a function wants one of its own, and the code that
takes the lock has to find the right one every time.

`wrapt.synchronized` answers the question the way these workshops
have been answering questions: from `instance`. This workshop makes a
race visible, fixes it, then reads the lock off each kind of object to
see
where it went, and finishes with the context manager form and locks
of your own.

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

The step below creates the notebook with a counter, a helper that
runs some calls in threads and reports how long they took, and one
setting. Python lets a thread run for five milliseconds before
switching to another, and the cells here are over in about one, so a
race would rarely get the chance to show. The setup asks Python to
switch every ten microseconds instead, which changes nothing about
what is correct and everything about how often the race is seen.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Synchronising calls
    Each step of the workshop adds a cell below.
- code: |
    import sys
    import threading
    import time

    import wrapt

    counter = {"total": 0}

    def run_threads(*calls):
        """Run each (function, args) pair in a thread; return the elapsed milliseconds."""
        threads = [threading.Thread(target=function, args=args) for function, args in calls]
        start = time.perf_counter()
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        return round((time.perf_counter() - start) * 1000)

    sys.setswitchinterval(0.00001)

    print("wrapt:", wrapt.__version__)
    print(f"threads switch every {sys.getswitchinterval() * 1_000_000:.0f} microseconds")
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The cell prints the wrapt version the environment installed and the
switch interval.

```{verify}
:id: setup-works
:label: wrapt is importable and the counter is defined
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
wrapt.__version__ and counter["total"] == 0
```

```{hint}
:title: If the check fails
A `NameError` on `wrapt` or a `ModuleNotFoundError` means the notebook
is not using the workshop's kernel: create the environment with the
first step, pick the kernel named "Synchronising calls" from the
picker at the top right of the notebook, and run the cell again.
```

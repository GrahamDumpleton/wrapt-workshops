# wrapt workshops: outline

The design of the collections in this repository: how they are
organised, what each workshop covers, its name and format, and the
decisions that cut across all of them. It is a living document. Read it
before adding a workshop, and update it when one is added, changed or
dropped: the status table at the end records where each workshop
stands, and the open questions section shrinks as they are settled.

## What this repository is

Guided JupyterLab workshops for [wrapt](https://wrapt.readthedocs.io),
the Python module for decorators, wrappers and monkey patching, in
collections that are each a course of their own. The first collection,
**Decorators with wrapt**, is twelve workshops on writing decorators
with wrapt, each shown beside the standard library version it
replaces. A second collection on monkey patching is planned and will
sit beside it. The two share this repository's tooling and nothing
else: each has its own index, id, numbering and audience.

The decorators collection is the companion to the
[decorator workshops](https://github.com/GrahamDumpleton/decorator-workshops),
which teach decorators with the standard library alone. A learner who
has done those knows what a closure is, why `functools.wraps` exists,
what goes wrong on methods and why the descriptor protocol is the
answer. This collection assumes that much and shows what wrapt does
about each of them. It does not require the other collection: every
workshop restates the standard library side in a cell and a sentence
before showing the wrapt one.

## Source material

wrapt's own documentation and source are the authority, read from the
`reference/wrapt` submodule at the release the workshops teach, never
from memory:

- `docs/decorators.rst`: the wrapper signature, decorators with
  arguments and with optional arguments, processing the call's
  arguments, decorators with state, enabling and disabling, what
  introspection sees, and the rules for functions, instance methods,
  class methods, static methods and classes.

- `docs/bundled.rst`: `lru_cache`, `synchronized` in its synchronous
  and asynchronous forms, the calling convention markers,
  `with_signature` and `bind_state_to_wrapper`.

- `docs/examples.rst`: tracking call state, checking argument types
  and validating argument values, which are the state class pattern the
  collection is built around.

- `docs/issues.rst`: `classmethod.__get__()`, `super()` with a
  decorated class, and the rest of what does not work and why.

Python's own documentation is the authority for the standard library
side of each comparison, and every claim about what Python does is
checked against the interpreter the learner gets before it is written
down: 3.14, which is what Binder and the codespace run.

## Shape of the decorators collection

One ordered collection, in three movements, with no visible break
between them: the collection is numbered straight through and each
Finish dialog offers the next.

**Understanding wrapt** (1 to 3). The wrapper signature, what
`instance` holds, and how a decorator takes arguments. After these
three the learner can write any decorator they could write with the
standard library, with less code and correct on methods.

**Inside the wrapper** (4 to 7). What a wrapper does with the call's
arguments, how it keeps state, how it is switched off, and how one
decorator serves every kind of target. This is where wrapt stops being
a shorter spelling and starts doing things the closure version cannot.

**Patterns worth knowing** (8 to 12). Five decorators worth having
written or used once: validation, caching, synchronisation, async, and
signature changing. Three of them are decorators wrapt ships, so the
learner leaves knowing what is in the box.

Ten to twenty minutes each, about three hours in total. Each workshop
is self-contained and ships whatever code it needs, so it can be taken
on its own, even though the order is the order to take them in.

## Naming

Directory names are short kebab-case phrases naming the question, not
the mechanism, with no numeric prefix. The collection index carries the
order, and unnumbered names stay stable as workshops are inserted,
split or moved. Titles are sentence case and read as what the learner
will do.

Names are unique across every collection in this repository, because
all workshops share the one `workshops/` directory the extension
lists, and distinct from the names of the decorator workshops, because
a learner may have both collections subscribed in one JupyterLab and
the browser matches a local directory to a collection by name. So
`decorating-methods`, `caching-results` and
`decorating-async-functions` are taken, and the workshops here that
cover the same ground are named differently.

## The workshops

### 1. `your-first-wrapt-decorator`: Your first wrapt decorator

The wrapper signature, and what it buys.

Start from the closure decorator the learner already knows, a `@timer`
with `functools.wraps`, and note in one cell what it gets right on
3.14: the name, the docstring, and, because `inspect` follows
`__wrapped__`, the signature too. Then the same decorator with
`@wrapt.decorator`: one function of four arguments, `wrapped`,
`instance`, `args` and `kwargs`, and no inner function at all. Apply
it, call it, and ask the same questions: `__name__`, `__doc__`,
`inspect.signature`, `inspect.getsource`, `__wrapped__`. All correct,
with nothing copied, because the decorated function is not a function
carrying copied attributes but a `FunctionWrapper` that forwards every
attribute lookup to the original. Show `type(timed)` and
`isinstance(timed, wrapt.FunctionWrapper)`, and that
`inspect.signature(timed, follow_wrapped=False)` is still the
original's, which is the one thing the closure version cannot manage.

Close with `instance`, unexplained: print it from a plain function and
get `None`, and say that the next workshop is about the cases where it
is not.

- Format: notebook. Checks read the wrapper's attributes and
  `type(...)` from the learner's kernel.

- Length: 15 minutes.

### 2. `what-instance-tells-you`: What instance tells you

The conceptual heart of wrapt, and the payoff for anyone who has hit
the method problem.

One `@show_context` decorator that prints `instance` and `args`.
Apply it to a plain function, an instance method, a class method, a
static method and a class, call each, and read the five results
together: `None` for the function and the static method, the object
for the method, the class for the class method, and `None` again for
the class with `inspect.isclass(wrapped)` telling that case apart.
Then the detail that removes the usual bug: `args` never contains
`self`, because the instance arrives in `instance` and `wrapped` is
already bound, so the wrapper calls `wrapped(*args, **kwargs)` and
never passes the instance itself. Call the method through the class
with an explicit self, `Shop.buy(shop, "apple")`, and see wrapt
normalise it so the wrapper cannot tell the difference.

Then the one ordering rule. Put the decorator above `@classmethod` and
`instance` is the class; put it below and `instance` is `None` and the
call looks like a plain function, because `classmethod.__get__()` does
not apply the descriptor protocol to what it wraps. The rule is always
outside, and `docs/issues.rst` says why it is Python's bug rather than
wrapt's, including the 3.9 fix that 3.13 reverted. A short
comparison cell reminds the learner what the standard library version
of this workshop looked like: `TypeError` from a class-based decorator
on a method, and a rule about ordering that was the other way round.

- Format: notebook. A quiz asks for the five values before the cell
  runs.

- Length: 15 minutes.

### 3. `arguments-to-the-decorator`: Arguments to the decorator

Arguments to the decorator itself, three ways, each beside the
standard library shape it replaces.

Start with the triple nested closure for `@retry(max_attempts=3)`,
shown and not dwelt on. Then the wrapt version: an outer function that
takes the arguments and returns a function decorated with
`@wrapt.decorator`, one level of nesting gone, with the arguments
reaching the wrapper as closure variables. Keyword only arguments with
`*`, so a call site cannot get the order wrong. Then the class form:
a class whose `__init__` takes the arguments and whose `__call__` is
the wrapper under `@wrapt.decorator`, which is where a decorator with
several settings and some helper methods wants to live.

The last page is the dual-use question the standard library collection
ended its arguments workshop on: a decorator that works as `@debug`
and as `@debug(prefix=">>>")`. The stdlib answer is callable detection
or a sentinel. The wrapt answer is a `wrapped=None` first parameter and
`wrapt.partial(...)` when it is missing, which is a
`PartialCallableObjectProxy` that keeps the decorator introspectable.
Both forms applied, both checked.

- Format: notebook.

- Length: 15 minutes.

### 4. `handling-the-arguments`: Handling the arguments

What a wrapper does with the call's arguments, which is the one place
wrapt makes the learner do slightly more work than a closure, for a
reason worth knowing.

Start with why `args` and `kwargs` arrive as a tuple and a dict and are
never bound to names: a wrapper written as `(wrapped, instance, *args,
**kwargs)` is wrong, and one that names the parameters is wrong too,
because a wrapped function may have a parameter called `wrapped` or
`instance`. Then the documented pattern for reaching the arguments: a
nested `_execute(arg1, arg2, *_args, **_kwargs)` that Python binds for
you, called with `*args, **kwargs`, so the wrapper sees the arguments
by name whether the caller passed them positionally or by keyword.
Show why reading `args[0]` directly is wrong with a keyword call.

Then the general tool: `inspect.signature(wrapped).bind(*args,
**kwargs)` with `apply_defaults()`, which gives every argument by name
including the defaults, and, because `wrapped` is already bound when
it is a method, needs no special case for `self`. Use it to normalise
one argument and forward the rest. Close with the return value:
transform it, wrap it, and see that a wrapper is free to return
something else entirely.

- Format: notebook.

- Length: 15 minutes.

### 5. `keeping-state`: Keeping state

The workshop the collection's version pin was chosen for.

Start with the trap. The standard library `@count_calls` kept its
count on `wrapper.call_count`. Do the same on a wrapt decorator,
`timed.count = 0`, and find the attribute on the wrapped function
instead: a `FunctionWrapper` forwards attribute assignment to what it
wraps, which is right for `__doc__` and wrong for state. The `_self_`
prefix keeps an attribute on the wrapper, and is the answer for a quick
flag, but it is not where state belongs.

Then the state class pattern from wrapt's own examples. A `CallTracker`
class with `call_count` in `__init__` and a `__call__` method that is
the wrapper, taking `self` and then the four arguments, under
`@wrapt.decorator`. Each `CallTracker()` is a decorator with
state of its own. Then `@wrapt.bind_state_to_wrapper(name="tracker")`
above it, so the tracker is reachable as `add.tracker.call_count`
through the decorated function, and, for a method, through the class
and through an instance alike, with the count shared across instances
because it lives on the wrapper. Then the static `track` method that
gives it optional arguments, `@CallTracker.track` and
`@CallTracker.track(call_count=10)`, which is the dual-use pattern
from workshop 3 again in the class form.

The closure with `nonlocal` is shown for completeness, and shown
failing to offer the count to anyone outside, which is why the class
wins.

The wrapper method sits under `wrapt.decorator`, as
`docs/decorators.rst` has it, not `wrapt.function_wrapper` as
`docs/examples.rst` and `docs/bundled.rst` have it. Both work, and
were checked to behave identically on 2.4.1 across a function, an
instance method, a class method, a static method and the `track`
form: `bind_state_to_wrapper` only needs a wrapper it can bind with
`__get__` and set an attribute on with `__self_setattr__`, and both
produce a `FunctionWrapper` that has both. `wrapt.decorator` is the
one the learner has used since workshop 1, and the one that takes
`enabled`, which workshop 6 puts on this same tracker, so a second
decorator would be a thing to explain that changes nothing. The page
says in a sentence that the examples show the class over
`function_wrapper`, the lighter decorator kept for monkey patching,
and that either works.

- Format: notebook.

- Length: 20 minutes.

### 6. `switching-a-decorator-off`: Switching a decorator off

Short, and a thing the standard library has no answer to at all.

The `enabled` keyword to `wrapt.decorator`. With a boolean, the
decision is made when the decorator is applied: `enabled=False` returns
the original function untouched, so `type(function)` is `function`
rather than `FunctionWrapper` and there is no runtime cost at all.
With a callable, the decision is made on every call: the callable is
asked, and when it says no the wrapper is bypassed and the original
called directly. Build a `DEBUG` flag that switches a logging
decorator on and off at runtime, then a settings object whose truth
value decides, and confirm from the call count of the wrapper that it
was really bypassed.

- Format: notebook.

- Length: 10 minutes.

### 7. `one-decorator-for-everything`: One decorator for everything

The universal decorator, and stacking, which together close the first
two movements.

Write the decorator from the rules of workshop 2: `instance is None`
and `inspect.isclass(wrapped)` for a class, `instance is None`
otherwise for a function or a static method, `inspect.isclass(instance)`
for a class method, and an instance method otherwise. Apply one
decorator to all five, and have it do something different for each,
which is what the standard library version of this needed a `__get__`
and a separate class decorator to approach. Then the robustness rule
from the docs: a universal decorator applied where it is not supported
raises at the call, rather than doing something half right.

Then stacking. Two wrapt decorators, applied one way and run the
other, as with any decorator. A wrapt decorator over a
`functools.wraps` one and under it, both working, with a look at what
`__wrapped__` shows through each. Finish by walking a three deep chain
with `wrapt.wrapper_chain()` and jumping to the bottom with
`wrapt.unwrapped()`, which see through wrapt wrappers and stdlib ones
alike.

- Format: notebook.

- Length: 15 minutes.

### 8. `validating-arguments`: Validating arguments

The first pattern, and the state class from workshop 5 doing real work.

A `TypeChecker` whose `__call__` is the wrapper, with the signature
computed from `wrapped` on the first call and cached on the instance,
so it is computed once and, because `wrapped` is bound by then, never
includes `self` or `cls`. Bind the arguments, apply defaults, compare
each against its annotation, raise a `TypeError` that names the
argument. Then a `ValueChecker` that takes constraint callables by
parameter name, using the same optional arguments pattern. Apply both
to a function, an instance method, a class method and a static method
without changing a line.

Close with the stacking order: type checking on top, so a wrong type is
reported as such rather than reaching a constraint that fails on it in
some other way. Predict, then run, both orders.

- Format: notebook.

- Length: 15 minutes.

### 9. `caching-methods`: Caching methods

Picks up where the standard library caching workshop stopped, on the
memory leak that comes free with caching a method.

Put `functools.lru_cache` on a method and find the three problems
`docs/bundled.rst` lists: every instance shares one `maxsize` budget,
the cache holds every instance alive through its keys, and an instance
with `__eq__` and no `__hash__` cannot be cached at all. Show each in
a cell. Then `wrapt.lru_cache`, the same decorator with a cache per
instance stored on the instance, so each gets its own budget, instances
are collected when they go, and hashability is not asked for.
`cache_info()` and `cache_clear()` on the bound method operate on that
instance's cache; on a function, a class method or a static method
there is one shared cache, as with the standard library. Finish with
the pickling note: the per instance cache is not picklable, and a
`__getstate__` that drops the `_lru_cache_` attributes fixes it.

- Format: notebook.

- Length: 15 minutes.

### 10. `synchronising-calls`: Synchronising calls

The one workshop that needs real threads, which is part of why the
collection runs on CPython.

Start with the race: a counter incremented from several threads, coming
up short. `@wrapt.synchronized` on the function fixes it with a lock
created on first call and reused. Then the interesting part, where the
lock lives. On an instance method it is per instance, so two objects
proceed in parallel and two callers on one object are serialised; on
a class method it is per class; on the class itself it is one lock for
everything; on a static method it is on the function. Show two of
these with threads and timing, and the rest by reading the lock
attribute off the object. Then the context manager form,
`with wrapt.synchronized(self):`, sharing the same lock as the
decorated method on the same object, so a critical section in an
undecorated method excludes a decorated one. Close with an explicit
lock or semaphore passed in, and the note that the automatic lock is
an `RLock`, so a synchronised method may call another on the same
object without deadlocking.

The standard library comparison is a page of `threading.Lock`
boilerplate and the question of where to keep the lock, which is the
whole point.

- Format: notebook. Threads run for milliseconds; the race is made
  visible with a short spin rather than a sleep.

- Length: 15 minutes.

### 11. `wrapping-async-functions`: Wrapping async functions

The pattern the standard library collection ended on, with wrapt's
answers.

Start with the same silent failure: a synchronous timer on an
`async def` times the creation of a coroutine, not its run. Then a
wrapper that is itself `async def` under `@wrapt.decorator`, which
awaits `wrapped(*args, **kwargs)` and works because the wrapper's
return value, a coroutine, is what the caller awaits. Then one
decorator for both kinds: check `inspect.iscoroutinefunction(wrapped)`
in the wrapper and return either the result or an inner coroutine that
awaits it, so a single `@timer` serves `def` and `async def`. Then
`@wrapt.synchronized` on an `async def`, which switches to an
`asyncio.Lock` by itself, and its `async with` form, with the
non-reentrancy of the asyncio lock stated and the shadow coroutine idiom
from the docs shown once. The calling convention markers,
`mark_as_sync`, `mark_as_async` and the two adapters, are named on the
last page as the tools for a stack whose convention the inner function
does not reveal, and not taught.

Notebook cells allow top level `await`, so the learner writes
`await slow()` directly. `asyncio.run()` is never used: it cannot be
called inside the kernel's running loop.

- Format: notebook, with top level `await` throughout.

- Length: 15 minutes.

### 12. `changing-the-signature`: Changing the signature

Short, and the last thing wrapt does about introspection.

A decorator that supplies an argument the caller no longer passes, a
session or a request id, is a signature changing decorator, and every
tool that asks the decorated function its signature is now told a lie:
`help()` and `inspect.signature()` show a parameter the caller must
not pass. `wrapt.with_signature` fixes what introspection sees without
touching the function: with a prototype function whose signature is
the truth, and with a factory that derives the new signature from the
wrapped function's own, which is what a decorator that always removes
one parameter wants. Show it on a method, where the bound view strips
`self` as Python's own does, and stacked under another wrapt decorator,
where the overridden signature still comes through. The `adapter`
argument to `wrapt.decorator` is named as the older mechanism this
replaces, and not taught.

- Format: notebook.

- Length: 10 minutes.

## Topics not covered

Several topics from the earlier plan for a wrapt course were
considered and left out, and the reasons are worth recording so the
decisions can be revisited rather than rediscovered.

Subclassing `FunctionWrapper` and `BoundFunctionWrapper`, with
`__bound_function_wrapper__` and `_self_parent`, is the machinery
under the decorator API and belongs to a collection about proxies, if
anywhere. An aspect oriented capstone with before, after and around
advice is composition dressed up; workshop 7 covers composition.
Contracts, deprecation, retry and context adaptive decorators are
further turns of the wrapper shape that workshops 8 to 12 already
establish, and each is a page rather than a workshop. A migration
workshop, converting stdlib decorators to wrapt, is redundant because
every workshop here is the migration. The calling convention markers
and the sync and async adapters are a footnote to workshop 11. Object
proxies, `ObjectProxy` and its lazy and automatic variants, are the
foundation of monkey patching and are for that collection.

## Decisions that cut across the workshops

**JupyterLab only, on Python 3.14.** JupyterLite was the first target,
as it is for the decorator workshops, and a probe workshop did run
there: the Pyodide kernel bundles wrapt, so `import wrapt` works in
the browser with no install step. But it bundles 2.1.2, and the site
builder has no way to bundle a newer release, so `bind_state_to_wrapper`
and `lru_cache` were out of reach and the version could only move when
the kernel's Pyodide did. JupyterLite is right for teaching the
language and starts to limit things once a third party package is the
subject, so it was dropped, and the collection runs on a real CPython
on Binder, in Codespaces and locally. That also brings threads, which
workshop 10 needs. The full set of rules that follow is in AGENTS.md.

**wrapt pinned per workshop, to the reference submodule.** Each
workshop's `requirements.txt` names the release, and `reference/wrapt`
is checked out at its tag, so the docs an agent reads are the docs of
the version a learner runs. Nothing installs wrapt into the JupyterLab
environment. The extension builds each workshop's environment on first
open, and the Binder and Codespaces images carry a wheelhouse so that
step does not wait on PyPI.

**One format.** Every workshop is a notebook. There is no terminal
workshop here and no mixed workshop, because the subject never needs
one: decorators are things you do to Python objects, and a notebook is
where Python objects live.

**Learners never type code.** Every cell arrives through a
`cell-insert` action, so the learner's attention goes on reading and
predicting, not on typing and typos.

**The standard library side is always shown, and always brief.** The
comparison is what makes this collection different from wrapt's own
documentation, so no workshop skips it; a cell and a sentence is the
usual weight, since the decorator workshops carry the full treatment.

**Checks.** Every page ends with something checkable. The substrate is
`learner-kernel` for what the learner's notebook holds, triggered by
`cell-executed <tag>`. Checks say what is wrong rather than that
something is: "the count is on the wrapped function, so the attribute
was set without the `_self_` prefix" rather than "check failed". A
`hint` beside a check says what to look at when it fails.

**Prediction before execution.** Where a result is surprising, and in
this subject it often is, the page asks for a prediction in a `quiz`
before the cell runs: the five values of `instance`, the attribute
that lands on the wrapped function, the stacking order of the two
checkers. The self-test answers quizzes correctly, so this costs
nothing in CI.

**Examples.** No single running example across the collection. A small
recurring cast, a `greet`, a slow `fetch_price` and a `Shop` with a
`buy` method, is reused where it fits, so the early workshops feel
continuous and so that a reader of the decorator workshops meets
familiar names.

**Timing and sleeps.** Every sleep is tens of milliseconds, and the
race in workshop 10 is made visible with a short spin, so a page never
pauses for long enough to read as broken.

**Platforms.** Every manifest declares `platforms: [linux, macos]`. No
workshop runs a command, so nothing is platform specific, but Windows
is not declared until it has been tried.

**Self-test.** A workshop is done when `just lint` is clean and
`just test <name>` is green. The self-test builds the workshop's
environment as a learner's session would, so it also proves the
requirements install.

## Collections and the repository

**Several collections, one repository, one catalog.** The decorators
collection and the planned monkey patching collection are different
courses for different people, so each is a collection of its own:
numbered from one, with its own id, description and Finish sequence,
and each can be subscribed to or linked alone. They share the tooling,
the submodules, the images and CI, which is the reason for one
repository. A `catalog.json` at the root names every collection by
relative path, so one URL offers them all.

**Layout.** Every workshop of every collection sits directly under
`workshops/`, because the extension lists only the directories
directly under its one workshops directory; which collection a
workshop belongs to is recorded in the indexes alone. Each index lives
in a directory of its own, `collections/<name>/collection.json`, so
the directory can hold an icon and anything else the collection needs,
and the conventional file name keeps the directory form working
everywhere a tool accepts one.

**Order.** The order of a collection is the list of workshop names in
the Justfile, which the `index-<collection>` recipe passes to
`jupyter workshop index` one by one. Named that way, the tool writes
the index in the order given, which is also how a workshop is inserted
into the middle of a course. A name in the list whose directory does
not exist yet is skipped, so the index can be refreshed while a
collection is being written.

**Ids.** `grahamdumpleton.me/wrapt/decorators` now,
`grahamdumpleton.me/wrapt/monkey-patching` later: a prefix for the
product, then the course, leaving room for more under the same prefix.
An id is the collection's identity to the analytics service and must
never change, so it was chosen before any workshop was written. The
other collections use flatter ids; revising them to match is a
separate job for another time.

**Where the collections meet the browser.** The Available section of
the workshop browser groups by collection, so anyone who subscribes
from their own JupyterLab sees the courses apart. The Installed
section is one list, ordered by collection and then by each
collection's order, with every card carrying its collection's title
and its own numbering but no heading between the groups, and that is
what the Binder and Codespaces images show, since everything is
installed there. With one collection it is exactly the numbered list
it is today. When the second collection arrives it is worth grouping
the Installed section by collection in jupyterlab-workshop, with the
heading the Available section already uses, and that change is in the
extension rather than here. The Finish dialog offers the next workshop
of the same collection and stops at its end; the last workshop's
`finish` text names where to go next.

**Binder, Codespaces and local runs.** The Binder and Codespaces
settings subscribe to each collection's index by relative path, so the
workshops are listed under their collection's title in its order, and
disable opening other directories, subscribing to other collections
and author mode, which keeps a visitor to the workshops the link was
for. The catalog is not subscribed there, since with subscribing
disabled it would offer nothing. A local `just lab` opens on a launch
link naming the catalog and the decorators collection, which adds both
for the session; a launch link carries one collection, so when the
second collection exists the local start lists one and offers the
other through the catalog.

The two images differ on trust, on purpose. A Binder session is an
anonymous container thrown away at the end, so the workshops are
forced to trusted and no dialog interrupts a visitor who chose the
link. A codespace belongs to the reader's GitHub account and persists,
so it trusts nothing for them and JupyterLab starts without the
codespace's GitHub token.

**CI.** `.github/workflows/test.yml` lints the catalog, every
collection index and every workshop, and self-tests every workshop, on
each push, spelling the commands out rather than running the Justfile
so the job needs nothing but uv. Linux only: no workshop runs a
command, so there is nothing platform specific to get wrong.

## Extension features the workshops use

The patterns settled from the extension's documentation in
`reference/jupyterlab-workshop/docs`, so each workshop does not
rediscover them. The authoring skill covers the syntax; this records
the choices.

**Environment first.** The welcome page opens with `environment-create`,
so the learner sees the environment being made and the self-test's
notebooks run on the workshop's kernel; a hint beside it says it is
safe to click again and that the banner on other pages does the same.
The manifest declares `install-packages`, an `environment` with
`requirements: requirements.txt` and a kernel named `workshop-<name>`.

**Notebook pages.** After the environment, the welcome page creates the
notebook with `notebook-create`; each later step is one `cell-insert`
with a tag and `:run: true`, so a page reads as prose, cell, check. The
check is a `learner-kernel` verify, an expression evaluated in the
learner's own kernel, triggered by `cell-executed <tag>`, asking the
question directly. Pages gate on those verifies with `requires`.

**One idea per cell.** A cell shows only its last expression, so a cell
that changes state and then makes a call shows the call and never the
change. Multi-line strings and anything whose shape matters are shown
with `print()`.

**Shipped files.** Where a workshop needs code the learner should not
have to read being typed in, it ships under `files/`, which the
extension copies into the workspace on first open. Most workshops need
none: the code is the point, so it goes in cells.

## Open questions

- **Analytics.** The Binder and Codespaces settings carry no analytics
  block yet, and the welcome messages say nothing about reporting.
  When tokens are minted for `wrapt-binder` and `wrapt-codespaces`,
  and the collection's own block for its index, the blocks go into
  `binder/postBuild`, `.devcontainer/setup.sh` and
  `collections/decorators/collection.json`, and both welcome messages
  gain the paragraph the other collections carry.

- **The GitHub repository.** The README, the catalog and the indexes
  assume `https://github.com/GrahamDumpleton/wrapt-workshops`, which
  does not exist yet. Nothing here needs it until the first push, but
  the Binder and Codespaces links do not work until then.

- **Grouping the Installed section by collection** in
  jupyterlab-workshop, before the monkey patching collection ships.

## Status

The writing order is the collection order: the first workshop settles
the manifest, the environment step, the notebook format and the kernel
checks, and each later one adds one idea to a format that already
works. Workshops 5 and 8 are written together, since 8 is 5's pattern
put to work.

| # | Workshop | Status |
|---|----------|--------|
| 1 | `your-first-wrapt-decorator` | Done |
| 2 | `what-instance-tells-you` | Done |
| 3 | `arguments-to-the-decorator` | Done |
| 4 | `handling-the-arguments` | Done |
| 5 | `keeping-state` | Planned |
| 6 | `switching-a-decorator-off` | Planned |
| 7 | `one-decorator-for-everything` | Planned |
| 8 | `validating-arguments` | Planned |
| 9 | `caching-methods` | Planned |
| 10 | `synchronising-calls` | Planned |
| 11 | `wrapping-async-functions` | Planned |
| 12 | `changing-the-signature` | Planned |

Planned means designed here and not yet written. Written means the
pages exist and lint is clean. Done means `just test <name>` is green
and the entry is in the index and the README.

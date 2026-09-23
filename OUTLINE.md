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
replaces. The second, **Monkey patching with wrapt**, is ten workshops
on patching code you did not write, each on a small package shipped
with it and open beside the notebook. A third, on object proxies, has
its id reserved and its workshops sketched, and a fourth is held as a
list of candidates. The
collections share this repository's tooling and nothing else: each has
its own index, id, numbering and audience.

The decorators collection is the companion to the
[decorator workshops](https://github.com/GrahamDumpleton/decorator-workshops),
which teach decorators with the standard library alone. A learner who
has done those knows what a closure is, why `functools.wraps` exists,
what goes wrong on methods and why the descriptor protocol is the
answer. This collection assumes that much and shows what wrapt does
about each of them. It does not require the other collection: every
workshop restates the standard library side in a cell and a sentence
before showing the wrapt one.

The monkey patching collection assumes the wrapper signature and the
`instance` rules from the first two workshops of the decorators
collection, and restates them where they matter, so it can be taken
on its own by anyone who has written a wrapt decorator. It is the
course beneath the
[wrapture workshops](https://github.com/GrahamDumpleton/wrapture-workshops):
wrapture is built on the helpers taught here, so a learner who wants
to test or trace with patches goes there next, and the workshops here
say so at the points where the two meet.

## Source material

wrapt's own documentation and source are the authority, read from the
`reference/wrapt` submodule at the release the workshops teach, never
from memory. For the decorators collection:

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

For the monkey patching collection:

- `docs/monkey.rst`: the whole document. Wrapping functions and
  methods, `patch_function_wrapper` and `function_wrapper`, wrapping
  arbitrary attributes with `wrap_object`, `resolve_path` and
  `apply_patch`, instance attributes with `wrap_object_attribute`,
  deferring with the `?` shortcut and post import hooks, temporary
  patches with `transient_function_wrapper` and
  `scoped_function_wrapper`, inspecting and removing patches through
  handles, and the pitfalls section, which the workshops distribute
  rather than teach in one place.

- `docs/wrappers.rst`: the Object Proxy and Custom Object Proxies
  sections, as much as workshop 8 needs and no more; the rest is for
  the proxies collection.

- `docs/examples.rst`: the Scoped Test Patches section, which is
  workshop 5's two step reading of `transient_function_wrapper`.

- `docs/changes.rst`: the 2.4.0 notes on `unwrap_object`,
  `wrapper_chain`, `scoped_function_wrapper` and `resolve_owner`,
  which say what removal restores in each arrangement more precisely
  than the guide does.

- `blog/11` to `blog/14` in the wrapt repository, on safely applying
  monkey patches, using wrapt to support testing, ordering issues, and
  automatic patching: the background the workshops draw on for why,
  written before the 2.4 lifecycle existed, so the docs win where the
  two differ.

The wrapture workshops are read, not taught, so the pointers to them
name workshops that exist and say what they add.

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
cover the same ground are named differently. The same goes for the
wrapture workshops, which the monkey patching collection points at
and a learner may well have beside it: `patching-third-party-code`,
`wrap-not-replace` and `writing-instrumentation` are taken too.

## The decorators workshops

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

## Topics the decorators collection leaves out

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

## Shape of the monkey patching collection

What you need to patch something you did not write: make the patch
correct on every kind of target, know when it did nothing, take it out
again, and get there before the code you are patching is used. One
ordered collection in four movements, numbered straight through.

**Making a patch** (1 to 3). Assignment by hand and where it goes
wrong, `wrap_function_wrapper` on every kind of method, and the three
spellings of the same patch. After these the learner can patch any
function or method and have it behave as the original did.

**Taking it out again** (4 and 5). The handle every wrap function
returns, what it is for, and the two forms of patch that remove
themselves. This comes early because a notebook kernel keeps every
patch the learner makes, so tidying up is a survival skill here, not
an advanced topic.

**Getting the timing right** (6 and 7). Why a patch applied after
`from x import y` misses the caller that already has `y`, and the
deferral mechanisms that put the patch in place before the module is
used.

**Beyond functions, and to work** (8 to 10). `wrap_object` with a
proxy, `wrap_object_attribute` for what lives on instances, and a
closing workshop that counts and times a library's calls, which is
the shape of every instrumentation agent and the point where wrapture
takes over.

Ten to twenty minutes each, about two and a half hours in total. As
in the decorators collection, each workshop is self-contained and
ships the code it patches.

The comparison the decorators collection makes with the standard
library continues here in a different form: every workshop opens
with the way the learner already knows, assignment, `getattr` and
`setattr`, or `unittest.mock.patch`, in a cell and a sentence, and
shows where it falls short before showing the wrapt helper. Every
workshop uses only what is in wrapt 2.4.1, the release the reference
submodule is at; the lifecycle functions the collection is built on
arrived in 2.4.0.

## The monkey patching workshops

The shipped package is the same cast as the decorators collection,
grown into a package: `shop`, under `files/shop/`, with a `pricing`
module holding `fetch_price`, a `cart` module holding `Shop` with its
`buy` method, an `empty` class method, a `tax` static method and a
`name` set in `__init__`, and further modules as each workshop needs
them. Each workshop ships its own copy, so no page depends on the
state another workshop left.

### 1. `your-first-monkey-patch`: Your first monkey patch

Assignment, and what it gets wrong.

Patch `shop.pricing.fetch_price` by assignment, with the closure and
`functools.wraps` the learner already knows, and see it work. Do the
same to `Shop.buy` and see that work too. Then `Shop.tax` and
`Shop.empty`: `getattr` on the class hands back the static method as
a plain function and the class method as a bound method, so the
closure assigned back is a plain function in the class namespace,
`shop.tax(10)` now passes the instance where none was wanted, and
`empty` looked up through a subclass binds to `Shop` rather than the
subclass. Print `Shop.__dict__["tax"]` before and after, so the
learner sees the kind of thing in the class change. Saving the
original through `getattr` to restore it later has the same flaw.

Then `wrapt.wrap_function_wrapper(shop.cart, "Shop.tax", wrapper)`
on all three, with the wrapper the learner writes with the four
argument signature from the decorators collection. Each is still its
own kind of method, `instance` follows the rules the learner knows,
and `inspect.signature` still tells the truth. The helper reads the
class `__dict__` along the method resolution order rather than
calling `getattr`, which is why it can.

Close with the value `wrap_function_wrapper` returned, printed and
unexplained: it is the handle, and workshop 4 is about it.

- Format: notebook with the code pane.

- Files: `shop/pricing.py`, `shop/cart.py`.

- Length: 15 minutes.

### 2. `patching-every-kind-of-method`: Patching every kind of method

The targets, and the `instance` rules from the patching side.

One target at a time: an instance method, a class method, a static
method, `__init__` and `__len__`, a method of a nested class through
the dotted path `"Outer.Inner.method"`, and a module named by the
string `"shop.cart"` rather than the module object, which imports it
if it has to. Before each cell a quiz asks what `instance` will be,
which is the table from the decorators collection with the answers
now arriving from outside the class. The one rule that matters more
here than for a decorator: `wrapped` is already bound, so the wrapper
calls `wrapped(*args, **kwargs)` and never inserts `instance` itself,
and a page shows what goes wrong when it does.

Then the target that is one object: `wrap_function_wrapper(shop_a,
"buy", wrapper)` patches a single `Shop` and leaves every other
instance alone, because the wrapper lands in that instance's own
namespace.

- Format: notebook with the code pane.

- Files: `shop/cart.py`, with the nested class added, and
  `shop/reports.py`, imported by name.

- Length: 15 minutes.

### 3. `three-ways-to-spell-a-patch`: Three ways to spell a patch

The same patch three ways, and when each reads best.

`wrap_function_wrapper` as a call, from code that decides at runtime
what to patch. `@patch_function_wrapper("shop.pricing",
"fetch_price")` on the wrapper itself, applied as a side effect of the
module holding it being imported, which is how a file of patches
reads; its `enabled` argument as a boolean read once and as a callable
consulted on every call, the switch from workshop 6 of the decorators
collection. `@function_wrapper`, the lighter `@decorator` without
`adapter` or `enabled`, turning a wrapper into something that can be
applied in place, `Shop.buy = count_calls(Shop.buy)`, or handed to
`wrap_object` as the factory, so one wrapper serves several targets.

- Format: notebook with the code pane.

- Files: `shop/pricing.py`, `shop/cart.py`, and a `patches.py` the
  learner reads in the pane and then imports, to see
  `patch_function_wrapper` apply on import.

- Length: 10 minutes.

### 4. `leaving-things-as-you-found-them`: Leaving things as you found them

The handle, and the lifecycle it unlocks.

Every wrap function returns the wrapper it installed, and that object
is the identity of the patch. `wrapt.is_wrapped_by` says whether it
is still there, `wrapt.wrapper_chain` prints the stack of wrappers
outermost first ending at the original, `wrapt.unwrapped` is the
original, and `wrapt.unwrap_object` takes the patch out. Each is
asked of the object `wrapt.resolve_path` returns, never of `getattr`
on the class, because the class hands back a fresh bound wrapper the
handle is not in; a page shows the check fail that way and then pass.

Two patches on `Shop.buy`, and the inner one removed first: the chain
is spliced and the outer one keeps working, so two parties can remove
their patches in either order. Remove the outer, remove it again, and
`WrapperNotFoundError` says the patch is gone; `missing_ok=True` is
for cleanup that must not care. A patch installed through a subclass
that inherits `buy` and then removed leaves no `buy` in the subclass
namespace, because the wrap recorded that it created the slot. The
closure from workshop 1 assigned over a wrapt wrapper raises
`WrapperNotOutermostError` on removal, naming what is above, since a
`functools.wraps` closure's `__wrapped__` is metadata and splicing
there would change nothing.

Close with the rule the whole collection follows from here: a page
that installs a patch takes it out before the next one needs a clean
target, and restarting the kernel is the alternative nobody wants.

- Format: notebook with the code pane.

- Files: `shop/cart.py`, with a subclass of `Shop`.

- Length: 20 minutes.

### 5. `patches-that-last-a-block`: Patches that last a block

Temporary patches, and what happens when something interferes.

Open with `unittest.mock.patch`, as a context manager and as a
decorator, and say what it does: replaces the attribute wholesale and
puts it back with `setattr`. The wrapt forms keep the original
running and know about methods. `wrapt.scoped_function_wrapper` in a
`with` statement, two of them in one `with`, and `ExitStack` when the
list is only known at runtime. `@wrapt.transient_function_wrapper` as
the decorator form, read in two steps as the examples do: the outer
decorator describes the patch, the inner application chooses the
function whose calls it is in force for, and applied straight onto a
test function it lasts that test.

Then interference. Replace the attribute wholesale inside the block
and `WrapperNotFoundError` is raised on exit, at the test responsible
rather than in the next one; a wrapt wrapper applied on top and left
there is tolerated and the temporary one spliced out beneath it. The
`?` form is not accepted here, since the patch must apply where the
`with` is entered, and a generator context manager under
`transient_function_wrapper` patches only the moment the generator is
made, which is the one trap worth a cell.

The finish text says that testing with patches is where wrapture
starts, and names its `wrap-not-replace` and `coming-from-mock`
workshops.

- Format: notebook with the code pane.

- Files: `shop/pricing.py`, `shop/cart.py`.

- Length: 15 minutes.

### 6. `why-your-patch-did-nothing`: Why your patch did nothing

Cached references, and the two ways round them.

`shop/checkout.py` does `from shop.pricing import fetch_price` and
`total()` calls it. Import `shop.checkout`, patch
`shop.pricing.fetch_price`, call `total()`, and nothing happens: the
pane shows the line that took its own reference at import, and
`shop.checkout.fetch_price is shop.pricing.fetch_price` is `False`.
Patch the alias too, at `"shop.checkout"`, and it works; the other
way round, patching before the consumer is imported, is the next
workshop. The same in the small: a bound method saved in a variable
before the patch keeps the original, while a method reached through
the class at call time sees the patch, which is why methods are safer
targets than functions.

- Format: notebook with the code pane.

- Files: `shop/pricing.py`, `shop/checkout.py`.

- Length: 15 minutes.

### 7. `patching-before-the-import`: Patching before the import

Deferral, three ways, and getting the handle back.

The `?` shortcut first: `@patch_function_wrapper("shop.reports?",
"summary")` before `shop.reports` has been imported, then the import,
and the patch is in place. `wrapt.register_post_import_hook` with a
callback that receives the module, so the patch code can hand the
module straight to `wrap_function_wrapper`; register it for
`shop.pricing`, already imported, and it fires at once. The
`@wrapt.when_imported` decorator form. The string form
`"patches:install"`, where the module holding the patch is not itself
imported until the target is, shown with `"patches" in sys.modules`
before and after.

Then the handle. A deferred wrap returns `None`, because the wrapper
does not exist yet, so a patch that may need removing installs from a
hook that keeps the handle, or recovers it after the import with
`wrapt.find_wrapper` and a predicate. `discover_post_import_hooks` and
entry points are named as the packaged form and left for later.

A kernel imports a module once, so each demonstration has a module of
its own, `shop.reports`, `shop.invoices` and `shop.shipping`, all open
in the pane from the start and linked from the page that imports each.

- Format: notebook with the code pane.

- Files: `shop/pricing.py`, `shop/reports.py`, `shop/invoices.py`,
  `shop/shipping.py`, `patches.py`.

- Length: 20 minutes.

### 8. `wrapping-what-is-not-a-function`: Wrapping what is not a function

`wrap_object`, and the least the learner needs of `BaseObjectProxy`.

`shop.config.settings` is a dictionary the package reads. Wrap it
with `wrapt.wrap_object("shop.config", "settings", Watched)`, where
`Watched` is a `BaseObjectProxy` subclass whose `__getitem__` records
which keys are read; the proxy is still a dictionary to `isinstance`,
still equal to the original, and everything not overridden passes
through. What the workshop teaches of proxies: `__wrapped__`, the
`_self_` prefix for the proxy's own state, that a special method
must be defined on the proxy class to be intercepted, and that
`__iter__` and `__call__` are left off the base class on purpose,
so `Watched` defines `__iter__` to pass iteration through. A callable
proxy counting calls to `fetch_price` shows the same with `__call__`.
Extra arguments to the factory through `args` and `kwargs`. The
handle `wrap_object` returns is removed the way workshop 4 taught.

Then the two steps beneath it: `wrapt.resolve_path` returning the
parent, the attribute name and the original, and `wrapt.apply_patch`
setting the replacement, for the case where the original is wanted
for something other than wrapping, such as capturing it in a closure.

The finish text names the proxies collection as where
`BaseObjectProxy` is taught in full.

- Format: notebook with the code pane.

- Files: `shop/pricing.py`, `shop/config.py`.

- Length: 15 minutes.

### 9. `patching-instance-attributes`: Patching instance attributes

What lives in `self.__dict__`, and the descriptor that reaches it.

`Shop.__init__` sets `self.name`, and no wrap function so far can
touch it: the value is set per instance, after the class exists.
`wrapt.wrap_object_attribute("shop.cart", "Shop.name", Labelled)`
installs a descriptor on the class, and every read fetches the
instance's value and passes it through the factory. Show
`Shop.__dict__["name"]` is now an `AttributeWrapper`, that a
`property` already on the class keeps working beneath it, that a
second application stacks over the first rather than replacing it,
and that reading the attribute on the class no longer raises: it
serves the class default when there was one and the `wrapt.MISSING`
sentinel when there was not. The handle is the descriptor, and
`unwrap_object` removes it.

- Format: notebook with the code pane.

- Files: `shop/cart.py`, with a `name` attribute and a `label`
  property.

- Length: 15 minutes.

### 10. `patching-to-observe`: Patching to observe

Counting and timing a library's calls, and the registry that keeps it
honest.

A wrapper with state, the class pattern from workshop 5 of the
decorators collection, records every call of `fetch_price` and
`Shop.buy` with its duration, and a cell prints the table. Around it
the registry from the docs: `instrument` that wraps a target only if
it is not already in the registry, `uninstrument` that walks the
registry removing with `missing_ok=True`, applying twice and seeing
one wrapper, and a check of `shop.__version__` before patching, which
is what a patch of code that changes under you does. Deferral from
workshop 7 makes it apply whether the package is imported before or
after.

The finish text says what this is: the shape of every instrumentation
agent, and the point where wrapture takes over, with its bindings,
recording and export built on these helpers. It names the
[wrapture workshops](https://github.com/GrahamDumpleton/wrapture-workshops),
`live-tracing` for what recording looks like and
`writing-instrumentation` for a package of patches done properly.

- Format: notebook with the code pane.

- Files: `shop/pricing.py`, `shop/cart.py`, `shop/__init__.py` with
  a version.

- Length: 20 minutes.

## Handed to wrapture

The earlier plan for a wrapt course had a monkey patching module of
ten topics, an import hooks module of sixteen and a capstone module of
five. What is not in the collection above, and why.

Monkey patching for testing, conditional and temporary patches, and
instrumentation and observability were applications in the earlier
plan. They are here as fundamentals, workshops 5 and 10, taught as
the primitive and no further: the block scoped patch and the counting
wrapper. The course in using them is the wrapture workshops,
`wrap-not-replace`, `coming-from-mock` and `wrapture-with-pytest` for
testing, `patching-third-party-code` for a patch's lifecycle, and
`live-tracing`, `zero-code-tracing` and `writing-instrumentation` for
tracing, and building those again on bare wrapt would be a worse
course pointing at a better one. The capstone module, an
instrumentation framework and a plugin system, is what wrapture is,
and is not built here.

Reversible patching, debugging patches and safe patching patterns
were advanced topics the learner would build by hand. Since wrapt 2.4
they are API, and workshop 4 teaches them as fundamentals. The
pitfalls section of the docs is spread over workshops 1, 2, 4 and 6
rather than being a workshop.

`ObjectProxy` and its lazy and automatic variants were two topics in
the middle of the earlier monkey patching module. Workshop 8 teaches
the least it needs and the proxies collection has the rest, because
proxies are a course of their own with a different audience: the
patching collection needs `wrap_function_wrapper` and a wrapper
function, which the learner already has.

## Later collections

**Object proxies with wrapt**, id `grahamdumpleton.me/wrapt/proxies`,
reserved now as the monkey patching id was. Eight or nine workshops:
a first proxy on `BaseObjectProxy` and what passes through, what
does not (`type`, identity, `__class__`, iteration, and the copy a
literal value becomes), why `ObjectProxy` still exists (its
`__iter__`, kept for code written before wrapt 2.0.0),
`_self_` attributes and where assignment lands, special methods and
why they must be on the proxy class, `CallableObjectProxy` and the
partial variant, custom `FunctionWrapper` and `BoundFunctionWrapper`
subclasses with `__bound_function_wrapper__`, `LazyObjectProxy` with
`lazy_import` and its `interface` hint, `AutoObjectProxy`,
`WeakFunctionProxy`, and serialising a proxy from the examples doc.
Independent of the monkey patching collection apart from the pointer
in its workshop 8. Notebook format, no shipped code expected.

**A fourth collection, candidates only.** The remainder of the
earlier import hooks module that is still wrapt rather than wrapture:
how `ImportHookFinder` sits in `sys.meta_path` and what it does to a
loader, `discover_post_import_hooks` with entry points and the
`install-packages` capability it needs, the autowrapt bootstrap,
versioned patches, patching a decorator itself, what cannot be
patched on builtins and C types, and the overhead figures from blog
posts 9 and 10. Half of it is a page each rather than a workshop, and
much of it borders wrapture's zero-code tracing, so it waits until
the second and third collections have shipped and the analytics show
whether people reach the end of the second.

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
one: decorators and patches are things you do to Python objects, and
a notebook is where Python objects live. The monkey patching
collection adds a pane for the code being patched, not a terminal.

**Shipped code beside the notebook.** A patch is only interesting
against code the learner can see, so every monkey patching workshop
ships the package it patches under `files/` and shows it in an editor
beside the notebook rather than in a tab behind it. The `notebook`
layout of the decorators collection becomes a `columns` split there:
the notebook on the left as the placeholder area, and an area named
`code` on the right listing every module the pages refer to, open as
tabs from the start, since a layout has one placeholder and this is
not it. The welcome page introduces each module with an `{open}`
link, and every later mention of a file is such a link, which brings
its tab to the front. No page opens a file with an action partway
through: that was tried and read as a second beginning, with the
learner asked to switch between panes rather than glance across. The
learner reads the line that took its own
reference in workshop 6 while the cell that proves it runs. Imports
work because the learner's kernel runs in the workspace, so `import
shop` finds the shipped package with nothing added to the path.

**Patch targets are shipped code, never the standard library.** The
docs patch `logging.Logger.info`, which makes a point about patching
something real, but a workshop patches the `shop` package it ships:
the learner can read the target, a patch left behind by mistake
confuses nothing the notebook depends on, and the internals of the
standard library on 3.14 are not the lesson.

**One module per deferral.** A kernel imports a module once, and the
deferral workshop demonstrates three mechanisms, so each has a module
of its own to be imported for the first time. Removing a module from
`sys.modules` to demonstrate again is exactly the trick the workshop
should not teach by accident.

**Patches are taken out.** Each workshop has its own environment and
kernel, so nothing leaks between workshops. Within one, from workshop
4 on, a page that installs a patch removes it before the next page
needs a clean target, and the page says so, which makes the lifecycle
the habit rather than a topic.

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
familiar names. The monkey patching collection keeps the cast and
grows it into the shipped `shop` package, so `fetch_price` and
`Shop.buy` are the things being patched.

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

**Ids.** `grahamdumpleton.me/wrapt/decorators`,
`grahamdumpleton.me/wrapt/monkey-patching` and
`grahamdumpleton.me/wrapt/proxies`: a prefix for the product, then
the course, leaving room for more under the same prefix. An id is the
collection's identity to the analytics service and must never change,
so each is chosen before any workshop of its collection is written,
and the proxies id is reserved here ahead of its design. The other
collections use flatter ids; revising them to match is a separate
job for another time.

**Where the collections meet the browser.** Both sections of the
workshop browser group by collection, since jupyterlab-workshop
0.10.0: the Available section for anyone who subscribes from their own
JupyterLab, and the Installed section, which is what the Binder and
Codespaces images show, since everything is installed there, with the
collections in the order the settings or the launch link name them,
each under its heading with its workshops numbered in its order. A
launch link can name several collections, so the local start in
`jupyter_lab_config.py` names both. The Finish dialog offers the next
workshop of the same collection and stops at its end; the last
workshop's `finish` text names where to go next.

**Binder, Codespaces and local runs.** The Binder and Codespaces
settings subscribe to each collection's index by relative path, so the
workshops are listed under their collection's title in its order, and
disable opening other directories, subscribing to other collections
and author mode, which keeps a visitor to the workshops the link was
for. The catalog is not subscribed there, since with subscribing
disabled it would offer nothing. A local `just lab` opens on a launch
link naming the catalog and both collections, which adds them for the
session in that order, so the local start lists both grouped and
numbered as the images do; a collection added to this repository is
added to that link.

The two images differ on trust, on purpose. A Binder session is an
anonymous container thrown away at the end, so the workshops are
forced to trusted and no dialog interrupts a visitor who chose the
link. A codespace belongs to the reader's GitHub account and persists,
so it trusts nothing for them and JupyterLab starts without the
codespace's GitHub token.

Both report anonymous progress events to the workshops' own analytics
service, which is how it can be seen where a workshop loses people.
Each carries an ingest token of its own, labelled `wrapt-binder` and
`wrapt-codespaces`, so the service tells the two apart and either can
be revoked alone; the tokens are public by construction, since the
settings scripts are. The tokens carry only the deployment label: the
collection is identified by the `id` in its index, which every event
already carries, so no label repeats it. Each welcome message tells
the visitor that progress is reported and what is never sent. The
collection index carries no block of its own, as the other
collections' do not: it would only ask someone who subscribed from
their own JupyterLab to opt in, and the two images are where the
numbers are.

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
extension copies into the workspace on first open. Most decorators
workshops need none: the code is the point, so it goes in cells. Every
monkey patching workshop ships its `shop` package, which is the thing
being patched, and opens its modules in the code pane.

## Open questions

- None open. Grouping the Installed section by collection, once
  recorded here, was done in jupyterlab-workshop 0.10.0 after seeing
  both collections installed together on Binder, along with launch
  links that name several collections.

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
| 5 | `keeping-state` | Done |
| 6 | `switching-a-decorator-off` | Done |
| 7 | `one-decorator-for-everything` | Done |
| 8 | `validating-arguments` | Done |
| 9 | `caching-methods` | Done |
| 10 | `synchronising-calls` | Done |
| 11 | `wrapping-async-functions` | Done |
| 12 | `changing-the-signature` | Done |

The monkey patching collection is written in its order too: the
first workshop settles the split layout, the shipped package and the
code pane, and each later one adds one idea. Workshops 6 and 7 are
written together, since 7 is the answer to 6.

| # | Workshop | Status |
|---|----------|--------|
| 1 | `your-first-monkey-patch` | Done |
| 2 | `patching-every-kind-of-method` | Done |
| 3 | `three-ways-to-spell-a-patch` | Done |
| 4 | `leaving-things-as-you-found-them` | Done |
| 5 | `patches-that-last-a-block` | Done |
| 6 | `why-your-patch-did-nothing` | Done |
| 7 | `patching-before-the-import` | Done |
| 8 | `wrapping-what-is-not-a-function` | Done |
| 9 | `patching-instance-attributes` | Done |
| 10 | `patching-to-observe` | Done |

Shipping the collection also touched what already existed: the
`monkey_patching` list, id, title and description and the
`index-monkey-patching` recipe in the Justfile; the `collections`
lists in `binder/postBuild` and `.devcontainer/setup.sh`; the
catalog description; the `finish` text of `changing-the-signature`;
the welcome messages, the README and AGENTS.md.

Planned means designed here and not yet written. Written means the
pages exist and lint is clean. Done means `just test <name>` is green
and the entry is in the index and the README.

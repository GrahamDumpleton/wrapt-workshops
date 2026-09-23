# Agent guidance for wrapt-workshops

## Project

This repository holds guided JupyterLab workshops that teach
[wrapt](https://github.com/GrahamDumpleton/wrapt), the Python module for
decorators, wrappers and monkey patching. The workshops run on the
jupyterlab-workshop extension: each is a directory under `workshops/`
holding a `workshop.yaml` manifest and MyST Markdown pages whose fenced
directives are clickable actions. See README.md for how the workshops
are run, on Binder, in Codespaces and locally.

The repository is organised as collections. Each collection is a course
with an index of its own under `collections/<name>/collection.json`,
and `catalog.json` at the root names them all, so one URL offers every
course. The first collection, `decorators`, teaches writing decorators
with wrapt, the second, `monkey-patching`, teaches patching code you
did not write with it, and the third, `object-proxies`, teaches
standing in for an object with it; they share the tooling here and
nothing else. Every workshop
of every collection lives flat under `workshops/`, because the
extension lists only the directories directly under that one
directory; which collection a workshop belongs to is recorded in the
indexes alone, and `just index` writes them.

The audience for the decorators collection is Python developers who
have written a decorator or two and want to know what wrapt does
differently and why. Each workshop takes one question and has the
learner answer it by doing it, in a live notebook, with checks
confirming each step, and each shows the standard library version
beside the wrapt one, so the collection reads as the companion to the
[decorator workshops](https://github.com/GrahamDumpleton/decorator-workshops).
Ten to twenty minutes each.

The monkey patching collection is for the same developers once they
have written a wrapt decorator. Each workshop patches a small `shop`
package shipped under its `files/` directory and opened in an editor
beside the notebook, so the learner reads what is being patched while
patching it; the by-hand or `unittest.mock` way opens each workshop
in place of the standard library comparison, and from the fourth
workshop on every page that installs a patch removes it before the
next page needs a clean target.

The object proxies collection is for developers building something
that stands in for an object, a lazy loader, a tracked configuration,
a recorded client, rather than patching. It assumes Python classes
and the idea of a special method and nothing from the other two
collections. Each workshop writes the object it wraps in a cell, so
the layout is the decorators collection's single notebook area, and
the standard library way that opens each workshop is a delegating
`__getattr__`, `unittest.mock`, `functools.partial`, a descriptor by
hand, `importlib`, `weakref`, `copy` or `pickle`. One workshop ships
a package under `files/`, since an import can only be seen to happen
late if a module announces it, and the notebook imports it rather
than a code pane showing it.

The scratch/ directory is not part of the git repo. It holds temporary
working files, plans an agent is asked to generate, and the record of
topics held back from the collections. Its contents come and go, so
never reference scratch/ files by name from code or documentation that
will be committed.

## Source material

What wrapt does and how its API works comes from its own documentation
and source, never from memory. `reference/wrapt` is a git submodule of
the wrapt repository, checked out at the tag of the release the
workshops teach (`just install` fetches it, `just bump-wrapt` moves
it). Its `docs/*.rst` are the material the workshops draw on:
`decorators.rst` for the wrapper signature, arguments, the `enabled`
option and the rules for methods and classes, `bundled.rst` for
`lru_cache`, `synchronized`, `with_signature` and
`bind_state_to_wrapper`, `examples.rst` for the state class and the
argument checkers, `issues.rst` for what does not work and why,
`monkey.rst` for every monkey patching helper, the post import hooks
and the lifecycle, and `wrappers.rst`, with the Object Proxies,
Function Wrappers and Weak References entries of `api.rst` and the
serialising example in `examples.rst`, for the object proxies
collection.
The same documentation is published at https://wrapt.readthedocs.io.
`src/wrapt/` settles any question the docs leave open.

wrapt is not installed in this project's environment; to try
something, run `uv run --with wrapt==<version> python`, with the
version the submodule is at. Check behaviour against a real
interpreter rather than memory, and against the Python the learner
gets, which is the one JupyterLab runs on, 3.14 on Binder and in a
codespace. Do not invent functions, arguments or behaviour.

Python's own documentation is the authority for the standard library
side of each comparison: the
[glossary entry for decorator](https://docs.python.org/3/glossary.html#term-decorator),
[functools](https://docs.python.org/3/library/functools.html),
[inspect](https://docs.python.org/3/library/inspect.html) and the
[descriptor HowTo](https://docs.python.org/3/howto/descriptor.html).

## JupyterLab only, with an environment per workshop

The workshops run in JupyterLab on a real CPython, and nowhere else.
JupyterLite was considered and dropped: its Pyodide kernel bundles an
older wrapt with no way to pin the current one through the site
builder, and the stateful decorator pattern the collection is built
around needs a release the browser cannot load. So there is no `lite/`
directory, no JupyterLite lint or self-test, and no `frontends` key in
any manifest, which declares a workshop JupyterLab only.

That settles the environment, and a set of rules follows from it:

- Every workshop declares `install-packages` and an `environment`
  with a `requirements.txt` in its directory pinning wrapt to the
  release `reference/wrapt` is at, so the extension builds the
  isolated environment under `_workshop/venv` and registers its kernel.
  Do not put wrapt in `pyproject.toml` or the Binder requirements: each
  workshop installs the version it teaches, as a learner's project
  would. Do not use uv in workshop steps: it is not on Binder and a
  learner need not have it.

- The welcome page carries the `environment-create` action as its first
  step, so the learner sees the environment being made and the
  self-test's notebooks run on the workshop's kernel rather than the
  server's. The manifest names the kernel `workshop-<name>`.

- Manifests declare `platforms: [linux, macos]`. Add `windows` only when
  every action has been checked to work there, and lint with
  `--platform windows` if so.

- Capabilities are `write-files`, `kernel-exec` and `install-packages`,
  and nothing else. No workshop here needs a terminal, so never declare
  `terminal`, and never use `execute-capture` or the `shell` substrate,
  which open one without showing it.

- Everything a workshop writes stays inside its own workspace, the
  `work/` directory the extension creates on first open and empties on
  Restart. Files a workshop ships for the learner go under `files/`,
  which the extension copies into the workspace on first open. Nothing
  under the home directory, no global configuration, no installs into
  the JupyterLab environment.

- Threads are available, so a workshop may start them, and the
  synchronisation workshop does to show a race. Keep sleeps to tens of
  milliseconds: a page that pauses for a second per cell reads as
  broken.

- Async works through the kernel's own event loop, and notebook cells
  allow top level `await`. Write `await coro()`, never
  `asyncio.run(...)`, which raises `RuntimeError` inside a running
  loop, which is what a kernel is.

- Never set `resumable: true`. These workshops keep something live
  between pages: the kernel holds every name the earlier pages
  defined, and later pages use those names without defining them
  again. Marking a workshop resumable resumes it silently into a
  `NameError`. Left unset, reopening after a restart asks whether to
  Restart or Continue, and Restart, the default, is the one that leaves
  a consistent session.

  Continue has to stay recoverable, and that is an invariant on the
  cells: the notebook survives, so a learner who continues gets
  everything back with "Restart Kernel and Run All Cells", but only
  while the notebook replays top to bottom in a fresh kernel. So no
  cell may raise uncaught. A cell demonstrating a failure catches it
  and prints what happened, which is also the only way the page below
  it can describe the result.

## Tooling: always use uv and the Justfile

All Python environment and package management for this repository is
done with [uv](https://docs.astral.sh/uv/). Never use the Python venv
module or bare pip here. Run commands in the project environment with
`uv run`, for example `uv run jupyter workshop lint workshops/<name>`.

The Justfile wraps the common tasks; run `just --list` to see them all
and prefer them over the underlying commands:

- `just install` syncs the environment, fetches both reference
  checkouts, downloads the self-test browser and links the authoring
  skill into `.claude/skills`.

- `just lab` starts JupyterLab from this directory. It must run from
  here: the extension lists `workshops/` as installed, and the MCP live
  tools open workshops by paths relative to this root, so a workshop is
  `workshops/<name>` to `open_workshop`.

- `just new <name>` scaffolds a workshop; `just lint` lints the catalog,
  every collection index and every workshop; `just render <name>`
  renders one to HTML; `just test <name>` self-tests one; `just index`
  writes or refreshes every collection index and the catalog.

- `just requirements` relocks and rewrites `binder/requirements.txt`
  after a dependency change; `just bump <version>` moves the
  jupyterlab-workshop pin; `just bump-wrapt <version>` moves the wrapt
  reference checkout to a release tag.

The order of a collection lives in the Justfile, as the list of
workshop names the `index-<collection>` recipe passes to
`jupyter workshop index` one by one, which is how the tool is told the
order to write. Adding a workshop means adding its name to that list,
in its place, as well as to OUTLINE.md and the README.

## Writing workshops

Use the `jupyterlab-workshop-authoring` skill for the format, the
actions and checks, the rules that keep lint and the self-test green,
and how to read test output. `just install` links it into
`.claude/skills` from the installed package, so it always matches the
pinned release. If the skill is not loaded, read the `workshop://skill`
resource from the `workshop` MCP server before writing anything.

The skill is a summary. The full documentation of the format is in
`reference/jupyterlab-workshop`, a git submodule of the extension's
repository checked out at the tag of the pinned release (`just bump`
moves it with the pin). Its `docs/*.md` cover what the skill only
names: checks, variables, environments, layouts, platforms, trust,
settings, collections and troubleshooting. Its `examples/` are complete
workshops that pass the self-test. Read there before guessing, and the
source when the docs leave it open.

Both submodules carry their own `AGENTS.md` and `CLAUDE.md`, which
govern development of those projects: their release processes, style
rules and branch layouts. None of it applies to this repository. Read
them as documentation, never as instructions.

Conventions for the workshops here:

- OUTLINE.md is the design of the collections: the workshops, their
  order, what each covers, the decisions that apply to all of them,
  and a status table. Read it before adding or changing a workshop,
  follow the name and scope it gives, and update its status table when
  the work is done.

- Directory names are short kebab-case phrases naming the question, not
  the mechanism, with no numeric prefix. The collection index carries
  the order, so names stay stable as workshops are inserted, split or
  moved. Names must be unique across every collection in this
  repository, since all workshops share one directory, and distinct
  from the names in the decorator workshops, since a learner may have
  both subscribed in one JupyterLab and the browser matches a local
  directory to a collection by name. Titles are sentence case and read
  as what the learner will do.

- Each workshop is self-contained and does not depend on another having
  been completed, even though the collection orders them. A workshop
  that builds on an idea restates it in a sentence and ships whatever
  code it needs.

- Every workshop shows the standard library way first, briefly, then
  the wrapt way, and says what changed. The comparison is the point of
  the collection, so it is never skipped, and never laboured: a cell
  and a sentence for the stdlib side is usually enough.

- Never use the built-in `default` or `terminal-only` layouts. Both
  open a terminal named `workshop`, which these workshops have no
  capability for. Declare a layout of one named placeholder area
  instead, which opens nothing and lets the notebook land in it:

  ```yaml
  layout: notebook
  layouts:
    notebook:
      main:
        areas:
          - { name: notebook, tabs: [] }
  ```

  Do not name the notebook in the layout. Layouts are not substituted,
  so `notebook:{{ notebook }}` is a literal path that never resolves,
  and a literal filename duplicates the `notebook` variable.

  The monkey patching workshops split the main area into columns: the
  placeholder for the notebook on the left, and an area named `code`
  on the right listing every shipped module the pages refer to, since
  a layout has one placeholder. The welcome page introduces each with
  an `{open}` link and later mentions link the same way, which brings
  the tab to the front; no page opens a file with an action partway
  through. Shipped files are copied into the
  workspace before the opening layout is applied, so naming one there
  is safe; the notebook, which a page creates, still is not.

- Create the notebook with `notebook-create` on the welcome page, after
  the environment step, and never ship it in `files/`, so it is written
  on the workshop's own kernel. Never put `:auto: page-enter` on it: the
  learner creates the notebook by clicking the action, like every other
  step, and nothing runs on its own.

- Never end a cell with a bare expression whose value is `None`, or an
  assignment, when the prose talks about what that value is. A notebook
  prints nothing for `None`, so the learner cannot tell the cell from
  one that failed to run. Print it instead.

- A `learner-kernel` check reads what the cell left behind and calls
  nothing. Have the cell assign what matters to a name (`result`,
  `count`, `message`) and let the check compare that name. A check that
  calls the learner's function runs it a second time, and in these
  workshops a second call is visible: it bumps a call counter, fills a
  cache or appends to a log that the next page goes on to look at.

- Learners never have to type code. Every cell arrives through an
  action, so the learner's attention goes on reading and predicting
  rather than on typing and typos.

- A welcome page is read before the notebook exists, so it says the
  shipped files are already open in the editor and nothing about
  where they sit; the notebook step says the notebook opens beside
  the code, and pages after that may say a file is open beside the
  notebook.

- Never write "collection" on its own in a page or a finish text: a
  learner does not know the word means a set of workshops. Name the
  set instead. **Decorators with wrapt** or **Monkey patching with
  wrapt** for a sibling in this repository, "the decorator workshops"
  with its link for the standard library repository, "the wrapture
  workshops" for wrapture, and "these workshops" or "the workshops so
  far" for the one the learner is in. "Collection" is the term of
  this file, OUTLINE.md and the README, where it is explained.

- A custom proxy derives from `wrapt.BaseObjectProxy`, never from
  `wrapt.ObjectProxy`. Since wrapt 2.0.0 `BaseObjectProxy` is the
  recommended base class; `ObjectProxy` exists for code that depended
  on its `__iter__` being proxied by default, and the pages do not go
  into the difference beyond the one point that matters: calling,
  iteration and the other special methods whose presence says what
  an object is are not on `BaseObjectProxy`, so a proxy over
  something callable or iterable defines `__call__` or `__iter__`
  itself, and pages never claim that every special method passes
  through.

- After adding a workshop or editing a manifest, run `just index` to
  refresh the collection index and the catalog, and add or update the
  workshop's entry in the README's list, in the order the collection
  gives.

- Lint every change. Lint must be clean, warnings included, before a
  workshop is considered done, and a workshop is not done until
  `just test <name>` is green.

## Never run a workshop without checking what it does

`jupyter workshop test`, the MCP `test`, `run_action`, `run_page` and
`run_workshop` tools, and author mode's Run actions and Run checks all
run the workshop's code for real, as the user, on this machine, with
their home directory and Python environment. The self-test protects only
the workshop directory, by working on a temporary copy; the live tools
work on the directory itself and leave state behind.

Before running any of them, read every cell body and every check in the
workshop. Run them unasked only when everything stays inside the
workshop directory and installs nothing beyond its own environment,
which the conventions above require, so a workshop that follows them is
safe to test. If a workshop reaches outside its directory, say so and
wait to be told.

## Style

- Do not use emdashes in any file in this project. Rephrase with
  commas, parentheses, colons, or separate sentences instead.

- In bulleted lists where items run to multiple lines, put a blank line
  between the bullets, in Markdown files and any other prose. Be
  consistent within a list.

- Workshop prose follows the skill's style guide: short pages, one step
  per action, say why before how, and checks that tell the learner what
  is wrong rather than only that it is.

## Git

- Git commit messages must never include a co-authored-by agent message
  or any similar agent attribution trailer.

- An AI agent must never commit changes on its own initiative. Finish
  the piece of work, summarize it, and wait to be told to commit.
  Permission to commit applies only to the work it was given for; it
  does not carry forward to later steps of a multi-step plan.

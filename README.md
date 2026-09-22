# wrapt workshops

[![Launch on Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/GrahamDumpleton/wrapt-workshops/main?urlpath=lab)
[![Open in GitHub Codespaces](https://img.shields.io/badge/launch-codespaces-579ACA?logo=github&logoColor=white)](https://codespaces.new/GrahamDumpleton/wrapt-workshops?quickstart=1)
[![test](https://github.com/GrahamDumpleton/wrapt-workshops/actions/workflows/test.yml/badge.svg)](https://github.com/GrahamDumpleton/wrapt-workshops/actions/workflows/test.yml)

Nothing to install: start the workshops on
[mybinder.org](https://mybinder.org/v2/gh/GrahamDumpleton/wrapt-workshops/main?urlpath=lab)
with no account, or in
[GitHub Codespaces](https://codespaces.new/GrahamDumpleton/wrapt-workshops?quickstart=1)
with a GitHub account (see [Launch on Binder](#launch-on-binder) and
[Launch on Codespaces](#launch-on-codespaces) below). Or
[run them locally](#run-locally).

Guided, hands-on workshops for
[wrapt](https://github.com/GrahamDumpleton/wrapt), the Python module for
decorators, wrappers and monkey patching. The first collection teaches
writing decorators with wrapt: the wrapper signature, what `instance`
tells you, arguments, state, and the decorators wrapt bundles, each
shown beside the standard library version it replaces. A collection on
monkey patching will follow.

The workshops run on
[jupyterlab-workshop](https://github.com/GrahamDumpleton/jupyterlab-workshop),
a JupyterLab extension that shows the instructions in a side panel with
clickable actions that drive the session, and checks what you have done
as you go. Each workshop is a directory of a `workshop.yaml` manifest
and Markdown pages, and each installs the wrapt release it teaches into
an environment of its own when it opens. See [OUTLINE.md](OUTLINE.md)
for the design of the collections.

## The collections

The repository holds one collection now and is laid out for more. Each
collection is a course: its workshops are numbered in the order to take
them, and the Finish dialog of each offers the next. A
[catalog](catalog.json) names every collection, so one URL offers them
all.

### Decorators with wrapt

Twelve workshops, about three hours in total, in the order to take
them. Each is self-contained, so you can start anywhere, but they
build. All twelve are written; the status table in
[OUTLINE.md](OUTLINE.md#status) records where each stands.

**Understanding wrapt**

1. **Your first wrapt decorator** (`your-first-wrapt-decorator`,
   15 minutes). Write the four argument wrapper and see what comes for
   free: name, docstring, signature, source and `__wrapped__`, with no
   `functools.wraps` in sight. The closure version sits beside it.

2. **What instance tells you** (`what-instance-tells-you`,
   15 minutes). One decorator on a function, an instance method, a
   class method, a static method and a class. Watch what `instance`
   holds each time, find out why `args` never contains `self`, and
   learn the one ordering rule with `@classmethod`.

3. **Arguments to the decorator** (`arguments-to-the-decorator`,
   15 minutes). A closure around `@wrapt.decorator` in place of three
   nested functions, the class form with `__call__`, and optional
   arguments with `wrapt.partial` in place of sentinels.

**Inside the wrapper**

4. **Handling the arguments** (`handling-the-arguments`, 15 minutes).
   Why `args` and `kwargs` are never bound to names, the nested
   function that reads or changes them, binding against the signature
   of `wrapped` so methods need no special case, and changing the
   return value.

5. **Keeping state** (`keeping-state`, 20 minutes). Set an attribute on
   the wrapper and find it on the wrapped function instead. Then the
   state class: a wrapper method, `bind_state_to_wrapper`, and a call
   count reachable through the function, the class and an instance.

6. **Switching a decorator off** (`switching-a-decorator-off`,
   10 minutes). The `enabled` argument as a boolean, where no wrapper
   is applied at all, and as a callable checked on every call.

7. **One decorator for everything** (`one-decorator-for-everything`,
   15 minutes). The universal decorator from the `instance` and
   `inspect.isclass` rules, raising where it is not supported, and
   stacking wrapt decorators with each other and with stdlib ones.

**Patterns worth knowing**

8. **Validating arguments** (`validating-arguments`, 15 minutes). A
   type checker and a value checker built on the state class, with the
   signature taken from `wrapped` on first call, and the one stacking
   order that gives the right error.

9. **Caching methods** (`caching-methods`, 15 minutes). The three ways
   `functools.lru_cache` goes wrong on a method, then `wrapt.lru_cache`
   with a cache per instance.

10. **Synchronising calls** (`synchronising-calls`, 15 minutes). A
    race shown with real threads, then `wrapt.synchronized` on a
    function, a method with a lock per instance, a class method with a
    lock per class, and the context manager form sharing the same lock.

11. **Wrapping async functions** (`wrapping-async-functions`,
    15 minutes). An `async def` wrapper under `@wrapt.decorator`, one
    decorator serving both kinds, and `synchronized` switching to an
    asyncio lock by itself.

12. **Changing the signature** (`changing-the-signature`, 10 minutes).
    A decorator that supplies an argument the caller no longer passes,
    the lie `inspect.signature` then tells, and `wrapt.with_signature`.

## Launch on Binder

[mybinder.org](https://mybinder.org) is a free public service that
builds this repository into a temporary JupyterLab and runs it for you
in the browser, so there is nothing to install. To start, click this
link:

**[Launch the workshops on Binder](https://mybinder.org/v2/gh/GrahamDumpleton/wrapt-workshops/main?urlpath=lab)**

The badge at the top of this page opens the same link. Building and
starting the session takes a minute or two. When JupyterLab appears, the
workshops are listed in its workshop browser under their collection,
numbered in the order to take them, and the Finish dialog of each
offers the next. A workshop installs wrapt for itself when it opens, into
an environment of its own inside the workshop directory, so its first
step takes a moment; the image carries the wheels, so the install does
not wait on PyPI.

Opening a workshop locally shows a dialog asking you to trust it, since
its actions run code on your machine. On Binder that dialog is removed:
the session is a container of its own, created for you and discarded
when you are done, and at no time is anything done on your machine. The
`binder/postBuild` script installs a settings override that marks the
checkout's workshops as trusted, turns off editing, subscribes to the
checkout's own collection indexes, and names `binder/welcome.md` as the
message shown when the session starts, which says what the workshops
are and how to end the session.

The same override names the workshops' own analytics service as the sink
for progress events, so a session reports which pages, actions and
checks happened and when, and it can be seen where the workshops are
clear and where they are not. Sessions are anonymous, and the events
never carry notebook contents, cell output or form answers; the welcome
message says that progress is reported before you start. The token in
the script is as public as the script, is accepted only for ingest, and
is labelled `wrapt-binder` so it can be revoked on its own.

Binder sessions are temporary: anything you do in one is gone when it
ends, so finish a workshop in the session you started it in. When you
are done with the session, whether you finished a workshop or not, shut
it down rather than closing the browser tab, so the resources go back to
Binder for other users. The Finish dialog at the end of a workshop has a
button for this, and so does JupyterLab's File menu, under "Shut Down".

## Launch on Codespaces

[GitHub Codespaces](https://github.com/features/codespaces) builds this
repository into a container of your own in the cloud and opens it in VS
Code in the browser. It needs a GitHub account, and the codespace uses
your account's Codespaces allowance: personal accounts get a monthly
amount of use at no cost, beyond which GitHub charges for it or stops
it. Unlike a Binder session, a codespace is kept until you delete it. To
start, click this link:

**[Launch the workshops on Codespaces](https://codespaces.new/GrahamDumpleton/wrapt-workshops?quickstart=1)**

The Codespaces badge at the top of this page opens the same link. If you
already have a codespace for this repository, the link offers to resume
it rather than create another.

Creating the codespace takes a few minutes. VS Code opens first, with
`.devcontainer/welcome.md` open in it, while `.devcontainer/setup.sh`
installs JupyterLab and the extension from `binder/requirements.txt`, as
`binder/postBuild` does, and `.devcontainer/start.sh` starts JupyterLab
in the background. When JupyterLab is ready, VS Code shows a
notification that the application on port 8888 is available: click Open
in Browser to open JupyterLab in a new tab. If the notification has
gone, open the address of the port labelled JupyterLab from VS Code's
Ports panel. The tab is not opened by itself, because browsers block a
tab nobody clicked for. From there the workshop browser lists the
workshops in order, as on Binder, and `setup.sh` installs the same
settings override as `binder/postBuild`, reporting progress to the same
analytics service under a token of its own, labelled
`wrapt-codespaces`, with two differences: it names
`.devcontainer/welcome.md` as the message shown when JupyterLab starts,
and it does not mark the workshops as trusted.

On Binder the trust dialog is removed, because the session is an
anonymous container that is thrown away when you are done. A codespace
is yours, tied to your GitHub account, so opening a workshop shows the
trust dialog: what the workshop will do, which here is to create an
environment with wrapt installed, write a notebook and run cells in it,
and how far to trust it. Choose Trust to let its actions run as
intended; Restricted asks before changing files or running code. You
are asked once for each workshop, and again only if it changes.
`.devcontainer/start.sh` also starts JupyterLab without the codespace's
GitHub credentials: the `GITHUB_TOKEN` variable is removed from its
environment and git is given no credential helper, so nothing a
workshop runs is handed a token for your account. That narrows what
workshop code can reach; it does not sandbox it.

JupyterLab in the codespace asks for no token, because the forwarded
port is private: only you, signed in to GitHub, can reach it. Leave the
port's visibility as Private. Made public, it would let anyone with its
address run code in your codespace.

A codespace stops by itself after a period of inactivity and keeps your
work, and starting it again from
[github.com/codespaces](https://github.com/codespaces) starts JupyterLab
again with it. A stopped codespace still uses your storage allowance, so
delete it there when you have finished with the workshops.

## Run locally

You need Python 3.14 and [uv](https://docs.astral.sh/uv/). Clone the
repository, install the environment and start JupyterLab from the
checkout:

```
git clone https://github.com/GrahamDumpleton/wrapt-workshops
cd wrapt-workshops
uv sync --no-dev
uv run jupyter lab --config=jupyter_lab_config.py
```

Python 3.14 is named because each workshop builds its own environment
from the Python JupyterLab runs on. Without uv, the environment comes
from the requirements file Binder uses:

```
python3 -m venv .venv && source .venv/bin/activate
pip install -r binder/requirements.txt
jupyter lab --config=jupyter_lab_config.py
```

Run from the checkout, the workshops appear under Installed in the
workshop browser, because they sit in the `workshops` directory the
extension looks in by default. The config file opens JupyterLab at
`http://localhost:8888/lab?catalog=catalog.json&collection=collections/decorators/collection.json`,
which adds the decorators collection for the session, so its workshops
are listed numbered in the order to take them under the collection's
title, and adds the catalog, which offers the other collections of this
repository to subscribe to once there are others. Without the link the
workshops are listed in directory order. From the browser, open a
workshop, or go straight to one with
`http://localhost:8888/lab?workshop=workshops/<name>`. Outside Binder
the trust dialog appears when a workshop opens; it lists what the
workshop's pages are allowed to do.

Or clone nothing: install the extension as a uv tool, with the `lab`
extra bringing JupyterLab along, and launch it on the catalog by URL,
with a directory of your own to keep the workshops in:

```
uv tool install --python 3.14 "jupyterlab-workshop[lab]"
jupyter-workshop launch --root ~/training --catalog https://raw.githubusercontent.com/GrahamDumpleton/wrapt-workshops/main/catalog.json
```

The same in one line, installing nothing that stays:

```
uvx --python 3.14 --from "jupyterlab-workshop[lab]" jupyter-workshop launch --root ~/training --catalog https://raw.githubusercontent.com/GrahamDumpleton/wrapt-workshops/main/catalog.json
```

They start JupyterLab on a free port with `~/training` as its root and
open the workshop browser with the catalog added, which offers each
collection to subscribe to; each workshop is installed from this
repository into `~/training/workshops` as you open it, and stays there
for the next launch. To land with one collection's workshops already
listed, give its index instead:

```
jupyter-workshop launch --root ~/training --collection https://raw.githubusercontent.com/GrahamDumpleton/wrapt-workshops/main/collections/decorators/collection.json
```

## Subscribe from your own JupyterLab

With the extension installed anywhere, subscribe to the catalog and
every collection here is offered in the workshop browser, with
Subscribe on each; subscribe to a collection and its workshops are
offered under Available, with Install fetching each from this
repository. In the browser, choose "Collections…" and enter the raw URL
of the catalog on the Catalogs tab, or of a collection's index on the
Collections tab:

```
https://raw.githubusercontent.com/GrahamDumpleton/wrapt-workshops/main/catalog.json
https://raw.githubusercontent.com/GrahamDumpleton/wrapt-workshops/main/collections/decorators/collection.json
```

## What is in the repository

```
workshops/
  <name>/                a workshop: workshop.yaml, requirements.txt and pages/*.md;
                         every collection's workshops sit here side by side
catalog.json             names every collection, by relative path; written by `just index`
collections/
  decorators/
    collection.json      the index of the decorators collection, in the order to take
                         it, written by `just index`; its id never changes
reference/wrapt          a git submodule of wrapt at the release the workshops teach,
                         the source of truth for its API and documentation
reference/jupyterlab-workshop
                         a git submodule of jupyterlab-workshop at the pinned release,
                         the full documentation and source of the workshop format
pyproject.toml           the uv project: JupyterLab and the extension, with the
                         authoring tools in the dev group; wrapt is deliberately absent
binder/                  the Binder image: the locked runtime dependencies exported
                         from uv.lock by `just requirements`, the Python version, the
                         postBuild that fills a wheelhouse and writes JupyterLab's
                         settings, and the welcome message a Binder session opens with
.devcontainer/           the Codespaces container: the same requirements installed with
                         pip, the wheelhouse and settings, a script that starts JupyterLab
                         on port 8888, and the welcome message VS Code opens
.github/workflows/       CI: test.yml lints the catalog, every collection and every
                         workshop, and self-tests every workshop, on each push
jupyter_lab_config.py    opens a local JupyterLab on the catalog and the decorators
                         collection, so the workshops are listed in order; `just lab`
                         passes it to jupyter lab
Justfile                 the common tasks, and the order of each collection; run `just`
                         to list them
.mcp.json                the MCP server configuration for AI agent clients
AGENTS.md                guidance for AI agents writing workshops here
OUTLINE.md               the design of the collections: the workshops, what each
                         covers, and where each stands
```

Each workshop is self-contained and can be copied out on its own.

## Writing and checking workshops

`just install` sets up the environment: it syncs uv, fetches both
reference submodules, downloads the browser the self-test drives, and
links the authoring skill shipped in the jupyterlab-workshop package
into `.claude/skills`.

```
just new <name>          scaffold a workshop under workshops/
just lint                lint the catalog, every collection index and every workshop
just render <name>       render a workshop to HTML
just test <name>         self-test one workshop in a JupyterLab of its own
just index               write or refresh every collection index and the catalog
```

The order of a collection is the list of workshop names in the
Justfile, which `just index` passes to `jupyter workshop index` one by
one; a new workshop is added there, in its place, as well as to
OUTLINE.md and the list above.

## Updating the release

jupyterlab-workshop is pinned once, in `pyproject.toml`. `just bump
<version>` moves the pin, relocks, rewrites `binder/requirements.txt`,
relinks the skill and moves the `reference/jupyterlab-workshop`
submodule to the same release tag. Binder builds a fresh image for the
new commit, a codespace created after it installs the new release (an
existing codespace keeps the one it was created with), and CI tests the
workshops against the new release.

The wrapt release the workshops teach is named in each workshop's
`requirements.txt` and matched by the `reference/wrapt` submodule.
`just bump-wrapt <version>` moves the submodule to the release tag; the
workshops' requirements are then updated by hand and the workshops
retested.

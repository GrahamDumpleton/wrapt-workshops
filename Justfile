# Guided JupyterLab workshops for wrapt. Run `just` to list targets.

repo := "https://github.com/GrahamDumpleton/wrapt-workshops"

# The catalog names every collection in this repository, so one URL
# offers them all; each collection has an index of its own under
# collections/<name>/, with an id that never changes.
catalog_title := "wrapt workshops"
catalog_description := "Guided JupyterLab workshops for wrapt: writing decorators, and later monkey patching."

decorators_id := "grahamdumpleton.me/wrapt/decorators"
decorators_title := "Decorators with wrapt"
decorators_description := "Guided JupyterLab workshops on writing decorators with wrapt: the wrapper signature, methods, arguments, state, and the decorators wrapt bundles, each beside the standard library version it replaces."

# The decorators collection, in the order to take it. OUTLINE.md is the
# design this list follows; `just index` writes the index in this order,
# skipping any not written yet, so the order lives here and nowhere else.
decorators := "your-first-wrapt-decorator what-instance-tells-you arguments-to-the-decorator handling-the-arguments keeping-state switching-a-decorator-off one-decorator-for-everything validating-arguments caching-methods synchronising-calls wrapping-async-functions changing-the-signature"

# List available targets.
default:
    @just --list

# Set up the environment: sync uv, fetch the reference checkouts, download the self-test browser, link the authoring skill.
install:
    uv sync
    git submodule update --init
    uv run playwright install chromium
    just skill

# The skill ships inside the jupyterlab-workshop package. Linking it into
# .claude/skills lets Claude Code load it without a copy in this repository,
# and it tracks the pinned release; rerun after bumping the version.
# Link the authoring skill from the installed package into .claude/skills.
skill:
    #!/usr/bin/env bash
    set -euo pipefail
    target=$(uv run python -c 'import jupyterlab_workshop, pathlib; print(pathlib.Path(jupyterlab_workshop.__file__).parent / "skills" / "jupyterlab-workshop-authoring")')
    mkdir -p .claude/skills
    ln -sfn "$target" .claude/skills/jupyterlab-workshop-authoring
    echo "Linked .claude/skills/jupyterlab-workshop-authoring -> $target"

# JupyterLab must run from this directory: the extension lists workshops/
# as installed, and the MCP live tools open workshops by paths relative
# to this root, such as workshops/<name>.
# Start JupyterLab from the checkout, listing the workshops in the collection's order.
lab *ARGS:
    uv run jupyter lab --config=jupyter_lab_config.py {{ARGS}}

# Scaffold a new workshop under workshops/; extra args go to `jupyter workshop init`.
new NAME *ARGS:
    uv run jupyter workshop init workshops/{{NAME}} {{ARGS}}

# Lint the catalog, every collection index and every workshop, or only the workshops named.
lint *NAMES:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    names=({{NAMES}})
    if [ ${#names[@]} -eq 0 ]; then
        if [ -f catalog.json ]; then
            uv run jupyter workshop lint catalog.json
        fi
        for index in collections/*/collection.json; do
            uv run jupyter workshop lint "$index"
        done
        dirs=(workshops/*/)
    else
        dirs=("${names[@]/#/workshops/}")
    fi
    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No workshops under workshops/ yet"
        exit 0
    fi
    for dir in "${dirs[@]}"; do
        echo "== $dir"
        uv run jupyter workshop lint "$dir"
    done

# Render one workshop as HTML to check what a page looks like; extra args go to `jupyter workshop render`.
render NAME *ARGS:
    uv run jupyter workshop render workshops/{{NAME}} {{ARGS}}

# The self-test runs the workshop's actions and checks for real, as you,
# on this machine; only the workshop directory is protected, by a
# temporary copy. Read the workshop first.
# Self-test one workshop in a JupyterLab of its own; extra args go to `jupyter workshop test`.
test NAME *ARGS:
    uv run jupyter workshop test workshops/{{NAME}} {{ARGS}}

# Self-test every workshop, writing a JUnit report for each.
test-all:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    for dir in workshops/*/; do
        name=$(basename "$dir")
        echo "== $dir"
        uv run jupyter workshop test "$dir" --junit "results-$name.xml"
    done

# Write or refresh every collection index and the catalog.
index: index-decorators catalog

# The workshop directories are named one by one, in the collection's
# order, which is how `jupyter workshop index` is told the order to
# write; naming only the directories that exist lets the index be
# refreshed while the collection is still being written. The repository
# URL is given explicitly so the index does not depend on a git remote
# being configured in the checkout.
# Write or refresh collections/decorators/collection.json in the collection's order.
index-decorators:
    #!/usr/bin/env bash
    set -euo pipefail
    dirs=()
    for name in {{decorators}}; do
        if [ -d "workshops/$name" ]; then
            dirs+=("workshops/$name")
        fi
    done
    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No decorator workshops under workshops/ yet; collections/decorators/collection.json is left as it is"
        exit 0
    fi
    uv run jupyter workshop index "${dirs[@]}" --root . --out collections/decorators/collection.json --repo "{{repo}}" --id "{{decorators_id}}" --title "{{decorators_title}}" --description "{{decorators_description}}" --homepage "{{repo}}" --tag python --tag wrapt --tag decorators --ordered

# Write or refresh catalog.json from the collection indexes, recorded by relative path.
catalog:
    uv run jupyter workshop catalog catalog.json collections/*/collection.json --relative --title "{{catalog_title}}" --description "{{catalog_description}}" --homepage "{{repo}}"

# Binder installs from binder/requirements.txt, so it is the locked
# runtime set (no dev group) exported from uv.lock, and is regenerated
# whenever the lock changes.
# Relock and export the runtime dependencies to binder/requirements.txt.
requirements:
    uv lock
    uv export --no-dev --no-hashes --no-annotate -o binder/requirements.txt

# The extension's reference checkout is what agents read for the workshop
# format beyond the skill (docs/, examples/ and the source), so it is
# kept at the tag of the pinned release and moves with the pin.
# Pin a new jupyterlab-workshop release, relock, export, relink the skill and move the reference checkout.
bump VERSION:
    uv add "jupyterlab-workshop=={{VERSION}}"
    just requirements
    just skill
    git -C reference/jupyterlab-workshop fetch --tags
    git -C reference/jupyterlab-workshop checkout "{{VERSION}}"
    git add reference/jupyterlab-workshop

# The reference checkout is what agents read for wrapt's API and
# documentation, so it is kept at the tag of the release the workshops
# teach; each workshop's requirements.txt names that version too.
# Move the wrapt reference checkout to a release tag, e.g. `just bump-wrapt 2.4.1`.
bump-wrapt VERSION:
    git -C reference/wrapt fetch --tags
    git -C reference/wrapt checkout "{{VERSION}}"
    git add reference/wrapt
    @echo "reference/wrapt is at {{VERSION}}; update the wrapt pin in each workshop's requirements.txt to match"

# Remove what opening, running and publishing the workshops leaves behind.
clean:
    rm -rf workshops/*/_workshop workshops/*/work workshops/*/dist workshops/*/scratch
    rm -f results-*.xml
    find . -type d -name .ipynb_checkpoints -not -path "./.venv/*" -exec rm -rf {} +
    find . -type d -name __pycache__ -not -path "./.venv/*" -not -path "./scratch/*" -exec rm -rf {} +

# Also remove the environment and the skill link; run `just install` afterwards.
distclean: clean
    rm -rf .venv .claude/skills/jupyterlab-workshop-authoring
    git submodule deinit -f reference/jupyterlab-workshop reference/wrapt

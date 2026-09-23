#!/bin/bash
# Run once when the codespace is created. Does what the Binder postBuild
# does, in the codespace: installs JupyterLab and the extension from the
# same pinned requirements the Binder image uses, fills a wheelhouse for
# the workshops' environments, and writes the JupyterLab overrides, with
# two differences, both because a codespace belongs to the person who
# created it, tied to their GitHub account, and persists, where a Binder
# session is an anonymous, temporary container. The welcome message is
# the Codespaces one. And workshops are not forced to trusted, so the
# learner is shown what a workshop asks to do and decides before it runs
# anything in their codespace. pip rather than uv, as on Binder, since
# this is the learner's environment and the workshops use pip themselves.
#
# The analytics block is the same as Binder's but carries a token of its
# own, so the service tells the two apart and either can be revoked
# alone; it is as public as this file and only routes anonymous progress
# events to the workshops' service. .devcontainer/welcome.md tells the
# learner that progress is reported.
set -euo pipefail

cd "$(dirname "$0")/.."

python -m pip install --no-cache-dir -r binder/requirements.txt

# Notebook workshops build an environment of their own on first open,
# installing their requirements and ipykernel with pip. Download every
# workshop's requirements, and ipykernel, into a wheelhouse in the home
# directory and tell pip to look there first, so the install takes its
# wheels from disk rather than PyPI. It is find-links only, never
# no-index: pip still reaches PyPI for anything the wheelhouse lacks.
# This is the same arrangement as binder/postBuild.
shopt -s nullglob

wheels="${HOME}/.wheels"

mkdir -p "$wheels"

for requirements in workshops/*/requirements.txt; do
  python -m pip download --disable-pip-version-check -d "$wheels" -r "$requirements"
done

python -m pip download --disable-pip-version-check -d "$wheels" ipykernel

mkdir -p "${HOME}/.config/pip"

cat > "${HOME}/.config/pip/pip.conf" <<CONF
[global]
find-links = ${wheels}
CONF

# The overrides live in JupyterLab's application settings directory. Ask
# JupyterLab for it rather than assuming the Python prefix: it moves to
# the user's home for a user-level install, which pip falls back to when
# the prefix is not writable, and to /usr/local/share for some system
# installs. sudo covers a directory this user cannot write.
settings="$(python -c 'import os; from jupyterlab.commands import get_app_dir; print(os.path.join(get_app_dir(), "settings"))')"

overrides="$(mktemp)"

cat > "$overrides" <<'JSON'
{
  "@jupyterlab-workshop/labextension:panel": {
    "defaultWorkshop": "",
    "browseOnStart": true,
    "workshopsDirectory": "workshops",
    "collections": ["collections/decorators/collection.json", "collections/monkey-patching/collection.json"],
    "welcome": ".devcontainer/welcome.md",
    "disabledFeatures": [
      "open-directory",
      "open-url",
      "collections",
      "catalogs",
      "remove",
      "author"
    ],
    "analytics": {
      "sink": "https://workshop-analytics.grumpys.work/events",
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4NWYyZTk4OTBjZjE0NmQzOWFmNDFiZGVlYjExN2Q0NSIsInN1YiI6IndyYXB0LWNvZGVzcGFjZXMiLCJzY29wZSI6WyJpbmdlc3QiXSwibGFiZWxzIjp7ImRlcGxveW1lbnQiOiJ3cmFwdC1jb2Rlc3BhY2VzIn0sIm9yaWdpbnMiOltdLCJpYXQiOjE3OTAxMTUwNTQsIm5iZiI6MTc5MDExNTA1NCwiZXhwIjoxODIxMTM5MTk5fQ.G5W_xc2ukdtzGtM5UjI5wgdJOM6Uq9fs6a4-09odhkY"
    }
  }
}
JSON

if mkdir -p "$settings" 2>/dev/null && [ -w "$settings" ]; then
  install -m 644 "$overrides" "$settings/overrides.json"
else
  sudo mkdir -p "$settings"
  sudo install -m 644 "$overrides" "$settings/overrides.json"
fi

rm -f "$overrides"

echo "Wrote the JupyterLab overrides to $settings/overrides.json"

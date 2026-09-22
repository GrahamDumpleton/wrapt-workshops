# Configuration for JupyterLab started from this checkout. Jupyter does
# not look in the current directory for config files, so this one is
# named explicitly: `just lab` passes `--config=jupyter_lab_config.py`,
# and `uv run jupyter lab --config=jupyter_lab_config.py` does the same.
#
# Open the workshop browser with the checkout's own catalog and the
# decorators collection added for the session. The collection lists its
# workshops in the order to take them, numbered, rather than the order
# the workshops directory gives; the catalog offers the other collections
# of this repository to subscribe to, once there are others. Both are
# added for the session only; the browser offers Subscribe to keep them.
c.LabApp.default_url = (
    "/lab?catalog=catalog.json&collection=collections/decorators/collection.json"
)

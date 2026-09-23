"""Patches that install themselves when this module is imported.

Nothing calls anything here. Evaluating the decorator is what applies
the patch, so `import patches` is the whole of switching it on.
"""

import wrapt


@wrapt.patch_function_wrapper("shop.pricing", "fetch_price")
def announce(wrapped, instance, args, kwargs):
    print(f"patches.py saw fetch_price{args}")
    return wrapped(*args, **kwargs)

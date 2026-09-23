"""A patch for shop.shipping, in a module of its own.

Nothing here runs until install() is called. Registered by name as
"patches:install", this module is not even imported until
shop.shipping is.
"""

import wrapt

handles = {}


def announce(wrapped, instance, args, kwargs):
    print(f"patches.py saw {wrapped.__name__}{args}")
    return wrapped(*args, **kwargs)


def install(module):
    print(f"patches.py installing on {module.__name__}")
    handles["quote"] = wrapt.wrap_function_wrapper(module, "quote", announce)

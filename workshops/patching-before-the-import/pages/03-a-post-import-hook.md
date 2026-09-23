---
title: A post import hook
requires: [verify:post-import-hook, verify:fires-at-once]
---

# A post import hook

For anything more than "as soon as possible", wrapt has post import
hooks, in the manner of PEP 369. `@wrapt.when_imported("shop.invoices")`
registers the function it decorates to be called with the module,
once, when `shop.invoices` is imported. Inside, the patch is an
ordinary `wrap_function_wrapper` on the module object, so the hook
can keep the handle.

{open}`shop/invoices.py` is the module this page imports, and
`render` is what the hook patches.

```{cell-insert}
:id: insert-post-import-hook
:path: {{ notebook }}
:tags: [post-import-hook]
:run: true
handles = {}

@wrapt.when_imported("shop.invoices")
def install_invoices(module):
    print("hook ran for", module.__name__)
    handles["render"] = wrapt.wrap_function_wrapper(module, "render", capture)

registered_only = "render" not in handles

import shop.invoices

invoice = shop.invoices.render(["apple", "pear"])

print()
print("registered only, before the import:", registered_only)
print("handle kept by the hook           :", type(handles["render"]).__name__)
print(invoice)
```

Registering ran nothing. The import ran the hook, which printed, and
by the time the import statement returned the patch was in place
with its handle in `handles`. A consumer whose first line is
`from shop.invoices import render` would copy the wrapper, not the
original, because the hook runs before the import returns to
whoever asked for it. That is the answer to the previous workshop:
register the hook at the earliest point in the program and every
importer, whatever the order, gets the patched module.

`wrapt.register_post_import_hook(install_invoices, "shop.invoices")`
is the same registration without the decorator.

## Already imported

`shop.pricing` was imported by the first cell. Register a hook for it
and watch when it runs.

```{cell-insert}
:id: insert-fires-at-once
:path: {{ notebook }}
:tags: [fires-at-once]
:run: true
@wrapt.when_imported("shop.pricing")
def install_pricing(module):
    print("hook ran for", module.__name__)
    handles["fetch_price"] = wrapt.wrap_function_wrapper(module, "fetch_price", capture)

fired_at_once = "fetch_price" in handles

print()
print("fired at registration:", fired_at_once)
```

At once. A hook for a module that is already imported fires during
registration, so the same registration is right whether the patch
code runs before or after the module it is for, which is what makes
it safe to register from a place that does not know the import order.

```{verify}
:id: post-import-hook
:label: The hook waited for the import and kept the handle
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed post-import-hook
registered_only and type(handles["render"]).__name__ == "FunctionWrapper" and invoice == "- apple\n- pear" and calls[-1] == ("render", (["apple", "pear"],))
```

```{verify}
:id: fires-at-once
:label: The hook for an imported module fired during registration
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed fires-at-once
fired_at_once and type(handles["fetch_price"]).__name__ == "FunctionWrapper"
```

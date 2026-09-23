---
title: The string form
requires: [verify:string-form]
---

# The string form

A hook registered as a function has to exist, so the module holding
it has been imported, along with whatever it imports. When patch code
lives in a module you would rather not load unless it is needed, the
hook can be named as a string, `"package.module:function"`, and wrapt
imports that module only when the target is.

{open}`patches.py` is such a module, shipped with the workshop: an
`install` function that patches `quote` in {open}`shop/shipping.py`
and keeps the handle in a dictionary of its own.

```{cell-insert}
:id: insert-string-form
:path: {{ notebook }}
:tags: [string-form]
:run: true
wrapt.register_post_import_hook("patches:install", "shop.shipping")

patches_before = "patches" in sys.modules

import shop.shipping

patches_after = "patches" in sys.modules
quote = shop.shipping.quote(3)

import patches

print()
print("patches imported after registering:", patches_before)
print("patches imported after the target :", patches_after)
print("quote                             :", quote)
print("handle kept in patches.handles    :", type(patches.handles["quote"]).__name__)
```

Registering the string imported nothing. Importing `shop.shipping`
imported `patches`, called its `install` with the module, and the
patch was in place before the import returned. The `import patches`
in the cell afterwards only gives the notebook a name for the module
already loaded, so the handle can be read.

This is the form an instrumentation package uses for a long list of
targets, most of which a given program never imports: the registrations
are cheap, and the patch code for each target loads only if the
target does.

```{verify}
:id: string-form
:label: The patch module was imported only when its target was
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed string-form
not patches_before and patches_after and quote == 4.5 and type(patches.handles["quote"]).__name__ == "FunctionWrapper" and wrapt.is_wrapped_by(shop.shipping.quote, patches.handles["quote"])
```

```{hint}
:title: Entry points, the packaged form
`wrapt.discover_post_import_hooks("some.group")` reads every entry
point in a named group from installed package metadata and registers
each as a post import hook, with the entry point's name as the target
module. A patch package then declares its targets in `pyproject.toml`
and the application chooses which groups to load. It needs an
installed distribution to demonstrate, so it is named here and not
run.
```

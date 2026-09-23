---
title: The two steps
requires: [verify:two-steps]
---

# The two steps

Every wrap function does two things: find the attribute, and set the
replacement. wrapt exposes both. `wrapt.resolve_path(target, name)`
returns the parent object, the attribute name and the original,
reading class namespaces along the method resolution order the way
`wrap_function_wrapper` does; `wrapt.apply_patch(parent, attribute,
replacement)` is the `setattr`. Use them when the original is wanted
for something other than wrapping.

Here the replacement is not a proxy at all, just a function that
answers with a fixed currency, keeping the original to hand for
putting back.

```{cell-insert}
:id: insert-two-steps
:path: {{ notebook }}
:tags: [two-steps]
:run: true
parent, attribute, original = wrapt.resolve_path(shop.config, "currency")

def fixed_currency():
    return "EUR"

wrapt.apply_patch(parent, attribute, fixed_currency)
patched = shop.config.currency()

wrapt.apply_patch(parent, attribute, original)
restored = shop.config.currency()

print("parent    :", parent.__name__, "attribute:", attribute)
print("original  :", original.__name__)
print("patched   :", patched)
print("restored  :", restored, "and the same object:", shop.config.currency is original)
```

The patch went in and came out by hand, correctly, because
`resolve_path` gave the real original rather than whatever `getattr`
would have produced. What it did not give is a handle: a replacement
that is not a wrapt proxy has no `__wrapped__` for the chain to
follow, so `is_wrapped_by` cannot find it and `unwrap_object` cannot
remove it, and anyone who patches over the top of it is stuck, as
the lifecycle workshop showed with a closure. That is why
`wrap_object` and a proxy are the default, and the two steps are
for the cases that need the original itself.

The `Watched` proxy from the second page is still on `settings`.
Take it out.

```{cell-insert}
:id: insert-settings-out
:path: {{ notebook }}
:tags: [settings-out]
:run: true
wrapt.unwrap_object(shop.config, "settings", watched)

print("settings:", chain(shop.config, "settings"))
```

```{verify}
:id: two-steps
:label: The two steps patched and restored currency, and settings is plain again
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed settings-out
patched == "EUR" and restored == "USD" and shop.config.currency is original and chain(shop.config, "settings") == ["dict"]
```

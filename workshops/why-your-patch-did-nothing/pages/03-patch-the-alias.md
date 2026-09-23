---
title: Patch the alias
requires: [verify:alias-patched]
---

# Patch the alias

A patch has to land where the name is looked up. `total` looks
`fetch_price` up in `shop.checkout`, so patch it there as well, and
call `total` again.

```{cell-insert}
:id: insert-alias
:path: {{ notebook }}
:tags: [alias]
:run: true
calls.clear()

alias_handle = wrapt.wrap_function_wrapper(shop.checkout, "fetch_price", capture)

total = shop.checkout.total(["apple", "pear"])
seen_by_total = len(calls)

print("total              :", total)
print("calls seen by total:", seen_by_total)
```

Two calls, as intended. The patch on `shop.checkout` wraps the
reference that module holds, and `total` finds the wrapper where it
always looked. Every module that imported the name is a place to
patch; there is no list of them, so the cost of this way round is
knowing your callers, which is fine for a package you can read and
less fine for one you cannot.

The other way round is to patch `shop.pricing` before `shop.checkout`
is imported, so that the `from` import copies the wrapper rather than
the original. That needs the patch to run first, whatever the import
order of the program, and it is what the next workshop's post import
hooks are for.

Take both patches out before going on, with the handles.

```{cell-insert}
:id: insert-alias-out
:path: {{ notebook }}
:tags: [alias-out]
:run: true
wrapt.unwrap_object(shop.checkout, "fetch_price", alias_handle)
wrapt.unwrap_object(shop.pricing, "fetch_price", pricing_handle)

print("checkout holds a:", type(shop.checkout.fetch_price).__name__)
print("pricing holds a :", type(shop.pricing.fetch_price).__name__)
print("same object     :", shop.checkout.fetch_price is shop.pricing.fetch_price)
```

```{verify}
:id: alias-patched
:label: Patching the alias reached total's calls, and both patches are out
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed alias-out
seen_by_total == 2 and type(shop.checkout.fetch_price).__name__ == "function" and shop.checkout.fetch_price is shop.pricing.fetch_price
```

```{hint}
:title: Removal put the same object back in both places
`unwrap_object` on the alias restored the reference `shop.checkout`
held, and on the original module the function it defined, and they
are the same object again, as they were before either patch. Each
patch was removed where it was made, with its own handle.
```

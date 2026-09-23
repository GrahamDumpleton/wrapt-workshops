---
title: Two dictionaries
requires: [verify:two-dictionaries]
---

# Two dictionaries

Where did `_self_count` go? Not into `vars(counted)`, because
`__dict__` is forwarded too: `vars()` on a proxy is the target's
dictionary, which is what code introspecting the object should see.
The proxy's own dictionary is on `__self_dict__`.

```{cell-insert}
:id: insert-two-dictionaries
:path: {{ notebook }}
:tags: [two-dictionaries]
:run: true
seen = dict(vars(counted))
own = dict(counted.__self_dict__)

print("vars(counted)        :", seen)
print("counted.__self_dict__:", own)
```

`vars(counted)` is the shop's dictionary, `count` and all.
`__self_dict__` holds `_self_count`, beside two entries wrapt keeps
there itself. It is the live dictionary rather than a copy, so a
change made to it shows on the proxy, and it is read only as an
attribute: assigning to `__self_dict__` raises.

That is the whole layout. Every proxy has two dictionaries: the
target's, which `__dict__` and `vars()` show and plain assignment
fills, and its own, which `_self_` assignment fills and
`__self_dict__` shows.

```{verify}
:id: two-dictionaries
:label: vars() shows the shop's dictionary and the proxy's own dictionary holds the count
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed two-dictionaries
"_self_count" in own and "_self_count" not in seen and "name" in seen
```

```{hint}
:title: A combined view, if you want one
The wrapt documentation's known issues page shows a subclass that
overrides `__dict__` with a property merging the two dictionaries,
for code that must see the proxy's own state through `vars()`. Most
proxies want the opposite, which is why the default is to forward.
```

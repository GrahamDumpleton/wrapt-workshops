---
title: The mock you know
requires: [verify:mock-patch]
---

# The mock you know

`unittest.mock.patch` is the standard library's temporary patch. As a
context manager it replaces the named attribute for the block and
puts the original back on the way out. Patch `fetch_price`, give the
replacement a return value, and look at what the module holds inside
the block and after it.

```{cell-insert}
:id: insert-mock-patch
:path: {{ notebook }}
:tags: [mock-patch]
:run: true
with mock.patch("shop.pricing.fetch_price") as fake:
    fake.return_value = 9.9
    inside = shop.pricing.fetch_price("apple")
    inside_type = type(shop.pricing.fetch_price).__name__

after_type = type(shop.pricing.fetch_price).__name__

print("inside the block:", inside, "from a", inside_type)
print("after the block :", after_type)
```

Inside the block `fetch_price` is a `MagicMock`, and the original
never ran: `9.9` is the mock's answer, not a price. That is what
`mock.patch` does, replace wholesale. It is the right tool when the
original must not run, a network call in a unit test, and it has two
limits that matter here. The original is gone for the block, so a
test cannot see what it would have done, and the replacement is not
a method, so a patch on a class method or a static method needs
`autospec` and care.

The wrapt forms on the next two pages keep the original running
beneath a wrapper that receives `wrapped`, `instance`, `args` and
`kwargs`, so they observe as easily as they replace, and they know
what kind of method they landed on.

```{verify}
:id: mock-patch
:label: mock.patch replaced fetch_price for the block and restored it after
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed mock-patch
inside == 9.9 and inside_type == "MagicMock" and after_type == "function" and calls == []
```

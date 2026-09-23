---
title: Where assignment lands
requires: [verify:assignment-lands, verify:mock-keeps-its-own]
---

# Where assignment lands

Wrap the shop and give the proxy a count.

```{cell-insert}
:id: insert-assignment
:path: {{ notebook }}
:tags: [assignment]
:run: true
proxy = wrapt.BaseObjectProxy(shop)

proxy.count = 0

print("vars(shop)   :", vars(shop))
print("count on shop:", "count" in vars(shop))
```

The count is on the shop. Assignment through a proxy is forwarded
like everything else, so `proxy.count` and `shop.count` are one
attribute, and any other code holding the shop can see it and change
it. For a proxy that is meant to be invisible that is correct, and
for one that needs a count of its own it is a leak.

The tool you may reach for instead is `unittest.mock.Mock` with
`wraps`, which forwards calls to the shop and keeps its own
attributes. See what it keeps and what it gives up.

```{cell-insert}
:id: insert-mock
:path: {{ notebook }}
:tags: [mock]
:run: true
recorder = mock.Mock(wraps=shop)

recorder.calls = 0
recorder.buy("apple")

print("calls on shop     :", "calls" in vars(shop))
print("isinstance Shop   :", isinstance(recorder, Shop))
print("recorder.name     :", recorder.name)
print("buy was called    :", recorder.buy.call_count, "time")
```

The mock keeps `calls` to itself by not being the shop at all. It is
not a `Shop` to `isinstance`, its `name` is another mock rather than
the string, and every attribute is recorded whether you wanted that
or not. That is the right trade for a test double and the wrong one
for a proxy, which has to be the shop to the code that receives it
and still keep something back. The next page is how.

```{verify}
:id: assignment-lands
:label: The assignment through the proxy landed on the shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed assignment
"count" in vars(shop) and shop.count == 0 and "count" not in proxy.__self_dict__
```

```{verify}
:id: mock-keeps-its-own
:label: The mock keeps its attribute and is not a Shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed mock
"calls" not in vars(shop) and not isinstance(recorder, Shop) and recorder.buy.call_count == 1
```

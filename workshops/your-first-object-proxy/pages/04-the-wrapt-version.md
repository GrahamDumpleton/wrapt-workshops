---
title: The wrapt version
requires: [verify:proxy-report, verify:proxy-assign]
---

# The wrapt version

Wrap the same shop in `wrapt.BaseObjectProxy` and run the same
report.

```{cell-insert}
:id: insert-proxy
:path: {{ notebook }}
:tags: [proxy]
:run: true
proxy = wrapt.BaseObjectProxy(shop)

proxy_report = report(proxy)

for key, value in proxy_report.items():
    print(f"{key:>10}: {value}")

print()
print("__wrapped__ is shop:", proxy.__wrapped__ is shop)
```

Four right answers, and nothing written. `isinstance` is true because
the proxy forwards `__class__` along with every other attribute, so
the proxy's `__class__` is `Shop`. `len`, `==` and `str` work because
`BaseObjectProxy` defines those special methods, and nearly every
other one, to call the wrapped object's. The original is on
`__wrapped__`, which is the one attribute the proxy keeps for itself
rather than forwarding.

Now the assignment.

```{cell-insert}
:id: insert-proxy-assign
:path: {{ notebook }}
:tags: [proxy-assign]
:run: true
proxy.name = "market"

print("proxy.name:", proxy.name)
print("shop.name :", shop.name)
```

The shop says `market`. Assignment through the proxy is forwarded
too, so the proxy holds no copy and code that updates the object
through it updates the object. Where a proxy keeps state of its own,
and how it says so, is the third workshop.

Two questions still tell the two apart, and it is worth seeing them
now.

```{cell-insert}
:id: insert-proxy-type
:path: {{ notebook }}
:tags: [proxy-type]
:run: true
print("type(proxy)    :", type(proxy))
print("proxy.__class__:", proxy.__class__)
print("repr(proxy)    :", repr(proxy))
print("str(proxy)     :", str(proxy))
```

`type()` reads the real type, not the `__class__` attribute, so it
names the proxy. And `repr()` announces the proxy and the object it
is standing in for, on purpose, so that debugging output never hides
that a proxy is there, while `str()` and `print()` show the shop.
What else does not pass through, and why, is the next workshop.

```{verify}
:id: proxy-report
:label: The proxy passes isinstance, len, equality and str
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed proxy
proxy_report["isinstance"] is True and proxy_report["len"] == 3 and proxy_report["equal"] is True and proxy_report["str"] == "Shop('corner')" and proxy.__wrapped__ is shop
```

```{verify}
:id: proxy-assign
:label: An assignment through the proxy lands on the shop
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed proxy-assign
shop.name == "market" and "name" not in proxy.__self_dict__
```

```{hint}
:title: About the name in type()
`type(proxy)` prints `_wrappers.ObjectProxy`, from the C extension
wrapt installs on the platforms it has wheels for, where the class
keeps its older name. `wrapt.BaseObjectProxy` is that class, and the
name to use for it; the pure Python implementation behaves the same.
```

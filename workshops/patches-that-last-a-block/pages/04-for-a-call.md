---
title: For a call
requires: [verify:for-a-call]
---

# For a call

`@wrapt.transient_function_wrapper` is the decorator form, and it is
read in two steps. The outer decorator, with the target and the name,
describes the patch and makes a decorator out of the wrapper: at this
point nothing is patched. Applying that decorator to a function
chooses the calls the patch covers: each call installs the patch on
the way in and removes it on the way out. This one stubs the price.

```{cell-insert}
:id: insert-for-a-call
:path: {{ notebook }}
:tags: [for-a-call]
:run: true
@wrapt.transient_function_wrapper(shop.pricing, "fetch_price")
def stub_price(wrapped, instance, args, kwargs):
    return 0.0

@stub_price
def checkout(item):
    return shop.pricing.fetch_price(item)

during = checkout("fig")
after = shop.pricing.fetch_price("fig")

print("during checkout:", during)
print("after checkout :", after)
print("chain          :", chain(shop.pricing, "fetch_price"))
```

`checkout` saw the stub and got `0.0`; the direct call afterwards
got the real price, and the chain is plain. Applied to a test
function, `@stub_price` makes the patch last exactly that test, which
is the pattern the wrapt examples build a test suite on.

The removal happens whether or not the call raised. `failing` calls
the patched function and then raises.

```{cell-insert}
:id: insert-for-a-call-raising
:path: {{ notebook }}
:tags: [for-a-call-raising]
:run: true
@stub_price
def failing(item):
    shop.pricing.fetch_price(item)
    raise RuntimeError("the checkout failed")

try:
    failing("fig")
    problem = "no error"
except RuntimeError as error:
    problem = str(error)

print("problem:", problem)
print("chain  :", chain(shop.pricing, "fetch_price"))
```

The error came through and the patch came out, so nothing that runs
after a failed test inherits its stub.

```{verify}
:id: for-a-call
:label: The stub lasted the call, including one that raised
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed for-a-call-raising
during == 0.0 and after == 2.0 and problem == "the checkout failed" and chain(shop.pricing, "fetch_price") == ["function"]
```

```{hint}
:title: Not on a generator based context manager
Applying `transient_function_wrapper` around a function decorated
with `contextlib.contextmanager` patches only the moment the
generator object is created, since calling a generator function runs
none of its body. For a block, use `scoped_function_wrapper`.
```

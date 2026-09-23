---
title: Taking them out
requires: [verify:as-shipped]
---

# Taking them out

Each descriptor is the handle for its patch, and `unwrap_object`
removes it as it removes any wrapper: restoring what was beneath, or
deleting the slot when the wrap created it. Take the four out, the
outer `name` one first, then the inner, though either order works.

```{cell-insert}
:id: insert-taking-them-out
:path: {{ notebook }}
:tags: [taking-them-out]
:run: true
wrapt.unwrap_object("shop.cart", "Shop.name", upper_handle)

print("name after one removal:", repr(corner.name))

wrapt.unwrap_object("shop.cart", "Shop.name", name_handle)
wrapt.unwrap_object("shop.cart", "Shop.label", label_handle)
wrapt.unwrap_object("shop.cart", "Shop.region", region_handle)

print("name                  :", repr(corner.name))
print("label                 :", repr(corner.label))
print("region                :", repr(corner.region))
print()
print("name on the class     :", "name" in Shop.__dict__)
print("label on the class    :", type(Shop.__dict__["label"]).__name__)
print("region on the class   :", repr(Shop.__dict__["region"]))
```

After the first removal `name` is `Tagged('Corner Store')`: the inner
descriptor was restored to the class. After the rest, every value is
a plain string again, `name` is gone from the class namespace, since
the wrap created that slot, `label` is the `property` the module
defined, and `region` is the string it defined. The class is as
shipped, and every shop, before or after the patches, reads as it
did.

```{verify}
:id: as-shipped
:label: Every descriptor is out and the class is as shipped
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed taking-them-out
type(corner.name) is str and corner.label == "CORNER STORE" and type(corner.region) is str and "name" not in Shop.__dict__ and type(Shop.__dict__["label"]) is property and Shop.__dict__["region"] == "local"
```

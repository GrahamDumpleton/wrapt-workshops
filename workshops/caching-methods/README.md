# Caching methods

Put `functools.lru_cache` on a method and find the three problems
that come with it: one budget shared by every instance, instances
held alive by the cache, and a `TypeError` for anything unhashable.
Then `wrapt.lru_cache`, which keeps a cache per instance, and what
that means for `cache_info()`, `cache_clear()` and pickling.

Fifteen minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

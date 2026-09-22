# Wrapping async functions

Put a synchronous timer on an `async def` and watch it time the
creation of a coroutine rather than its run. Fix it with an
`async def` wrapper, write one timer that serves `def` and
`async def` alike, then use `wrapt.synchronized` on coroutines, where
it switches to an `asyncio.Lock`, and see what its non-reentrancy
asks of you.

Fifteen minutes, in a notebook, with top level `await`. The workshop
installs wrapt into an environment of its own.

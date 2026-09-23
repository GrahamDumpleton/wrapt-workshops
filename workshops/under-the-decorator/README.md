# Under the decorator

`FunctionWrapper` is the callable proxy every wrapt decorator builds,
and reading it through an instance gives a `BoundFunctionWrapper`
that knows its instance, its parent and what kind of method it was.
Predict the binding of an instance method, a class method and a
static method, then write a wrapper pair of your own with
`__bound_function_wrapper__`.

Twenty minutes, in a notebook. The workshop installs wrapt into an
environment of its own.

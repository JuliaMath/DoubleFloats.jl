

## looking ahead

When you are `using DoubleFloats`, two related numeric types become available: `Double` and `FastDouble`.

These types are identical in coverage and compatibility. Any function that knows of one knows of both.
Every function that is imported from Base.Math and overloaded in order to just work and work well with
`Doubles` will do the same with `FastDoubles`.  And they utilize identical code for some of their work.


- `Double` is the accuracy stalwart.  The algorithms and refinements that apply when used with reasonably
sized values, should limit the accrual of relative error from any basic arithmetic operation 

- `FastDoubles` do not have this way of working; instead, they offer a more performant alternative.
With computations that are heavily reliant upon elementary functions, `FastDoubles` are helpful.

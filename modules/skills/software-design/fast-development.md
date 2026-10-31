## Fast Development design

1. Identify the requested behavior and the smallest design that will remain
   clear and maintainable as it is used.
2. Keep module responsibilities and interfaces straightforward. Prefer
   readable, conventional implementation over extra abstraction.
3. Avoid concurrency, infrastructure, extension points, and optimization
   unless the current requirements justify them.
4. Consider important contracts and common edge cases without turning a
   bounded change into a broad redesign.

# PrettyPrinting.jl


*PrettyPrinting* is a Julia library for optimal formatting of composite data
structures.  It works by generating all possible layouts of the data, and then
selecting the best layout that fits the screen width.  The algorithm for
finding the optimal layout is based upon [Phillip Yelland, A New Approach to
Optimal Code Formatting, 2016](https://ai.google/research/pubs/pub44667).

Out of the box, PrettyPrinting can format Julia code and standard Julia
containers.  It can be easily extended to format custom data structures.

## Table of Contents

```@contents
Pages = ["guide.md", "api.md", "test.md"]
```

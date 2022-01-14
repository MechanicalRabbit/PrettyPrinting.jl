# PrettyPrinting.jl

[![Build Status][ci-img]][ci-url]
[![Code Coverage Status][codecov-img]][codecov-url]
[![Open Issues][issues-img]][issues-url]
[![Documentation][doc-img]][doc-url]
[![MIT License][license-img]][license-url]

*PrettyPrinting* is a Julia library for optimal formatting of composite data
structures.  It works by generating all possible layouts of the data, and then
selecting the best layout that fits the screen width.  The algorithm for
finding the optimal layout is based upon [Phillip Yelland, A New Approach to
Optimal Code Formatting, 2016][rfmt-paper].

Out of the box, PrettyPrinting can format Julia code and standard Julia
containers.  It can be easily extended to format custom data structures.

To learn more about PrettyPrinting, check the [**Quick Start**](#quick-start)
below, read the [**Documentation**][doc-url], or watch the
[**Presentation at JuliaCon 2021**][juliacon2021-url] ([**slides**][juliacon2021-slides]).

[![PrettyPrinting | JuliaCon 2021][juliacon2021-img]][juliacon2021-url]


## Quick Start

If you work with nested data structures in Julia REPL, you may find the way
they are displayed unsatisfactory.  For example:

```julia
julia> data = [(name = "POLICE",
                employees = [(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing),
                             (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)]),
               (name = "OEMC",
                employees = [(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68),
                             (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])]
2-element Vector{NamedTuple{(:name, :employees), T} where T<:Tuple}:
 (name = "POLICE", employees = NamedTuple{(:name, :position, :salary, :rate), Tuple{String, String, Int64, Missing}}[(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing), (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)])
 (name = "OEMC", employees = NamedTuple{(:name, :position, :salary, :rate), Tuple{String, String, Missing, Float64}}[(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68), (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])
```

If this is the case, consider using PrettyPrinting.  First, install it with the
Julia package manager:

```julia
julia> using Pkg
julia> Pkg.add("PrettyPrinting")
```

Import the package:

```julia
julia> using PrettyPrinting
```

Now you can use `pprint()` to display your complex data.  For example:

```julia
julia> pprint(data)
[(name = "POLICE",
  employees = [(name = "JEFFERY A",
                position = "SERGEANT",
                salary = 101442,
                rate = missing),
               (name = "NANCY A",
                position = "POLICE OFFICER",
                salary = 80016,
                rate = missing)]),
 (name = "OEMC",
  employees = [(name = "LAKENYA A",
                position = "CROSSING GUARD",
                salary = missing,
                rate = 17.68),
               (name = "DORIS A",
                position = "CROSSING GUARD",
                salary = missing,
                rate = 19.38)])]
```

PrettyPrinting knows how to format tuples, named tuples, vectors, sets, and
dictionaries.  It can also format Julia code represented as an `Expr` object.
To format custom data types, implement either `PrettyPrinting.quoteof()` or
`PrettyPrinting.tile()`, as described in the [**Documentation**][doc-url].


[ci-img]: https://github.com/MechanicalRabbit/PrettyPrinting.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/MechanicalRabbit/PrettyPrinting.jl/actions?query=workflow%3ACI+branch%3Amaster
[codecov-img]: https://codecov.io/gh/MechanicalRabbit/PrettyPrinting.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/MechanicalRabbit/PrettyPrinting.jl
[issues-img]: https://img.shields.io/github/issues/MechanicalRabbit/PrettyPrinting.jl.svg
[issues-url]: https://github.com/MechanicalRabbit/PrettyPrinting.jl/issues
[doc-img]: https://img.shields.io/badge/doc-stable-blue.svg
[doc-url]: https://mechanicalrabbit.github.io/PrettyPrinting.jl/stable/
[license-img]: https://img.shields.io/badge/license-MIT-blue.svg
[license-url]: https://raw.githubusercontent.com/MechanicalRabbit/PrettyPrinting.jl/master/LICENSE.md
[rfmt-paper]: https://ai.google/research/pubs/pub44667
[juliacon2021-img]: https://img.youtube.com/vi/Pa92w_ACp_c/maxresdefault.jpg
[juliacon2021-url]: https://www.youtube.com/watch?v=Pa92w_ACp_c
[juliacon2021-slides]: https://github.com/MechanicalRabbit/PrettyPrinting.jl/files/7870322/PrettyPrinting-JuliaCon2021.pdf

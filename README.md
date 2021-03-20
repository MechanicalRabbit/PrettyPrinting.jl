# PrettyPrinting.jl

*PrettyPrinting is a Julia library for optimal formatting of composite data
structures on a fixed-width terminal.*

[![Build Status][ci-img]][ci-url]
[![Code Coverage Status][codecov-img]][codecov-url]
[![Open Issues][issues-img]][issues-url]
[![Documentation][doc-dev-img]][doc-dev-url]
[![MIT License][license-img]][license-url]


## Quick Start

Install the package using the Julia package manager:

```julia
julia> using Pkg
julia> Pkg.add("PrettyPrinting")
```

To start using the package, import it:

```julia
julia> using PrettyPrinting
```

Use function `pprint()` to display complex data structures.  For example:

```julia
julia> data = [(name = "POLICE",
                employees = [(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing),
                             (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)]),
               (name = "OEMC",
                employees = [(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68),
                             (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])]
2-element Array{NamedTuple{(:name, :employees),T} where T<:Tuple,1}:
 (name = "POLICE", employees = NamedTuple{(:name, :position, :salary, :rate),Tuple{String,String,Int64,Missing}}[(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing), (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)])
 (name = "OEMC", employees = NamedTuple{(:name, :position, :salary, :rate),Tuple{String,String,Missing,Float64}}[(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68), (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])

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

PrettyPrinting knows how to format tuples, vectors, and dictionaries.  Other
data types should implement the function `tile()` as described in the
[**Documentation**][doc-dev-url].


## Acknowledgements

The algorithm for finding the optimal layout is based upon
[Phillip Yelland, A New Approach to Optimal Code Formatting, 2016][rfmt-paper].


[ci-img]: https://github.com/MechanicalRabbit/PrettyPrinting.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/MechanicalRabbit/PrettyPrinting.jl/actions?query=workflow%3ACI+branch%3Amaster
[codecov-img]: https://codecov.io/gh/MechanicalRabbit/PrettyPrinting.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/MechanicalRabbit/PrettyPrinting.jl
[issues-img]: https://img.shields.io/github/issues/MechanicalRabbit/PrettyPrinting.jl.svg
[issues-url]: https://github.com/MechanicalRabbit/PrettyPrinting.jl/issues
[doc-dev-img]: https://img.shields.io/badge/doc-dev-blue.svg
[doc-dev-url]: https://mechanicalrabbit.github.io/PrettyPrinting.jl/dev/
[license-img]: https://img.shields.io/badge/license-MIT-blue.svg
[license-url]: https://raw.githubusercontent.com/MechanicalRabbit/PrettyPrinting.jl/master/LICENSE.md
[rfmt-paper]: https://ai.google/research/pubs/pub44667

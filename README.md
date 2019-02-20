# PrettyPrinting.jl

*PrettyPrinting is a Julia library for optimal formatting of composite data
structures on a fixed-width terminal.*

[![Linux/OSX Build Status][travis-img]][travis-url]
[![Windows Build Status][appveyor-img]][appveyor-url]
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
               (name = "FIRE",
                employees = [(name = "JAMES A", position = "FIRE ENGINEER-EMT", salary = 103350, rate = missing),
                             (name = "DANIEL A", position = "FIRE FIGHTER-EMT", salary = 95484, rate = missing)]),
               (name = "OEMC",
                employees = [(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68),
                             (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])]
3-element Array{NamedTuple{(:name, :employees),T} where T<:Tuple,1}:
 (name = "POLICE", employees = NamedTuple{(:name, :position, :salary, :rate),Tuple{String,String,Int64,Missing}}[(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing), (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)])
 (name = "FIRE", employees = NamedTuple{(:name, :position, :salary, :rate),Tuple{String,String,Int64,Missing}}[(name = "JAMES A", position = "FIRE ENGINEER-EMT", salary = 103350, rate = missing), (name = "DANIEL A", position = "FIRE FIGHTER-EMT", salary = 95484, rate = missing)])
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
 (name = "FIRE",
  employees = [(name = "JAMES A",
                position = "FIRE ENGINEER-EMT",
                salary = 103350,
                rate = missing),
               (name = "DANIEL A",
                position = "FIRE FIGHTER-EMT",
                salary = 95484,
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
[**documentation**][doc-dev-url].


## Acknowledgements

The algorithm for finding the optimal layout is based upon
[Phillip Yelland, A New Approach to Optimal Code Formatting, 2016][rfmt-paper].


[travis-img]: https://travis-ci.org/rbt-lang/PrettyPrinting.jl.svg?branch=master
[travis-url]: https://travis-ci.org/rbt-lang/PrettyPrinting.jl
[appveyor-img]: https://ci.appveyor.com/api/projects/status/github/rbt-lang/PrettyPrinting.jl?branch=master&svg=true
[appveyor-url]: https://ci.appveyor.com/project/rbt-lang/prettyprinting-jl/branch/master
[codecov-img]: https://codecov.io/gh/rbt-lang/PrettyPrinting.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/rbt-lang/PrettyPrinting.jl
[issues-img]: https://img.shields.io/github/issues/rbt-lang/PrettyPrinting.jl.svg
[issues-url]: https://github.com/rbt-lang/PrettyPrinting.jl/issues
[doc-dev-img]: https://img.shields.io/badge/doc-dev-blue.svg
[doc-dev-url]: https://rbt-lang.github.io/PrettyPrinting.jl/dev/
[license-img]: https://img.shields.io/badge/license-MIT-blue.svg
[license-url]: https://raw.githubusercontent.com/rbt-lang/PrettyPrinting.jl/master/LICENSE.md
[rfmt-paper]: https://ai.google/research/pubs/pub44667

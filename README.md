# PPrint.jl

*PPrint is a Julia library for optimal formatting of composite data structures
on a fixed-width terminal.*

[![Linux/OSX Build Status][travis-img]][travis-url]
[![Windows Build Status][appveyor-img]][appveyor-url]
[![Code Coverage Status][codecov-img]][codecov-url]
[![Open Issues][issues-img]][issues-url]
[![Documentation][doc-dev-img]][doc-dev-url]
[![MIT License][license-img]][license-url]


# Quick Start

Install the package by cloning the package repository:

```julia
julia> using Pkg
julia> Pkg.clone("https://github.com/rbt-lang/PPrint.jl")

julia> using PPrint
```

Now you can use `PPrint.pprint()` to display complex data structures that are
poorly represented by Julia.

Let us demonstrate it by printing the directory tree of a Julia package.

```julia
julia> function pkgtree(pkg)
           top = dirname(dirname(pathof(pkg)))
           roots = Dict(top => [])
           for (root, dirs, files) in walkdir(top)
               append!(roots[root], [
                   [dir => (roots[joinpath(root, dir)] = []) for dir in dirs];
                   files
               ])
           end
           roots[top]
       end

julia> tree = pkgtree(PPrint)
12-element Array{Any,1}:
 ".git" => Any["branches"=>Any[], "hooks"=>Any["applypatch-msg.sample", "commit-
msg.sample", "fsmonitor-watchman.sample", "post-update.sample", "pre-applypatch.
sample", "pre-commit.sample", "pre-push.sample", "pre-rebase.sample", "pre-recei
ve.sample", "prepare-commit-msg.sample", "update.sample"], "info"=>Any["exclude"
], "objects"=>Any["info"=>Any[], "pack"=>Any[]], "refs"=>Any["heads"=>Any[], "ta
gs"=>Any[]], "HEAD", "config", "description"]
  "doc" => Any["src"=>Any["index.md"], ".gitignore", "make.jl"]





  "src" => Any["PPrint.jl", "fit.jl", "tile.jl"]





 "test" => Any["doc"=>Any[], "coverage.jl", "runtests.jl"]





         ".appveyor.yml"





         ".codecov.yml"





         ".gitignore"





         ".travis.yml"





         "LICENSE.md"





         "Project.toml"




         "README.md"





         "REQUIRE"
```

The output is garbled because the tree does not fit the output terminal.

By contrast, `PPrint.pprint()` respects the width of the output screen.

```julia
julia> pprint(tree)
[".git" => ["branches" => [],
            "hooks" => ["applypatch-msg.sample",
                        "commit-msg.sample",
                        "fsmonitor-watchman.sample",
                        "post-update.sample",
                        "pre-applypatch.sample",
                        "pre-commit.sample",
                        "pre-push.sample",
                        "pre-rebase.sample",
                        "pre-receive.sample",
                        "prepare-commit-msg.sample",
                        "update.sample"],
            "info" => ["exclude"],
            "objects" => ["info" => [], "pack" => []],
            "refs" => ["heads" => [], "tags" => []],
            "HEAD",
            "config",
            "description"],
 "doc" => ["src" => ["index.md"], ".gitignore", "make.jl"],
 "src" => ["PPrint.jl", "fit.jl", "tile.jl"],
 "test" => ["doc" => [], "coverage.jl", "runtests.jl"],
 ".appveyor.yml",
 ".codecov.yml",
 ".gitignore",
 ".travis.yml",
 "LICENSE.md",
 "Project.toml",
 "README.md",
 "REQUIRE"]
```


# Acknowledgements

The algorithm for finding the optimal layout is based upon
[Phillip Yelland, A New Approach to Optimal Code Formatting, 2016][rfmt-paper].


[travis-img]: https://travis-ci.org/rbt-lang/PPrint.jl.svg?branch=master
[travis-url]: https://travis-ci.org/rbt-lang/PPrint.jl
[appveyor-img]: https://ci.appveyor.com/api/projects/status/github/rbt-lang/PPrint.jl?branch=master&svg=true
[appveyor-url]: https://ci.appveyor.com/project/rbt-lang/pprint-jl/branch/master
[codecov-img]: https://codecov.io/gh/rbt-lang/PPrint.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/rbt-lang/PPrint.jl
[issues-img]: https://img.shields.io/github/issues/rbt-lang/PPrint.jl.svg
[issues-url]: https://github.com/rbt-lang/PPrint.jl/issues
[doc-dev-img]: https://img.shields.io/badge/doc-dev-blue.svg
[doc-dev-url]: https://rbt-lang.github.io/PPrint.jl/dev/
[license-img]: https://img.shields.io/badge/license-MIT-blue.svg
[license-url]: https://raw.githubusercontent.com/rbt-lang/PPrint.jl/master/LICENSE.md
[rfmt-paper]: https://ai.google/research/pubs/pub44667

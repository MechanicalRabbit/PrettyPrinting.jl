#!/usr/bin/env julia

using Pkg
haskey(Pkg.installed(), "NarrativeTest") || Pkg.clone("https://github.com/rbt-lang/NarrativeTest.jl")

using PrettyPrinting
using NarrativeTest

args = !isempty(ARGS) ? ARGS : [relpath(joinpath(dirname(abspath(PROGRAM_FILE)), "../doc/src"))]
exit(!runtests(args))

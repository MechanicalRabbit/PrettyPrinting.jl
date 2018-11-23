#!/usr/bin/env julia

using Pkg
haskey(Pkg.installed(), "Documenter") || Pkg.add("Documenter")

using Documenter
using PPrint

# Highlight indented code blocks as Julia code.
using Markdown
Markdown.Code(code) = Markdown.Code("julia", code)

makedocs(
    sitename = "PPrint.jl",
    pages = [
        "Home" => "index.md",
    ],
    modules = [PPrint])

deploydocs(
    repo = "github.com/rbt-lang/PPrint.jl.git",
)

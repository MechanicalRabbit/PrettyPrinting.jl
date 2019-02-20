#!/usr/bin/env julia

using Pkg
haskey(Pkg.installed(), "Documenter") || Pkg.add("Documenter")

using Documenter
using PrettyPrinting

# Highlight indented code blocks as Julia code.
using Markdown
Markdown.Code(code) = Markdown.Code("julia", code)

makedocs(
    sitename = "PrettyPrinting.jl",
    pages = [
        "Home" => "index.md",
    ],
    modules = [PrettyPrinting])

deploydocs(
    repo = "github.com/rbt-lang/PrettyPrinting.jl.git",
)

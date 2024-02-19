#!/usr/bin/env julia

using Documenter
using PrettyPrinting

# Highlight indented code blocks as Julia code.
using Documenter: Expanders, Selectors, MarkdownAST, iscode
abstract type DefaultLanguage <: Expanders.ExpanderPipeline end
Selectors.order(::Type{DefaultLanguage}) = 99.0
Selectors.matcher(::Type{DefaultLanguage}, node, page, doc) =
    iscode(node, "")
Selectors.runner(::Type{DefaultLanguage}, node, page, doc) =
    node.element = MarkdownAST.CodeBlock("julia", node.element.code)

makedocs(
    sitename = "PrettyPrinting.jl",
    format = Documenter.HTML(prettyurls=(get(ENV, "CI", nothing) == "true")),
    pages = [
        "Home" => "index.md",
        "guide.md",
        "api.md",
        "test.md",
    ],
    modules = [PrettyPrinting],
    doctest = false,
    repo = Remotes.GitHub("MechanicalRabbit", "PrettyPrinting.jl"),
)

deploydocs(
    repo = "github.com/MechanicalRabbit/PrettyPrinting.jl.git",
)

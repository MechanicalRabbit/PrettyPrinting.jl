using Pkg
haskey(Pkg.installed(), "Coverage") || Pkg.add("Coverage")

using Coverage
Codecov.submit(Codecov.process_folder())

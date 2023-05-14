#
# Optimal data formatter for a fixed width screen.
# (see <https://research.google.com/pubs/pub44667.html>)
#

module PrettyPrinting

export
    pprint,
    pprintln

import Base:
    IndexStyle,
    getindex,
    size,
    show,
    *, /, |

const DEFAULT_LINE_WIDTH = 79
const DEFAULT_BREAK_COST = 1
const DEFAULT_SPILL_COST = 2

include("tile.jl")
include("expr.jl")
include("fit.jl")

"""
    pprint([io::IO], data)

Display the data so that it fits the width of the output screen.
"""
pprint(@nospecialize data) =
    pprint(stdout, data)

pprint(io::IO, data) =
    pprint(io, tile(data))

function pprint(io::IO, lt::Layout)
    render(io, best_fit(io, lt))
    nothing
end

"""
    pprintln([io::IO], data)

Display the data using `pprint` and print a line break.
"""
pprintln(@nospecialize data) =
    pprintln(stdout, data)

function pprintln(io::IO, data)
    pprint(io, data)
    println(io)
end

"""
    quoteof(obj)

Convert an object to its representation in Julia AST.

Implement this method to customize [`pprint`](@ref) on a user-defined type.
"""
function quoteof
end

"""
    tile(obj)

Convert an object to the corresponding layout expression.

Implement this method to customize [`pprint`](@ref) on a user-defined type.
"""
function tile
end

include("precompile.jl")

end

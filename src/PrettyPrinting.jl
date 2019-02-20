#
# Optimal data formatter for a fixed width screen.
# (see <https://research.google.com/pubs/pub44667.html>)
#

module PrettyPrinting

export
    pprint

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
include("fit.jl")

"""
    pprint([io::IO], data)

Displays the data so that it fits the width of the output screen.
"""
pprint(data) =
    pprint(stdout, data)

pprint(io::IO, data) =
    pprint(io, tile(data))

function pprint(io::IO, lt::Layout)
    render(io, best_fit(io, lt))
    nothing
end

end

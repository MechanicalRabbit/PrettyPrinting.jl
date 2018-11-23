#
# Optimal data formatter for a fixed width screen.
# (see <https://research.google.com/pubs/pub44667.html>)
#

module PPrint

export
    PPrinter,
    pprint

import Base:
    IndexStyle,
    getindex,
    size,
    show,
    *, /, |

const PPrinter = Any

const DEFAULT_LINE_WIDTH = 79
const DEFAULT_BREAK_COST = 1
const DEFAULT_SPILL_COST = 2

include("tile.jl")
include("fit.jl")

"""
    PPrint.pprint([io::IO], data)

Displays the data so that it fits the width of the output screen.
"""
pprint(data) =
    pprint(stdout, data)

pprint(io::IO, data) =
    pprint(io, tile(data))

function pprint(io::IO, lt::Layout)
    render(io, best(fit(io, lt)))
    nothing
end

end

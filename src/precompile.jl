#
# Precompilation.
#

function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return

    for T in Any[Nothing, Missing, Symbol, Bool, String, Int, Float64, Vector{Any}, Tuple{}, @NamedTuple{}, QuoteNode, Expr]
        precompile(Tuple{typeof(tile), T})
        precompile(Tuple{typeof(pprint), T})
        precompile(Tuple{typeof(pprintln), T})
        precompile(Tuple{typeof(pprint), Base.TTY, T})
        precompile(Tuple{typeof(pprintln), Base.TTY, T})
    end

    for T in Any[LiteralBlock, HorizontalBlock, VerticalBlock, ChoiceBlock, PenaltyBlock]
        precompile(Tuple{typeof(nobreak), T, Vector{Layout}})
        precompile(Tuple{typeof(fit), Formatter, T, Vector{Layout}, Rope})
    end
end

_precompile_()

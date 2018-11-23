#
# Layout combinators, tiling, and rendering.
#

# Layout tree.

abstract type AbstractBlock end

struct Layout
    blk::AbstractBlock
    args::Vector{Layout}
end

struct LiteralBlock <: AbstractBlock
    atom::Any
    len::Int
end

struct HorizontalBlock <: AbstractBlock
end

struct VerticalBlock <: AbstractBlock
end

struct ChoiceBlock <: AbstractBlock
end

struct PenaltyBlock <: AbstractBlock
    cost::Int
    break_factor::Int
    spill_factor::Int

    PenaltyBlock(; cost::Int=0, break_factor::Int=1, spill_factor::Int=1) =
        new(cost, break_factor, spill_factor)
end

let NO_ARGS = Layout[],
    INDENTS = Layout[Layout(LiteralBlock(" " ^ i, i), NO_ARGS) for i = 1:DEFAULT_LINE_WIDTH]

    global literal, indent

    literal(str::String) =
        Layout(LiteralBlock(str, textwidth(str)), NO_ARGS)

    literal(sym::Symbol) =
        literal(string(sym))

    literal(atom, len::Int) =
        Layout(LiteralBlock(atom, len), NO_ARGS)

    indent(i::Int) =
        1 <= i <= length(INDENTS) ? INDENTS[i] : Layout(LiteralBlock(" " ^ i, i), NO_ARGS)
end

# Visualization.

show(io::IO, lt::Layout) =
    pprint(io, tile(lt))

# Layout combinators.

(*)(lt::Layout, lts::Layout...) =
    Layout(HorizontalBlock(), collect(Layout, (lt, lts...)))

(/)(lt::Layout, lts::Layout...) =
    Layout(VerticalBlock(), collect(Layout, (lt, lts...)))

(|)(lt::Layout, lts::Layout...) =
    Layout(ChoiceBlock(), collect(Layout, (lt, lts...)))

penalize(lt::Layout; cost::Int=0, break_factor::Int=1, spill_factor::Int=1) =
    Layout(PenaltyBlock(cost=cost, break_factor=break_factor, spill_factor=spill_factor), Layout[lt])

nobreak(lt::Layout) =
    let lt′ = nobreak(lt.blk, lt.args)
        lt′ isa Layout && lt′.blk == lt.blk && lt′.args == lt.args ? lt : lt′
    end

nobreak(blk::LiteralBlock, args::Vector{Layout}) =
    Layout(blk, args)

function nobreak(blk::HorizontalBlock, args::Vector{Layout})
    args′ = Layout[]
    for arg in args
        arg′ = nobreak(arg)
        arg′ !== nothing || return nothing
        push!(args′, arg′)
    end
    Layout(blk, args′)
end

nobreak(::VerticalBlock, ::Vector{Layout}) = nothing

function nobreak(blk::Union{ChoiceBlock,PenaltyBlock}, args::Vector{Layout})
    args′ = Layout[]
    for arg in args
        arg′ = nobreak(arg)
        arg′ !== nothing || continue
        push!(args′, arg′)
    end
    !isempty(args′) || return nothing
    Layout(blk, args′)
end

function list_layout(items::Vector{Layout};
                     prefix::Union{String,Symbol}="",
                     suffix::Union{String,Symbol}="",
                     par::Tuple{String,String}=("(", ")"),
                     sep::Tuple{String,String,String}=(", ", "", ","),
                     tab::Int=4,
                     nobrk::Int=10)
    !isempty(items) || return literal("$(prefix)$(par[1])$(par[2])$(suffix)")
    head_lt = literal("$(prefix)$(par[1])")
    tail_lt = literal("$(par[2])$(suffix)")
    sepc_lt, sepl_lt, sepr_lt = map(literal, sep)
    tab_lt = indent(tab)
    vlt = items[1]
    #hlt = penalize(items[1], break_factor=nobrk)
    hlt = items[1]
    for item in items[2:end]
        vlt = (vlt * sepr_lt) / (sepl_lt * item)
        hlt = hlt * sepc_lt * item
    end
    vlt = (head_lt | (head_lt / tab_lt)) * vlt * tail_lt
    #hlt = penalize(head_lt * hlt * tail_lt, break_factor=nobrk)
    #vlt | hlt
    hlt = nobreak(head_lt * hlt * tail_lt)
    (hlt !== nothing ? vlt | hlt : vlt)::Layout
end

function pair_layout(fst::Layout,
                     snd::Layout;
                     sep::Tuple{String,String,String}=(" => ", "", " =>"),
                     tab::Int=4)
    sepc_lt, sepl_lt, sepr_lt = map(literal, sep)
    tab_lt = indent(tab)
    (fst * sepc_lt * snd) | ((fst * sepr_lt) / (tab_lt * sepl_lt * snd))
end

# Fallback layout.

tile(obj) = literal(repr(obj))

# Layouts for standard types.

tile(p::Pair) =
    pair_layout(tile(p.first), tile(p.second))

tile(t::Tuple) =
    list_layout(Layout[tile(x) for x in t])

tile(v::Vector) =
    list_layout(Layout[tile(x) for x in v], par=("[", "]"))

tile(t::NamedTuple) =
    list_layout(Layout[pair_layout(literal(key), tile(val), sep=(" = ", "", " ="))
                       for (key, val) in pairs(t)])

tile(d::Dict) =
    list_layout(Layout[pair_layout(tile(key), tile(val)) for (key, val) in d],
                prefix=:Dict)

# Layout of the layout tree.

tile(lt::Layout) =
    tile_layout(lt)

tile_layout(lt::Layout, precedence::Int=0) =
    tile_layout(lt.blk, lt.args, precedence)

function tile_layout(blk::LiteralBlock, ::Vector{Layout}, ::Int)
    if blk.atom isa String && blk.len == textwidth(blk.atom)
        if blk.len > 0 && all(ch == ' ' for ch in blk.atom)
            literal("indent($(blk.len))")
        else
            literal("literal($(repr(blk.atom)))")
        end
    else
        literal("literal($(repr(blk.atom)), $(blk.len))")
    end
end

function tile_layout(blk::PenaltyBlock, args::Vector{Layout}, ::Int)
    items = Layout[tile_layout(arg) for arg in args]
    if blk.cost != 0
        push!(items, literal("cost=$(blk.cost)"))
    end
    if blk.break_factor != 1
        push!(items, literal("break_factor=$(blk.break_factor)"))
    end
    if blk.spill_factor != 1
        push!(items, literal("spill_factor=$(blk.spill_factor)"))
    end
    list_layout(items, prefix=:penalize)
end

function tile_layout(blk::Union{HorizontalBlock, VerticalBlock, ChoiceBlock}, args::Vector{Layout}, precedence::Int)
    precedence′ = blk isa ChoiceBlock ? 0 : 1
    items = Layout[]
    first = true
    for arg in args
        item = tile_layout(arg, first ? precedence′ : precedence′ + 1)
        push!(items, item)
        first = false
    end
    par = precedence > precedence′ ? ("(", ")") : ("", "")
    sep = blk isa HorizontalBlock ? (" * ", "* ", "") :
          blk isa VerticalBlock ? (" / ", "/ ", "") :
          blk isa ChoiceBlock ? (" | ", "| ", "") : ("", "", "")
    return list_layout(items, par=par, sep=sep)
end

# Rendering

render(io::IO, lt::Layout, col::Int=0) =
    render(io, lt.blk, lt.args, col)

function render(io::IO, blk::LiteralBlock, ::Vector{Layout}, col::Int)
    print(io, blk.atom)
    col + blk.len
end

function render(io::IO, ::HorizontalBlock, args::Vector{Layout}, col::Int)
    for arg in args
        col = render(io, arg, col)
    end
    col
end

function render(io::IO, ::VerticalBlock, args::Vector{Layout}, col::Int)
    nl = "\n" * " " ^ col
    col′ = col
    first = true
    for arg in args
        if !first
            print(io, nl)
        end
        col′ = render(io, arg, col)
        first = false
    end
    col′
end

render(io::IO, ::Union{ChoiceBlock, PenaltyBlock}, args::Vector{Layout}, col::Int) =
    !isempty(args) ? render(io, args[1], col) : col

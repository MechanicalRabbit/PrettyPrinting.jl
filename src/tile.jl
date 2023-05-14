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

literal(str::Union{AbstractString,Symbol}) =
    literal(string(str))

literal(atom, len::Int) =
    Layout(LiteralBlock(atom, len), NO_ARGS)

indent(i::Int) =
    1 <= i <= length(INDENTS) ? INDENTS[i] : Layout(LiteralBlock(" " ^ i, i), NO_ARGS)

end

const ZERO = literal("")

# Visualization.

show(io::IO, lt::Layout) =
    pprint(io, tile(lt))

# Layout combinators.

function (*)(lts::Vector{Layout})
    lts = filter(!isequal(ZERO), lts)
    if isempty(lts)
        ZERO
    elseif length(lts) == 1
        lts[1]
    else
        Layout(HorizontalBlock(), lts)
    end
end

(/)(lts::Vector{Layout}) =
    Layout(VerticalBlock(), lts)

(|)(lts::Vector{Layout}) =
    Layout(ChoiceBlock(), lts)

(*)(lt1::Layout, lts::Layout...) =
    (*)(Layout[lt1, lts...])

(/)(lt1::Layout, lts::Layout...) =
    (/)(Layout[lt1, lts...])

(|)(lt1::Layout, lts::Layout...) =
    (|)(Layout[lt1, lts...])

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
                     prefix::Union{String,Symbol,Layout}="",
                     par::Tuple{String,String}=("(", ")"),
                     sep::String=", ",
                     sep_brk=:end,  # :start, :end, :both, or :none
                     tab::Int=4,
                     nobrk::Int=10)
    prefix_lt = prefix isa Layout ? prefix : literal(prefix)
    head_lt = prefix_lt * literal(par[1])
    tail_lt = literal(par[2])
    !isempty(items) || return head_lt * tail_lt
    sepc_lt = literal(sep)
    sepl_lt = literal(sep_brk == :start || sep_brk == :both ? lstrip(sep) : "")
    sepr_lt = literal(sep_brk == :end || sep_brk == :both ? rstrip(sep) : "")
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
                     sep::String=" => ",
                     sep_brk=:end,  # :start, :end, :both, or :none
                     tab::Int=4)
    nbfst = nobreak(fst)
    sepc_lt = literal(sep)
    sepl_lt = literal(sep_brk == :start || sep_brk == :both ? lstrip(sep) : "")
    sepr_lt = literal(sep_brk == :end || sep_brk == :both ? rstrip(sep) : "")
    tab_lt = indent(tab)
    nbfst !== nothing ?
        ((nobreak(fst) * sepc_lt) | ((fst * sepr_lt) / (tab_lt * sepl_lt))) * snd :
        ((fst * sepr_lt) / (tab_lt * sepl_lt)) * snd
end

# Fallback layout.

tile_repr(obj) =
    literal(repr(obj))

tile(obj) = tile_expr_or_repr(quoteof(obj))

# Layouts for standard types.

function tile(s::String)
    lt = literal(repr(s))
    if '"' in s
        if endswith(s, '"')
            es = escape_string(s[1:end - 1], "") * "\\\""
        else
            es = escape_string(s, "")
        end
        lt = lt | literal("\"\"\"" * replace(es, "\"\"\"" => "\"\"\\\"") * "\"\"\"")
    end
    if '\n' in s
        lines = split(s, '\n')
        n = length(lines)
        for k = 1:n
            line = lines[k]
            if k == n && endswith(line, '"')
                line = escape_string(line[1:end - 1], "") * "\\\""
            else
                line = escape_string(line, "")
            end
            if '"' in line
                line = replace(line, "\"\"\"" => "\"\"\\\"")
            end
            lines[k] = line
        end
        lines[end] *= "\"\"\""
        indented = true
        for line in lines
            if !isempty(line) && !(first(line) in (' ', '\t'))
                indented = false
                break
            end
        end
        if indented
            line = lines[end]
            lines[end] = "\\x" * string(UInt32(first(line)), base = 16, pad = 2) * line[2:end]
        end
        mlt = literal("\"\"\"")
        for line in lines
            mlt = mlt / literal(line)
        end
        lt = lt | mlt
    end
    lt
end

tile(p::Pair) =
    pair_layout(tile(p.first), tile(p.second))

tile(@nospecialize t::Tuple) =
    if length(t) == 1
        literal("(") * tile(t[1]) * literal(",)")
    else
        list_layout(Layout[tile(x) for x in t])
    end

tile(v::Vector) =
    list_layout(Layout[tile(x) for x in v], par=("[", "]"))

tile(s::Set) =
    if isempty(s)
        literal("Set()")
    else
        list_layout(Layout[list_layout([tile(x) for x in s], par=("[", "]"))],
                    prefix=:Set)
    end

tile(@nospecialize t::NamedTuple) =
    if length(t) == 1
        ((key, val),) = pairs(t)
        literal("(") * pair_layout(literal(key), tile(val), sep=" = ") * literal(",)")
    else
        list_layout(Layout[pair_layout(literal(key), tile(val), sep=" = ")
                           for (key, val) in pairs(t)])
    end

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
    sep = blk isa HorizontalBlock ? " * " :
          blk isa VerticalBlock ? " / " :
          blk isa ChoiceBlock ? " | " : ""
    return list_layout(items, par=par, sep=sep)
end

# Rendering

function render(io::IO, lt::Layout, col::Int=0, nl::Vector{UInt8}=UInt8[0x0A, 0x20, 0x20, 0x20, 0x20])
    blk = lt.blk
    args = lt.args
    if blk isa LiteralBlock
        col = render(io, blk, args, col, nl)
    elseif blk isa HorizontalBlock
        col = render(io, blk, args, col, nl)
    elseif blk isa VerticalBlock
        col = render(io, blk, args, col, nl)
    else
        col = render(io, blk, args, col, nl)::Int
    end
    col
end

function render(io::IO, blk::LiteralBlock, ::Vector{Layout}, col::Int, ::Vector{UInt8})
    atom = blk.atom
    if atom isa String
        print(io, atom)
    else
        print(io, atom)
    end
    col + blk.len
end

function render(io::IO, ::HorizontalBlock, args::Vector{Layout}, col::Int, nl::Vector{UInt8})
    for arg in args
        col = render(io, arg, col, nl)
    end
    col
end

function render(io::IO, ::VerticalBlock, args::Vector{Layout}, col::Int, nl::Vector{UInt8})
    l = length(nl)
    if col + 1 > l
        resize!(nl, col + 1)
        for k = l:col
            @inbounds nl[k + 1] = 0x20
        end
    end
    col′ = col
    first = true
    for arg in args
        if !first
            GC.@preserve nl unsafe_write(io, pointer(nl), col + 1)
        end
        col′ = render(io, arg, col, nl)
        first = false
    end
    col′
end

render(io::IO, ::Union{ChoiceBlock, PenaltyBlock}, args::Vector{Layout}, col::Int, nl::Vector{UInt8}) =
    !isempty(args) ? render(io, args[1], col, nl) : col

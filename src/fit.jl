#
# Optimal layout generator.
#

# Layout constraints.

struct Spec
    line_width::Int
    break_cost::Int
    spill_cost::Int
end

# Maps a starting column to the optimal layout and its cost.

mutable struct Rope <: AbstractVector{Tuple{Int,Int,Int,Int,Layout}}
    len::Int
    cols::Vector{Int}
    spans::Vector{Int}
    icepts::Vector{Int}
    slopes::Vector{Int}
    lts::Vector{Layout}

    cache::Dict{Spec, Dict{Layout, Rope}}

    Rope() = new(0, Int[], Int[], Int[], Int[], Layout[], Dict())
    Rope(::Nothing) = new(1, [0], [0], [0], [0], [literal("")], Dict())
end

size(rope::Rope) = (rope.len,)

IndexStyle(::Type{Rope}) = IndexLinear()

@inline function getindex(rope::Rope, k::Int)
    @boundscheck checkbounds(rope, k)
    @inbounds t = (rope.cols[k], rope.spans[k], rope.icepts[k], rope.slopes[k], rope.lts[k])
    t
end

best(rope::Rope) = rope.lts[1]

function extend!(rope::Rope, col::Int, span::Int, icept::Int, slope::Int, lt::Layout)
    @assert rope.len == 0 && col == 0 || rope.len > 0 && col > rope.cols[end]
    if rope.len > 0
        col′, span′, icept′, slope′, lt′ = rope[end]
        lt.blk == lt′.blk && lt.args == lt′.args &&
        span == span′ &&
        icept == icept′ + (col - col′) * slope′ &&
        slope == slope′ && return
    end
    rope.len += 1
    push!(rope.cols, col)
    push!(rope.spans, span)
    push!(rope.icepts, icept)
    push!(rope.slopes, slope)
    push!(rope.lts, lt)
    nothing
end

# Generator state.

mutable struct Formatter
    spec::Spec
    empty::Rope

    Formatter(spec::Spec, empty::Rope) = new(spec, empty)

    Formatter(line_width::Int = DEFAULT_LINE_WIDTH,
              break_cost::Int = DEFAULT_BREAK_COST,
              spill_cost::Int = DEFAULT_SPILL_COST) =
        new(Spec(line_width, break_cost, spill_cost), Rope(nothing))

    Formatter(io::IO,
              break_cost::Int = DEFAULT_BREAK_COST,
              spill_cost::Int = DEFAULT_SPILL_COST) =
        let (h, w) = displaysize(io)
            Formatter(w-1, break_cost, spill_cost)
        end
end

best_fit(args...) = best(fit(args...))

fit(lt::Layout) = fit(Formatter(), lt)

fit(io::IO, lt::Layout) = fit(Formatter(io), lt)

fit(fmt::Formatter, lt::Layout) =
    fit(fmt, lt, fmt.empty)

function fit(fmt::Formatter, lt::Layout, tail::Rope)
    spec_cache = get!(tail.cache, fmt.spec) do
        Dict{Layout, Rope}()
    end
    get!(spec_cache, lt) do
        fit(fmt, lt.blk, lt.args, tail)
    end
end

function fit(fmt::Formatter, blk::LiteralBlock, args::Vector{Layout}, tail::Rope)
    line_width = fmt.spec.line_width
    spill_cost = fmt.spec.spill_cost
    w = blk.len
    lt = Layout(blk, args)
    rope = Rope()
    if w < line_width
        extend!(rope, 0, w, 0, 0, lt)
        extend!(rope, line_width - w, w, 0, spill_cost, lt)
    else
        extend!(rope, 0, w, (w - line_width) * spill_cost, spill_cost, lt)
    end
    return horizontal(fmt, rope, tail)
end

function fit(fmt::Formatter, ::HorizontalBlock, args::Vector{Layout}, tail::Rope)
    rope = tail
    k = length(args)
    while k > 0
        rope = fit(fmt, args[k], rope)
        k -= 1
    end
    return rope
end

function fit(fmt::Formatter, ::VerticalBlock, args::Vector{Layout}, tail::Rope)
    rope = tail
    k = length(args)
    while k > 0
        if k == length(args)
            rope = fit(fmt, args[k], rope)
        else
            rope = vertical(fmt, fit(fmt, args[k]), rope)
        end
        k -= 1
    end
    return rope
end

function fit(fmt::Formatter, ::ChoiceBlock, args::Vector{Layout}, tail::Rope)
    if isempty(args)
        return tail
    end
    rope = fit(fmt, args[1], tail)
    k = 2
    while k <= length(args)
        rope = choice(fmt, rope, fit(fmt, args[k], tail))
        k += 1
    end
    return rope
end

function fit(fmt::Formatter, blk::PenaltyBlock, args::Vector{Layout}, tail::Rope)
    spec = fmt.spec
    spec′ = Spec(spec.line_width, spec.break_cost * blk.break_factor, spec.spill_cost * blk.spill_factor)
    fmt.spec = spec′
    try
        rope′ = fit(fmt, ChoiceBlock(), args, tail)
        if blk.cost == 0
            return rope′
        end
        rope = Rope()
        for (col, span, icept, slope, lt) in rope′
            extend!(rope, col, span, icept + blk.cost, slope, lt)
        end
        return rope
    finally
        fmt.spec = spec
    end
end

function horizontal(fmt::Formatter, rope1::Rope, rope2::Rope)
    if rope2 === fmt.empty
        return rope1
    end
    line_width = fmt.spec.line_width
    spill_cost = fmt.spec.spill_cost
    rope = Rope()
    col = 0
    i1 = 1
    i2 = searchsorted(rope2.cols, rope1.spans[i1]).stop
    while i1 <= length(rope1) && i2 <= length(rope2)
        col1, span1, icept1, slope1, lt1 = rope1[i1]
        col2, span2, icept2, slope2, lt2 = rope2[i2]
        span = span1 + span2
        icept = icept1 + (col - col1) * slope1 +
                icept2 + (col + span1 - col2) * slope2 +
                (col + span1 >= line_width ?
                    -(col + span1 - line_width) * spill_cost : 0)
        slope = slope1 + slope2 +
            (col + span1 >= line_width ? -spill_cost : 0)
        lt = lt1 * lt2
        extend!(rope, col, span, icept, slope, lt)
        if i1 < length(rope1) && i2 < length(rope2)
            col1 = rope1.cols[i1+1]
            col2 = rope2.cols[i2+1] - rope1.spans[i1]
            if col1 <= col2
                col = col1
                i1 += 1
                i2 = searchsorted(rope2.cols, col + rope1.spans[i1]).stop
            else
                col = col2
                i2 += 1
            end
        elseif i1 < length(rope1)
            col = rope1.cols[i1+1]
            i1 += 1
            i2 = searchsorted(rope2.cols, col + rope1.spans[i1]).stop
        elseif i2 < length(rope2)
            col = rope2.cols[i2+1] - rope1.spans[i1]
            i2 += 1
        else
            i1 += 1
        end
    end
    return rope
end

function vertical(fmt::Formatter, rope1::Rope, rope2::Rope)
    break_cost = fmt.spec.break_cost
    rope = Rope()
    col = 0
    i1 = 1
    i2 = 1
    while i1 <= length(rope1) && i2 <= length(rope2)
        col1, span1, icept1, slope1, lt1 = rope1[i1]
        col2, span2, icept2, slope2, lt2 = rope2[i2]
        span = span2
        icept = icept1 + (col - col1) * slope1 +
                icept2 + (col - col2) * slope2 +
                break_cost
        slope = slope1 + slope2
        lt = lt1 / lt2
        extend!(rope, col, span, icept, slope, lt)
        if i1 < length(rope1) && i2 < length(rope2)
            col1 = rope1.cols[i1+1]
            col2 = rope2.cols[i2+1]
            if col1 <= col2
                col = col1
                i1 += 1
            end
            if col1 >= col2
                col = col2
                i2 += 1
            end
        elseif i1 < length(rope1)
            col = rope1.cols[i1+1]
            i1 += 1
        elseif i2 < length(rope2)
            col = rope2.cols[i2+1]
            i2 += 1
        else
            i1 += 1
        end
    end
    return rope
end

function choice(fmt::Formatter, rope1::Rope, rope2::Rope)
    rope = Rope()
    col = 0
    i1 = 1
    i2 = 1
    while i1 <= length(rope1) && i2 <= length(rope2)
        col1, span1, icept1, slope1, lt1 = rope1[i1]
        col2, span2, icept2, slope2, lt2 = rope2[i2]
        cost1 = icept1 + (col - col1) * slope1
        cost2 = icept2 + (col - col2) * slope2
        if cost1 < cost2 || cost1 == cost2 && slope1 <= slope2
            span = span1
            icept = cost1
            slope = slope1
            lt = lt1
        else
            span = span2
            icept = cost2
            slope = slope2
            lt = lt2
        end
        extend!(rope, col, span, icept, slope, lt)
        xcol = col
        if slope1 != slope2
            xcol = ceil(Int, 1.0 * (col1 * slope1 - icept1 - col2 * slope2 + icept2) / (slope1 - slope2))
        end
        if i1 < length(rope1) && i2 < length(rope2)
            col1 = rope1.cols[i1+1]
            col2 = rope2.cols[i2+1]
            if xcol > col && xcol < col1 && xcol < col2
                col = xcol
            else
                if col1 <= col2
                    col = col1
                    i1 += 1
                end
                if col1 >= col2
                    col = col2
                    i2 += 1
                end
            end
        elseif i1 < length(rope1)
            if xcol > col && xcol < rope1.cols[i1+1]
                col = xcol
            else
                col = rope1.cols[i1+1]
                i1 += 1
            end
        elseif i2 < length(rope2)
            if xcol > col && xcol < rope2.cols[i2+1]
                col = xcol
            else
                col = rope2.cols[i2+1]
                i2 += 1
            end
        else
            if xcol > col
                col = xcol
            else
                i1 += 1
            end
        end
    end
    return rope
end

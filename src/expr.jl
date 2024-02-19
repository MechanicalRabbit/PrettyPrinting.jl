#
# Layout for Expr nodes.
#

# Pattern matching for Expr objects.

# Supported syntax:
#   @isexpr ex _                => true
#   @isexpr ex var              => (local var = ex; true)
#   @isexpr ex :sym             => ex === :sym
#   @isexpr ex var := ...       => (local var = ex; ...)
#   @isexpr ex ::T              => ex isa T
#   @isexpr ex (... && ...)     => (... && ...)
#   @isexpr ex (... || ...)     => (... || ...)
#   @isexpr ex QuoteNode(...)   => (ex isa QuoteNode && (ex.value ...))
#   @isexpr ex Expr(...)        => (ex isa Expr && (ex.head ...) && (ex.args ...))

macro isexpr(val, pat)
    esc(_isexpr(val, pat))
end

function _isexpr(@nospecialize(val), @nospecialize(pat))
    pat !== :_ || return :(true)
    scr = gensym(:scr)
    ex = _isexpr(scr, pat)
    :(local $scr = $val; $ex)
end

function _isexpr(scr::Symbol, @nospecialize(pat))
    if pat isa Symbol
        if pat === :_
            :(true)
        else
            :(local $pat = $scr; true)
        end
    elseif pat isa QuoteNode && pat.value isa Symbol
        :($scr === $pat)
    elseif pat isa Expr
        nargs = length(pat.args)
        if pat.head === :(:=) && nargs == 2
            ex1 = _isexpr(scr, pat.args[1])
            ex2 = _isexpr(scr, pat.args[2])
            :($ex2 && $ex1)
        elseif pat.head === :(::) && nargs == 1
            T = pat.args[1]
            :($scr isa $T)
        elseif pat.head === :(::) && nargs == 2
            T = pat.args[2]
            ex = _isexpr(scr, pat.args[1])
            :($scr isa $T && $ex)
        elseif pat.head === :&& || pat.head === :||
            Expr(pat.head, Any[_isexpr(scr, argpat) for argpat in pat.args]...)
        elseif pat.head === :call && nargs >= 1
            call = pat.args[1]
            if call === :QuoteNode && nargs == 2
                ex = _isexpr(:($scr.value), pat.args[2])
                :($scr isa QuoteNode && $ex)
            elseif call === :Expr && nargs >= 2
                exs = Any[:($scr isa Expr)]
                push!(exs, _isexpr(:($scr.head), pat.args[2]))
                minlen = 0
                varlen = false
                for k = 3:lastindex(pat.args)
                    argpat = pat.args[k]
                    if argpat isa Expr && argpat.head === :... && length(argpat.args) == 1
                        !varlen || error("duplicate vararg patttern: $pat")
                        varlen = true
                    else
                        minlen += 1
                    end
                end
                if !varlen
                    push!(exs, :(length($scr.args) == $minlen))
                else
                    push!(exs, :(length($scr.args) >= $minlen))
                end
                j = 1
                seen_vararg = false
                for k = 3:lastindex(pat.args)
                    argpat = pat.args[k]
                    if argpat isa Expr && argpat.head === :... && length(argpat.args) == 1
                        argpat = argpat.args[1]
                        ex = _isexpr(:($scr.args[$j : $lastindex($scr.args) - $(minlen-j+1)]), argpat)
                        seen_vararg = true
                    elseif seen_vararg
                        ex = _isexpr(:($scr.args[$lastindex($scr.args) - $(minlen-j+1)]), argpat)
                    else
                        ex = _isexpr(:($scr.args[$j]), argpat)
                    end
                    push!(exs, ex)
                    j += 1
                end
                Expr(:&&, exs...)
            else
                error("invalid Expr pattern: $pat")
            end
        end
    else
        error("invalid Expr pattern: $pat")
    end
end

# Represent an object as an Expr node.

quoteof(obj) =
    obj

quoteof(ex::Union{Symbol,Expr,QuoteNode}) =
    QuoteNode(ex)

# Tiling Expr nodes.

tile_expr_or_repr(ex::Union{Symbol,Expr,QuoteNode}, pr = -1) =
    tile_expr(ex, pr)

tile_expr_or_repr(obj, pr = -1) =
    tile_repr(obj)

tile_expr(obj, pr = -1) =
    tile(obj)

tile_expr(qn::QuoteNode, pr = -1) =
    tile_expr_quoted(qn.value, pr)

identifier(s::Symbol) =
    Base.isidentifier(s) || Base.isoperator(s) || string(s)[1] == '@' ?
        string(s) :
        "var" * repr(string(s))

identifier(data) =
    repr(data)

tile_expr(s::Symbol, pr = -1) =
    literal(identifier(s))

function strip_line_number_nodes(ex::Expr)
    if any(arg -> arg isa LineNumberNode, ex.args)
        ex = Expr(ex.head, Any[arg for arg in ex.args if !(arg isa LineNumberNode)]...)
    end
    ex
end

function tile_expr(ex::Expr, pr = -1)
    ex = strip_line_number_nodes(ex)
    if @isexpr ex Expr(:block, args...)
        return tile_expr_block(args, pr)
    elseif @isexpr ex Expr(:module, notbare::Bool, name::Symbol, body)
        return tile_expr_module(notbare ? :module : :baremodule, name, body)
    elseif @isexpr ex Expr(:export, names...)
        return tile_expr_export(names)
    elseif @isexpr ex Expr(head := :using || :import, Expr(:(:), from, args...))
        return tile_expr_import(head, from, args)
    elseif @isexpr ex Expr(head := :using || :import, arg)
        return tile_expr_import(head, arg)
    elseif @isexpr ex Expr(:struct, mut::Bool, decl, body)
        return tile_expr_struct(mut ? Symbol("mutable struct") : :struct, decl, body)
    elseif @isexpr ex Expr(:abstract, decl)
        return tile_expr_abstract(decl)
    elseif @isexpr ex Expr(head := :if || :while || :for, cond, body)
        return tile_expr_stmt(head, cond, body, pr)
    elseif @isexpr ex Expr(head := :if, cond, body, else_body)
        return tile_expr_stmt(head, cond, body, else_body, pr)
    elseif @isexpr ex Expr(:let, decl, body)
        return tile_expr_let(decl, body)
    elseif @isexpr ex Expr(:try, body, ::Bool, ::Bool, finally_body)
        return tile_expr_try(body, nothing, nothing, finally_body)
    elseif @isexpr ex Expr(:try, body, ::Bool, catch_body, finally_body)
        return tile_expr_try(body, nothing, catch_body, finally_body)
    elseif @isexpr ex Expr(:try, body, name, catch_body, finally_body)
        return tile_expr_try(body, name, catch_body, finally_body)
    elseif @isexpr ex Expr(:try, body, ::Bool, catch_body)
        return tile_expr_try(body, nothing, catch_body, nothing)
    elseif @isexpr ex Expr(:try, body, name, catch_body)
        return tile_expr_try(body, name, catch_body, nothing)
    elseif @isexpr ex Expr(head := :function || :macro, decl, body)
        return tile_expr_function(head, decl, body)
    elseif (@isexpr ex Expr(:macrocall, ref::GlobalRef, docstr::String, def)) && ref === GlobalRef(Core, Symbol("@doc"))
        return tile_expr(docstr, pr) / tile_expr(def, pr)
    elseif @isexpr ex Expr(head := :break || :continue || :return)
        return literal(head)
    elseif @isexpr ex Expr(head := :return || :const, arg)
        return literal(head) * indent(1) * tile_expr(arg, 0)
    elseif @isexpr ex Expr(head := :local || :global, args...)
        return list_layout(Layout[tile_expr(arg, 0) for arg in args], prefix = head, par = (" ", ""))
    elseif @isexpr ex Expr(:do, call, Expr(:->, Expr(:tuple, args...), body))
        return tile_expr_do(call, args, body)
    elseif @isexpr ex Expr(:(=) || :kw, larg, rarg)
        return tile_expr_assign(:(=), larg, rarg, pr)
    elseif @isexpr ex Expr(head := :(:=) || :-> || :(<:) || :(::) || :(+=) || :(-=), larg, rarg)
        return tile_expr_assign(head, larg, rarg, pr)
    elseif @isexpr ex Expr(:call, fn := :(=>), larg, rarg)
        return tile_expr_assign(fn, larg, rarg, pr)
    elseif @isexpr ex Expr(:call, fn, args...)
        return tile_expr_call(fn, args, pr)
    elseif @isexpr ex Expr(fn := :|| || :&&, args...)
        return tile_expr_call(fn, args, pr)
    elseif @isexpr ex Expr(fn := :(::), arg)
        return tile_expr_call(fn, Any[arg], pr)
    elseif @isexpr ex Expr(fn := :(.), arg1, QuoteNode(arg2))
        return tile_expr_call(fn, [arg1, arg2], pr)
    elseif (@isexpr ex Expr(:(.), op::Symbol, Expr(:tuple, arg1, arg2))) && Meta.isoperator(op)
        return tile_expr_call(Symbol("." * string(op)), [arg1, arg2], pr)
    elseif @isexpr ex Expr(fn := :(.), arg1, arg2)
        return tile_expr_call(fn, [arg1, arg2], pr)
    elseif (@isexpr ex Expr(:comparison, args...)) && length(args) >= 3 && isodd(length(args))
        return tile_expr_comparison(args, pr)
    elseif @isexpr ex Expr(:..., arg)
        return pr > 0 ? literal("(") * tile_expr(arg, 0) * literal("...)") : tile_expr(arg, 0) * literal("...")
    elseif @isexpr ex Expr(:tuple, arg)
        return literal("(") * tile_expr(arg, 0) * literal(",)")
    elseif @isexpr ex Expr(:macrocall, name, args...)
        return tile_expr_macro(name, args, pr)
    elseif @isexpr ex Expr(:tuple, args...)
        return list_layout(Layout[tile_expr(arg, 0) for arg in args])
    elseif @isexpr ex Expr(:generator, call, loop)
        return list_layout(Layout[tile_expr(call, 0), tile_expr(loop, 0)],
                           sep = " for ", sep_brk = :start, par = ("", ""))
    elseif @isexpr ex Expr(:filter, pred, loop)
        return list_layout(Layout[tile_expr(loop, 0), tile_expr(pred, 0)],
                           sep = " if ", sep_brk = :start, par = ("", ""))
    elseif @isexpr ex Expr(:vect || :comprehension, args...)
        return list_layout(Layout[tile_expr(arg, 0) for arg in args], par = ("[", "]"))
    elseif @isexpr ex Expr(:ref || :typed_comprehension, t, args...)
        return tile_expr_ref(t, args)
    elseif @isexpr ex Expr(:curly, t, args...)
        return tile_expr_ref(t, args, par = ("{", "}"))
    elseif @isexpr ex Expr(:string, args...)
        return tile_expr_string(args)
    elseif @isexpr ex Expr(:quote, arg)
        return tile_expr_quoted(arg, pr)
    elseif @isexpr ex Expr(:$, arg)
        return literal("\$(") * tile_expr(arg) * literal(")")
    end
    tile_expr_fallback(ex)
end

tile_exprs(data) =
    tile_expr(data)

function tile_exprs(ex::Expr, parskip::Union{Bool,Nothing}=nothing)
    ex = strip_line_number_nodes(ex)
    if parskip === nothing
        parskip = @isexpr ex Expr(:toplevel, _...)
    end
    if @isexpr ex Expr(:toplevel || :block, args...)
        lts = Layout[]
        for arg in args
            if parskip && !isempty(lts)
                push!(lts, ZERO)
            end
            push!(lts, tile_expr(arg))
        end
        !isempty(lts) ? /(lts) : ZERO
    else
        tile_expr(ex)
    end
end

tile_expr_quoted(s::Symbol, pr) =
    literal(repr(s))

function tile_expr_quoted(ex, pr)
    if pr < 0
        lt = literal("quote")
        ex_lt = tile_exprs(ex)
        if ex_lt !== ZERO
            lt = lt / (indent(4) * ex_lt)
        end
        lt = lt / literal("end")
    else
        lt = literal(":(") * tile_expr(ex, 0) * literal(")")
    end
    lt
end

function tile_expr_block(args, pr)
    if pr < 0
        lt = literal("begin")
        if !isempty(args)
            lts = Layout[tile_expr(arg) for arg in args]
            lt = lt / (indent(4) * (/(lts)))
        end
        lt = lt / literal("end")
    else
        if isempty(args)
            lt = literal("(;;)")
        elseif length(args) == 1
            lt = tile_expr(args[1], pr)
        else
            lts = Layout[tile_expr(arg, 0) for arg in args]
            lt = list_layout(lts, sep = "; ")
        end
    end
    lt
end

function tile_expr_module(head, name, body)
    lt = literal(head) * indent(1) * literal(name)
    body_lt = tile_exprs(body, true)
    if body_lt !== ZERO
        lt = lt / ZERO / body_lt
    end
    lt = lt / ZERO / literal("end")
    lt
end

tile_expr_export(args) =
    list_layout(prefix = "export ", par = ("", ""),
                Layout[tile_expr(arg, 0) for arg in args])

tile_expr_import_path(ex) =
    (@isexpr ex Expr(:., args...)) ?
        list_layout([tile_expr(arg) for arg in args], sep=".", par=("", "")) :
        tile_expr(ex)

tile_expr_import(head, arg) =
    literal(head) * indent(1) * tile_expr_import_path(arg)

function tile_expr_import(head, from, args)
    prefix = literal(head) * indent(1) * tile_expr_import_path(from)
    list_layout(prefix=prefix, par=(": ", ""),
                Layout[tile_expr_import_path(arg) for arg in args])
end

function tile_expr_struct(head, decl, body)
    lt = literal(head) * indent(1) * tile_expr(decl, 0)
    body_lt = tile_exprs(body)
    if body_lt !== ZERO
        lt = lt / (indent(4) * body_lt)
    end
    lt = lt / literal("end")
    lt
end

tile_expr_abstract(decl) =
    literal("abstract type ") * tile_expr(decl, 0) / literal("end")

function tile_expr_stmt(head, cond, body, pr)
    lt = literal(head) * indent(1) * tile_expr(cond, 0)
    body_lt = tile_exprs(body)
    if body_lt !== ZERO
        lt = lt / (indent(4) * body_lt)
    end
    lt = lt / literal("end")
end

const if_precedence = Base.operator_precedence(:?)

function tile_expr_stmt(head, cond, body, else_body, pr)
    if pr >= 0 && head === :if && !(@isexpr body Expr(:block, _...)) && !(@isexpr else_body Expr(:block || :elseif, _...))
        cond_lt = tile_expr(cond, if_precedence)
        body_lt = tile_expr(body, if_precedence)
        else_body_lt = tile_expr(else_body, if_precedence)
        vlt = (cond_lt * literal(" ?")) /
              (indent(4) * body_lt * literal(" :")) /
              (indent(4) * else_body_lt)
        hlt = nobreak(cond_lt * literal(" ? ") * body_lt * literal(" : ") * else_body_lt)
        lt = hlt !== nothing ? (vlt | hlt) : vlt
        if pr >= if_precedence
            lt = literal("(") * lt * literal(")")
        end
        return lt
    end
    lt = literal(head) * indent(1) * tile_expr(cond, 0)
    body_lt = tile_exprs(body)
    if body_lt !== ZERO
        lt = lt / (indent(4) * body_lt)
    end
    if @isexpr else_body Expr(:elseif, cond′, body′)
        lt = lt / tile_expr_stmt(:elseif, cond′, body′, -1)
    elseif @isexpr else_body Expr(:elseif, cond′, body′, else_body′)
        lt = lt / tile_expr_stmt(:elseif, cond′, body′, else_body′, -1)
    else
        lt = lt / literal("else")
        else_body_lt = tile_exprs(else_body)
        if else_body_lt !== ZERO
            lt = lt / (indent(4) * else_body_lt)
        end
        lt = lt / literal("end")
    end
    lt
end

function tile_expr_let(decl, body)
    lt = literal(:let)
    if @isexpr decl Expr(:block, arg1, rest...)
        decl_lt = tile_expr(arg1, 0)
        for arg in rest
            decl_lt = decl_lt * literal(",") / tile_expr(arg, 0)
        end
    else
        decl_lt = tile_expr(decl)
    end
    if decl_lt !== ZERO
        lt = lt * indent(1) * decl_lt
    end
    body_lt = tile_exprs(body)
    if body_lt !== ZERO
        lt = lt / (indent(4) * body_lt)
    end
    lt = lt / literal("end")
    lt
end

function tile_expr_try(body, name, catch_body, finally_body)
    lt = literal("try")
    body_lt = tile_exprs(body)
    if body_lt !== ZERO
        lt = lt / (indent(4) * body_lt)
    end
    if catch_body !== nothing
        catch_lt = literal("catch")
        if name !== nothing
            catch_lt = catch_lt * indent(1) * tile_expr(name, 0)
        end
        lt = lt / catch_lt
        catch_body_lt = tile_exprs(catch_body)
        if catch_body_lt !== ZERO
            lt = lt / (indent(4) * catch_body_lt)
        end
    end
    if finally_body !== nothing
        lt = lt / literal("finally")
        finally_body_lt = tile_exprs(finally_body)
        if finally_body_lt !== ZERO
            lt = lt / (indent(4) * finally_body_lt)
        end
    end
    lt = lt / literal("end")
    lt
end

function tile_expr_function(head, decl, body)
    lt = literal(head) * indent(1) * tile_expr(decl)
    body_lt = tile_exprs(body)
    if body_lt !== ZERO
        lt = lt / (indent(4) * body_lt)
    end
    lt = lt / literal("end")
    lt
end

function tile_expr_do(call, args, body)
    call_lt = tile_expr(call, 0)
    body_lt = tile_exprs(body)
    if isempty(args)
        args_lt = literal(" do")
    else
        args_lt = literal(" do ") *
                  list_layout(Layout[tile_expr(arg, 0) for arg in args],
                              par = ("", ""))
    end
    if body_lt === ZERO
        call_lt * args_lt /
        literal("end")
    else
        call_lt * args_lt /
        (indent(4) * body_lt) /
        literal("end")
    end
end

function tile_expr_assign(op, larg, rarg, pr)
    pr′ = Base.operator_precedence(op)
    sep = op !== :(::) ? " $op " : string(op)
    lt = pair_layout(tile_expr(larg, pr′), tile_expr(rarg, pr′), sep = sep)
    if pr >= pr′
        lt = literal("(") * lt * literal(")")
    end
    lt
end

function tile_expr_call(fn, args, pr)
    nargs = length(args)
    if fn isa Symbol
        pr′ = Base.operator_precedence(fn)
        prefix = ""
        par = ("(", ")")
        if pr′ > pr && pr′ > 0
            par = ("", "")
        end
        sep = ", "
        if fn === :(:) && 2 <= nargs <= 3
            sep = ":"
        elseif (Base.isunaryoperator(fn) || fn === :(::)) && nargs == 1
            prefix = string(fn)
        elseif (Base.isbinaryoperator(fn) || fn === :in || fn === :isa) && nargs == 2
            if fn === :. || fn === :(::)
                sep = string(fn)
            else
                sep = " $fn "
            end
            assoc = Base.operator_associativity(fn)
            if assoc === :right
                while ((@isexpr args[end] Expr(:call, fn′::Symbol, arg1, arg2)) && fn′ === fn) ||
                      ((@isexpr args[end] Expr(fn′ := :|| || :&&, arg1, arg2)) && fn′ === fn)
                    pop!(args)
                    push!(args, arg1)
                    push!(args, arg2)
                end
            elseif assoc === :left
                while ((@isexpr args[1] Expr(:call, fn′::Symbol, arg1, arg2)) && fn′ === fn) ||
                      ((@isexpr args[1] Expr(fn′ := :., arg1, QuoteNode(arg2))) && fn′ === fn) ||
                      ((@isexpr args[1] Expr(fn′ := :. || :(::), arg1, arg2)) && fn′ === fn)
                    popfirst!(args)
                    pushfirst!(args, arg2)
                    pushfirst!(args, arg1)
                end
            end
        else
            prefix = identifier(fn)
            par = ("(", ")")
        end
        if length(args) >= 1 && @isexpr args[1] Expr(:parameters, params...)
            args = args[2:end]
            args_lt = list_layout(Layout[tile_expr(arg, 0) for arg in args], par = ("", ""))
            params_lt = list_layout(Layout[tile_expr(param, 0) for param in params], par = ("", ""))
            list_layout(Layout[args_lt, params_lt], sep = "; ", prefix = prefix, par = ("(", ")"))
        else
            list_layout(Layout[tile_expr(arg, pr′) for arg in args],
                        prefix = prefix,
                        par = par,
                        sep = sep)
        end
    else
        prefix = tile_expr(fn)
        if !@isexpr fn Expr(:. || :curly || :macroname, _...)
            prefix = literal("(") * prefix * literal(")")
        end
        list_layout(Layout[tile_expr(arg, 0) for arg in args], prefix = prefix)
    end
end

const comparison_precedence = Base.operator_precedence(:(==))

function tile_expr_comparison(args, pr)
    arg = pop!(args)
    vlt = hlt = tile_expr(arg, comparison_precedence)
    while !isempty(args)
        op = pop!(args)
        arg = pop!(args)
        arg_lt = tile_expr(arg, comparison_precedence)
        vlt = (arg_lt * literal(" $op")) / vlt
        hlt = arg_lt * literal(" $op ") * hlt
    end
    hlt = nobreak(hlt)
    lt = hlt !== nothing ? vlt | hlt : vlt
    if pr >= comparison_precedence
        lt = literal("(") * lt * literal(")")
    end
    lt
end

function tile_expr_macro(fn, args, pr)
    prefix = tile_expr(fn, pr)
    if pr < 0 && length(args) <= 1
        par = (" ", "")
        sep = " "
    else
        par = ("(", ")")
        sep = ", "
    end
    list_layout(Layout[tile_expr(arg, 0) for arg in args], prefix = prefix, par = par, sep = sep)
end

const dot_precedence = Base.operator_precedence(:.)

function tile_expr_ref(t, args; par = ("[", "]"))
    prefix = tile_expr(t, dot_precedence - 1)
    list_layout(Layout[tile_expr(arg, 0) for arg in args],
                prefix = prefix,
                par = par)
end

function tile_expr_string(chunks)
    lts = Layout[literal("\"")]
    for chunk in chunks
        if chunk isa AbstractString
            push!(lts, literal(escape_string(chunk, "\"\$")))
        else
            push!(lts, literal("\$("))
            push!(lts, tile_expr(chunk))
            push!(lts, literal(")"))
        end
    end
    push!(lts, literal("\""))
    *(lts...)
end

function tile_expr_fallback(ex::Expr)
    items = Layout[tile(ex.head)]
    for arg in ex.args
        push!(items, tile(arg))
    end
    list_layout(prefix = "\$", Layout[list_layout(prefix = "Expr", items)])
end

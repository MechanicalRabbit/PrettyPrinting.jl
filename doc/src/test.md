# Test Suite

We start with importing the package.

    using PrettyPrinting: list_layout, literal, pair_layout, pprint, pprintln

The following function overrides the width of the output terminal.

    resize(w) = IOContext(stdout, :displaysize => (24, w))


## Formatting Built-in Data Structures

The function `pprint()` supports many built-in data structures.

In particular, `pprint()` can format `Pair` objects.

    p = :deinstitutionalization => :counterrevolutionaries

    pprint(p)
    #-> :deinstitutionalization => :counterrevolutionaries

    pprint(resize(40), p)
    #=>
    :deinstitutionalization =>
        :counterrevolutionaries
    =#

`pprint(::Pair)` can handle composite keys and values.

    p = :deinstitutionalization => [:notation, :nation, :initialization, :intuition]

    pprint(p)
    #-> :deinstitutionalization => [:notation, :nation, :initialization, :intuition]

    pprint(resize(60), p)
    #=>
    :deinstitutionalization =>
        [:notation, :nation, :initialization, :intuition]
    =#

    pprint(resize(50), p)
    #=>
    :deinstitutionalization => [:notation,
                                :nation,
                                :initialization,
                                :intuition]
    =#

    pprint(resize(40), p)
    #=>
    :deinstitutionalization =>
        [:notation,
         :nation,
         :initialization,
         :intuition]
    =#

    p = [:orientation, :interculture, :translucent] => :counterrevolutionaries

    pprint(p)
    #-> [:orientation, :interculture, :translucent] => :counterrevolutionaries

    pprint(resize(60), p)
    #=>
    [:orientation, :interculture, :translucent] =>
        :counterrevolutionaries
    =#

    pprint(resize(40), p)
    #=>
    [:orientation,
     :interculture,
     :translucent] =>
        :counterrevolutionaries
    =#

`pprint()` can also format tuples and vectors.

    pprint(())
    #-> ()

    pprint([])
    #-> []

    pprint((:deinstitutionalization,))
    #-> (:deinstitutionalization,)

    pprint([:deinstitutionalization])
    #-> [:deinstitutionalization]

    t = (:notation, :nation, :initialization, :intuition)

    pprint(t)
    #-> (:notation, :nation, :initialization, :intuition)

    pprint(collect(t))
    #-> [:notation, :nation, :initialization, :intuition]

    pprint(resize(40), t)
    #=>
    (:notation,
     :nation,
     :initialization,
     :intuition)
    =#

    pprint(resize(40), collect(t))
    #=>
    [:notation,
     :nation,
     :initialization,
     :intuition]
    =#

Finally, `pprint()` is implemented for sets, dictionaries and named tuples.

    pprint(Dict())
    #-> Dict()

    pprint(Set())
    #-> Set()

    pprint((deinstitutionalization = :counterrevolutionaries,))
    #-> (deinstitutionalization = :counterrevolutionaries,)

    pprint(Dict(:deinstitutionalization => :counterrevolutionaries))
    #-> Dict(:deinstitutionalization => :counterrevolutionaries)

    pprint(Set([:deinstitutionalization]))
    #-> Set([:deinstitutionalization])

    nt = (deinstitutionalization = [:notation, :nation, :initialization, :intuition],
          counterrevolutionaries = [:orientation, :interculture, :translucent])

    pprint(nt)
    #=>
    (deinstitutionalization = [:notation, :nation, :initialization, :intuition],
     counterrevolutionaries = [:orientation, :interculture, :translucent])
    =#

The following test has to be skipped because the order of entries in a
dictionary is unstable.

```julia
pprint(Dict(pairs(nt)))
#=>
Dict(:deinstitutionalization =>
         [:notation, :nation, :initialization, :intuition],
     :counterrevolutionaries => [:orientation, :interculture, :translucent])
=#

pprint(Set([:deinstitutionalization, :counterrevolutionaries]))
#-> Set([:deinstitutionalization, :counterrevolutionaries])
```


## Using `pair_layout()`

Function `pair_layout()` generates a layout expression for `Pair`-like objects.

    kl = literal(:deinstitutionalization)
    vl = literal(:counterrevolutionaries)

    pl = pair_layout(kl, vl)

    pprint(pl)
    #-> deinstitutionalization => counterrevolutionaries

    pprint(resize(40), pl)
    #=>
    deinstitutionalization =>
        counterrevolutionaries
    =#

Use parameter `sep` to change the separator.

    pprint(pair_layout(kl, vl, sep=" -> "))
    #-> deinstitutionalization -> counterrevolutionaries

Parameter `sep_brk` controls the position of the separator with respect to the
line break.

    pprint(resize(40), pair_layout(kl, vl, sep_brk=:start))
    #=>
    deinstitutionalization
        => counterrevolutionaries
    =#

    pprint(resize(40), pair_layout(kl, vl, sep_brk=:end))
    #=>
    deinstitutionalization =>
        counterrevolutionaries
    =#

    pprint(resize(40), pair_layout(kl, vl, sep_brk=:both))
    #=>
    deinstitutionalization =>
        => counterrevolutionaries
    =#

    pprint(resize(40), pair_layout(kl, vl, sep_brk=:none))
    #=>
    deinstitutionalization
        counterrevolutionaries
    =#

Parameter `tab` specifies the indentation level.

    pprint(resize(40), pair_layout(kl, vl, tab=0))
    #=>
    deinstitutionalization =>
    counterrevolutionaries
    =#


## Using `list_layout()`

Function `list_layout()` generates a layout expression for list-like objects.

    ls = literal.([:notation, :nation, :initialization, :intuition])

    ll = list_layout(ls)

    pprint(ll)
    #-> (notation, nation, initialization, intuition)

    pprint(resize(40), ll)
    #=>
    (notation,
     nation,
     initialization,
     intuition)
    =#

Use parameter `prefix` to add a prefix to the list.  This is useful for
generating functional notation.

    pprint(resize(30), list_layout(ls, prefix=:deinstitutionalization))
    #=>
    deinstitutionalization(
        notation,
        nation,
        initialization,
        intuition)
    =#

Parameter `par` specifies the left and the right parentheses.

    pprint(list_layout(ls, par=("[","]")))
    #-> [notation, nation, initialization, intuition]

Parameter `sep` to specifies the separator.

    pprint(list_layout(ls, sep=" * "))
    #-> (notation * nation * initialization * intuition)

Parameter `sep_brk` controls the position of separators with respect to
line breaks.

    pprint(resize(40), list_layout(ls, sep_brk=:start))
    #=>
    (notation
     , nation
     , initialization
     , intuition)
    =#

    pprint(resize(40), list_layout(ls, sep_brk=:end))
    #=>
    (notation,
     nation,
     initialization,
     intuition)
    =#

    pprint(resize(40), list_layout(ls, sep_brk=:both))
    #=>
    (notation,
     , nation,
     , initialization,
     , intuition)
    =#

    pprint(resize(40), list_layout(ls, sep_brk=:none))
    #=>
    (notation
     nation
     initialization
     intuition)
    =#

Parameter `tab` specifies the indentation level.

    pprint(resize(30), list_layout(ls, prefix=:deinstitutionalization, tab=0))
    #=>
    deinstitutionalization(
    notation,
    nation,
    initialization,
    intuition)
    =#

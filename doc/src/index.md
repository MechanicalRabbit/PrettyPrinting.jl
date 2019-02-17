# PPrint.jl


## Overview

`PPrint` is a Julia library for optimal formatting of composite data structures
on a fixed-width terminal.


### Installation

Use the Julia package manager.

```julia
julia> using Pkg
julia> Pkg.add("PPrint")
```


### Using `PPrint`

First, import the module.

    using PPrint

Use the function `pprint()` to print composite data structures formed of nested
tuples, vectors, and dictionaries.  The data will be formatted to fit the
screen size.

To demonstrate how to use `pprint()`, we create a small dataset of city
departments with associated employees.

    data = [(name = "POLICE",
             employees = [(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing),
                          (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)]),
            (name = "FIRE",
             employees = [(name = "JAMES A", position = "FIRE ENGINEER-EMT", salary = 103350, rate = missing),
                          (name = "DANIEL A", position = "FIRE FIGHTER-EMT", salary = 95484, rate = missing)]),
            (name = "OEMC",
             employees = [(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68),
                          (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])]

The built-in `print()` function prints this data on a single line, making the
output unreadable.

    print(data)
    #-> NamedTuple{(:name, :employees),T} where T<:Tuple[(name = "POLICE", employees = NamedTuple{ … }[ … ]) … ]

By contrast, `pprint()` formats the data to fit the screen size.

    pprint(data)
    #=>
    [(name = "POLICE",
      employees = [(name = "JEFFERY A",
                    position = "SERGEANT",
                    salary = 101442,
                    rate = missing),
                   (name = "NANCY A",
                    position = "POLICE OFFICER",
                    salary = 80016,
                    rate = missing)]),
     (name = "FIRE",
      employees = [(name = "JAMES A",
                    position = "FIRE ENGINEER-EMT",
                    salary = 103350,
                    rate = missing),
                   (name = "DANIEL A",
                    position = "FIRE FIGHTER-EMT",
                    salary = 95484,
                    rate = missing)]),
     (name = "OEMC",
      employees = [(name = "LAKENYA A",
                    position = "CROSSING GUARD",
                    salary = missing,
                    rate = 17.68),
                   (name = "DORIS A",
                    position = "CROSSING GUARD",
                    salary = missing,
                    rate = 19.38)])]
    =#

The width of the output is controlled by the `displaysize` property of the
output stream.

    pprint(IOContext(stdout, :displaysize => (24, 100)), data)
    #=>
    [(name = "POLICE",
      employees = [(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing),
                   (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)]),
     (name = "FIRE",
      employees =
          [(name = "JAMES A", position = "FIRE ENGINEER-EMT", salary = 103350, rate = missing),
           (name = "DANIEL A", position = "FIRE FIGHTER-EMT", salary = 95484, rate = missing)]),
     (name = "OEMC",
      employees = [(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68),
                   (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])]
    =#


### Layout expressions

`PPrint` can be extended to format any custom data structure.  To let `PPrint`
format a data structure, we need to encode its possible layouts in the form of
a *layout expression*.

A fixed single-line layout is created with `PPrint.literal()`.

    ll = PPrint.literal("salary")
    #-> literal("salary")

Layouts could be combined using horizontal (`*`) and vertical (`/`) composition
operators.

    lhz = PPrint.literal("salary") * PPrint.literal(" = ") * PPrint.literal("101442")
    #-> literal("salary") * literal(" = ") * literal("101442")

    lvt = PPrint.literal("salary") * PPrint.literal(" =") /
          PPrint.indent(4) * PPrint.literal("101442")
    #-> literal("salary") * literal(" =") / indent(4) * literal("101442")

Here, `PPrint.indent(4)` is equivalent to `PPrint.literal(" "^4)`.

Function `PPrint.pprint()` serializes the layout.

    pprint(ll)
    #-> salary

    pprint(lhz)
    #-> salary = 101442

    pprint(lvt)
    #=>
    salary =
        101442
    =#

To indicate that we can choose between several different layouts, we use the
choice (`|`) operator.

    l = lhz | lvt
    #=>
    literal("salary") * literal(" = ") * literal("101442") |
    literal("salary") * literal(" =") / indent(4) * literal("101442")
    =#

The pretty-printing engine can search through possible layouts to find the best
fit, which is expressed as a layout expression without a choice operator.

    PPrint.best(PPrint.fit(l))
    #-> literal("salary") * (literal(" = ") * literal("101442"))

In addition, `PPrint` provides functions for generating some common layouts.  A
delimiter-separated pair can be generated with `PPrint.pair_layout()`.

    PPrint.pair_layout(PPrint.literal("salary"),
                       PPrint.literal("101442"),
                       sep=" = ")
    #=>
    (literal("salary") * literal(" = ") |
     literal("salary") * literal(" =") / indent(4)) *
    literal("101442")
    =#

A delimiter-separated list of items can be generated with
`PPrint.list_layout()`.

    PPrint.list_layout([PPrint.literal("salary = 101442"),
                        PPrint.literal("rate = missing")])
    #=>
    (literal("(") | literal("(") / indent(4)) *
    (literal("salary = 101442") * literal(",") / literal("rate = missing")) *
    literal(")") |
    literal("(") *
    (literal("salary = 101442") * literal(", ") * literal("rate = missing")) *
    literal(")")
    =#


### Extending `PPrint`

We can make `pprint()` format objects of user-defined types.  For this purpose,
we must implement the function `PPrint.tile()`, which should map an object to
its layout expression.

For example, consider a simple tree structure.

    struct Node
        name::Symbol
        arms::Vector{Node}
    end

    Node(name) = Node(name, [])

    tree =
        Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage),
                                            Node(:anchorite)]),
                             Node(:anchovy),
                             Node(:antic, [Node(:anticipation)])]),
                  Node(:arc, [Node(:arch, [Node(:archduke),
                                           Node(:archer)])]),
                  Node(:awl)])
    #-> Node(:a, Main.index.md.Node[ … ])

To make `pprint()` format this tree, we must implement the function
`PPrint.tile(::Node)`.  A suitable layout expression for this tree could be
generated with `PPrint.list_layout()`.

    function PPrint.tile(tree::Node)
        if isempty(tree.arms)
            return PPrint.literal("Node($(repr(tree.name)))")
        end
        arm_lts = [PPrint.tile(arm) for arm in tree.arms]
        return PPrint.list_layout(arm_lts, prefix="Node($(repr(tree.name)), ", par=("[", "])"))
    end

Now `pprint()` renders a nicely formatted representation of the tree.

    pprint(stdout, tree)
    #=>
    Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),
                         Node(:anchovy),
                         Node(:antic, [Node(:anticipation)])]),
              Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),
              Node(:awl)])
    =#


## Acknowledgements

The algorithm for finding the optimal layout is based upon
[Phillip Yelland, A New Approach to Optimal Code Formatting, 2016](https://ai.google/research/pubs/pub44667).


## API Reference

```@docs
PPrint.pprint
```


## Test Suite

The following function overrides the width of the output terminal.

    resize(w) = IOContext(stdout, :displaysize => (24, w))


### Formatting built-in data structures

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

Finally, `pprint()` is implemented for dictionaries and named tuples.

    pprint(Dict())
    #-> Dict()

    pprint((deinstitutionalization = :counterrevolutionaries,))
    #-> (deinstitutionalization = :counterrevolutionaries,)

    pprint(Dict(:deinstitutionalization => :counterrevolutionaries))
    #-> Dict(:deinstitutionalization => :counterrevolutionaries)

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
```


### Using `pair_layout()`

Function `pair_layout()` generates a layout expression for `Pair`-like objects.

    kl = PPrint.literal(:deinstitutionalization)
    vl = PPrint.literal(:counterrevolutionaries)

    pl = PPrint.pair_layout(kl, vl)

    pprint(pl)
    #-> deinstitutionalization => counterrevolutionaries

    pprint(resize(40), pl)
    #=>
    deinstitutionalization =>
        counterrevolutionaries
    =#

Use parameter `sep` to change the separator.

    pprint(PPrint.pair_layout(kl, vl, sep=" -> "))
    #-> deinstitutionalization -> counterrevolutionaries

Parameter `sep_brk` controls the position of the separator with respect to the
line break.

    pprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:start))
    #=>
    deinstitutionalization
        => counterrevolutionaries
    =#

    pprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:end))
    #=>
    deinstitutionalization =>
        counterrevolutionaries
    =#

    pprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:both))
    #=>
    deinstitutionalization =>
        => counterrevolutionaries
    =#

    pprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:none))
    #=>
    deinstitutionalization
        counterrevolutionaries
    =#

Parameter `tab` specifies the indentation level.

    pprint(resize(40), PPrint.pair_layout(kl, vl, tab=0))
    #=>
    deinstitutionalization =>
    counterrevolutionaries
    =#


### Using `list_layout()`

Function `list_layout()` generates a layout expression for list-like objects.

    ls = PPrint.literal.([:notation, :nation, :initialization, :intuition])

    ll = PPrint.list_layout(ls)

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

    pprint(resize(30), PPrint.list_layout(ls, prefix=:deinstitutionalization))
    #=>
    deinstitutionalization(
        notation,
        nation,
        initialization,
        intuition)
    =#

Parameter `par` specifies the left and the right parentheses.

    pprint(PPrint.list_layout(ls, par=("[","]")))
    #-> [notation, nation, initialization, intuition]

Parameter `sep` to specifies the separator.

    pprint(PPrint.list_layout(ls, sep=" * "))
    #-> (notation * nation * initialization * intuition)

Parameter `sep_brk` controls the position of separators with respect to
line breaks.

    pprint(resize(40), PPrint.list_layout(ls, sep_brk=:start))
    #=>
    (notation
     , nation
     , initialization
     , intuition)
    =#

    pprint(resize(40), PPrint.list_layout(ls, sep_brk=:end))
    #=>
    (notation,
     nation,
     initialization,
     intuition)
    =#

    pprint(resize(40), PPrint.list_layout(ls, sep_brk=:both))
    #=>
    (notation,
     , nation,
     , initialization,
     , intuition)
    =#

    pprint(resize(40), PPrint.list_layout(ls, sep_brk=:none))
    #=>
    (notation
     nation
     initialization
     intuition)
    =#

Parameter `tab` specifies the indentation level.

    pprint(resize(30), PPrint.list_layout(ls, prefix=:deinstitutionalization, tab=0))
    #=>
    deinstitutionalization(
    notation,
    nation,
    initialization,
    intuition)
    =#

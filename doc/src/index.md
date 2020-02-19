# PrettyPrinting.jl


## Overview

PrettyPrinting is a Julia library for optimal formatting of composite data
structures on a fixed-width terminal.


### Installation

Use the Julia package manager.

```julia
julia> using Pkg
julia> Pkg.add("PrettyPrinting")
```


### Using PrettyPrinting

First, import the module.

    using PrettyPrinting

Use the function `pprint()` to print composite data structures formed of nested
tuples, vectors, and dictionaries.  The data will be formatted to fit the
screen size.

To demonstrate how to use `pprint()`, we consider a small dataset of city
departments with associated employees.

    data = [(name = "POLICE",
             employees = [(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing),
                          (name = "NANCY A", position = "POLICE OFFICER", salary = 80016, rate = missing)]),
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
     (name = "OEMC",
      employees = [(name = "LAKENYA A", position = "CROSSING GUARD", salary = missing, rate = 17.68),
                   (name = "DORIS A", position = "CROSSING GUARD", salary = missing, rate = 19.38)])]
    =#

If you want to add a newline after the output, use the function `pprintln()`.

    pprintln(data[1])
    pprintln(data[2])
    #=>
    (name = "POLICE",
     employees = [(name = "JEFFERY A",
                   position = "SERGEANT",
                   salary = 101442,
                   rate = missing),
                  (name = "NANCY A",
                   position = "POLICE OFFICER",
                   salary = 80016,
                   rate = missing)])
    (name = "OEMC",
     employees = [(name = "LAKENYA A",
                   position = "CROSSING GUARD",
                   salary = missing,
                   rate = 17.68),
                  (name = "DORIS A",
                   position = "CROSSING GUARD",
                   salary = missing,
                   rate = 19.38)])
    =#


### Layout expressions

PrettyPrinting can be extended to format any custom data structure.  To let
PrettyPrinting format a data structure, we need to encode its possible layouts
in the form of a *layout expression*.

We will use the following definitions.

    using PrettyPrinting:
        best_fit,
        indent,
        list_layout,
        literal,
        pair_layout

A fixed single-line layout is created with `literal()`.

    ll = literal("salary")
    #-> literal("salary")

Layouts could be combined using horizontal (`*`) and vertical (`/`) composition
operators.

    lhz = literal("salary") * literal(" = ") * literal("101442")
    #-> literal("salary") * literal(" = ") * literal("101442")

    lvt = literal("salary") * literal(" =") /
          indent(4) * literal("101442")
    #-> literal("salary") * literal(" =") / indent(4) * literal("101442")

Here, `indent(4)` is equivalent to `literal(" "^4)`.

Function `pprint()` serializes the layout.

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

    best_fit(l)
    #-> literal("salary") * (literal(" = ") * literal("101442"))

In addition, PrettyPrinting can generate some common layouts.  A
delimiter-separated pair can be generated with `pair_layout()`.

    pair_layout(literal("salary"), literal("101442"), sep=" = ")
    #=>
    (literal("salary") * literal(" = ") |
     literal("salary") * literal(" =") / indent(4)) *
    literal("101442")
    =#

A delimiter-separated list of items can be generated with `list_layout()`.

    list_layout([literal("salary = 101442"), literal("rate = missing")])
    #=>
    (literal("(") | literal("(") / indent(4)) *
    (literal("salary = 101442") * literal(",") / literal("rate = missing")) *
    literal(")") |
    literal("(") *
    (literal("salary = 101442") * literal(", ") * literal("rate = missing")) *
    literal(")")
    =#


### Extending PrettyPrinting

We can make `pprint()` format objects of user-defined types.  For this purpose,
we must implement the function `tile()`, which should map an object to its
layout expression.

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
`tile(::Node)`.  A suitable layout expression for this tree could be generated
with `list_layout()`.

    import PrettyPrinting:
        tile

    function tile(tree::Node)
        if isempty(tree.arms)
            return literal("Node($(repr(tree.name)))")
        end
        return list_layout(tile.(tree.arms),
                           prefix="Node($(repr(tree.name)), ", par=("[", "])"))
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
PrettyPrinting.pprint
PrettyPrinting.pprintln
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


### Using `list_layout()`

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


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

We start with creating a simple tree structure.

To specify a layout expression for `Node` objects, we need to override
`PPrint.tile()`.  Layout expressions are assembled from `PPrint.literal()`
primitives using operators `*` (horizontal composition), `/` (vertical
composition), and `|` (choice).

We can control the width of the output.

    pprint(IOContext(stdout, :displaysize => (24, 60)), tree)
    #=>
    Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage),
                                        Node(:anchorite)]),
                         Node(:anchovy),
                         Node(:antic, [Node(:anticipation)])]),
              Node(:arc, [Node(:arch, [Node(:archduke),
                                       Node(:archer)])]),
              Node(:awl)])
    =#

We can display the layout expression itself, both the original and the
optimized variants.

    PPrint.tile(tree)
    #=>
    (literal("Node(:a, [") | literal("Node(:a, [") / indent(4)) *
    (((literal("Node(:an, [") | literal("Node(:an, [") / indent(4)) *
      (((literal("Node(:anchor, [") | literal("Node(:anchor, [") / indent(4)) *
        ⋮
    =#

    PPrint.best(PPrint.fit(stdout, PPrint.tile(tree)))
    #=>
    literal("Node(:a, [") *
    (literal("Node(:an, [") *
     (literal("Node(:anchor, [") *
      ⋮
    =#

For some built-in data structures, automatic layout is already provided.

    data = [
        (name = "RICHARD A", position = "FIREFIGHTER", salary = 90018),
        (name = "DEBORAH A", position = "POLICE OFFICER", salary = 86520),
        (name = "KATHERINE A", position = "PERSONAL COMPUTER OPERATOR II", salary = 60780)
    ]

    pprint(data)
    #=>
    [(name = "RICHARD A", position = "FIREFIGHTER", salary = 90018),
     (name = "DEBORAH A", position = "POLICE OFFICER", salary = 86520),
     (name = "KATHERINE A",
      position = "PERSONAL COMPUTER OPERATOR II",
      salary = 60780)]
    =#

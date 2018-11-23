# PPrint.jl


## Overview

Module `PPrint` implements a pretty-printing engine for visualizing composite
data structures.

    using PPrint

To format a data structure, we need to encode its possible layouts in the form
of a *layout expression*.

A fixed single-line layout is created with `PPrint.literal()`.

    ll = PPrint.literal("department")
    #-> literal("department")

PPrint could be combined using horizontal and vertical composition operators.

    lhz = PPrint.literal("department") * PPrint.literal(".") * PPrint.literal("name")
    #-> literal("department") * literal(".") * literal("name")

    lvt = PPrint.literal("department") / PPrint.literal("name")
    #-> literal("department") / literal("name")

Function `PPrint.pprint()` serializes the layout.

    pprint(ll)
    #-> department

    pprint(lhz)
    #-> department.name

    pprint(lvt)
    #=>
    department
    name
    =#

To indicate that we can choose between several different layouts, use the
choice operator.

    l = lhz | lvt
    #=>
    literal("department") * literal(".") * literal("name")
    | literal("department") / literal("name")
    =#

The pretty-printing engine can search through possible layouts to find the best
fit, which is expressed as a layout expression without a choice operator.

    PPrint.best(PPrint.fit(l))
    #-> literal("department") * (literal(".") * literal("name"))


# Acknowledgements

The algorithm for finding the optimal layout is based upon
[Phillip Yelland, A New Approach to Optimal Code Formatting, 2016](https://ai.google/research/pubs/pub44667).


## API Reference

```@docs
PPrint.pprint
```


## Test Suite

We start with creating a simple tree structure.

    struct Node
        name::Symbol
        arms::Vector{Node}
    end

    Node(name) = Node(name, [])

    tree =
        Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),
                               Node(:anchovy),
                               Node(:antic, [Node(:anticipation)])]),
                   Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),
                   Node(:awl)])
    #-> Node(:a, Main.index.md.Node[ … ])

To specify a layout expression for `Node` objects, we need to override
`PPrint.tile()`.  Layout expressions are assembled from `PPrint.literal()`
primitives using operators `*` (horizontal composition), `/` (vertical
composition), and `|` (choice).

    function PPrint.tile(tree::Node)
        if isempty(tree.arms)
            return PPrint.literal("Node($(repr(tree.name)))")
        end
        arm_lts = [PPrint.tile(arm) for arm in tree.arms]
        return PPrint.list_layout(arm_lts, prefix="Node($(repr(tree.name)), ", par=("[", "])"))
    end

Now we can use function `pprint()` to render a nicely formatted representation
of the tree.

    pprint(stdout, tree)
    #=>
    Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),
                         Node(:anchovy),
                         Node(:antic, [Node(:anticipation)])]),
              Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),
              Node(:awl)])
    =#

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
    (literal("Node(:a, [") | literal("Node(:a, [") / indent(4))
    * (((literal("Node(:an, [") | literal("Node(:an, [") / indent(4))
        * (((literal("Node(:anchor, [") | literal("Node(:anchor, [") / indent(4))
       ⋮
    =#

    PPrint.best(PPrint.fit(stdout, PPrint.tile(tree)))
    #=>
    literal("Node(:a, [")
    * (literal("Node(:an, [")
       * (literal("Node(:anchor, [")
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

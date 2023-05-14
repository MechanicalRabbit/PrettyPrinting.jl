# Usage Guide


## Installation

Use the Julia package manager.

```julia
julia> using Pkg
julia> Pkg.add("PrettyPrinting")
```


## Using PrettyPrinting

First, import the module.

    using PrettyPrinting

Use the function `pprint()` to print composite data structures formed of nested
tuples, vectors, and dictionaries.  The data will be formatted to fit the
screen size.

To demonstrate how to use `pprint()`, we take a small dataset of city
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
    #-> NamedTuple … [(name = "POLICE", employees = … [(name = "JEFFERY A", position = "SERGEANT", salary = 101442, rate = missing), … ]) … ]

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

To add a line break after the output, use the function `pprintln()`.

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


## Formatting Julia Code

PrettyPrinting can format Julia code represented as an `Expr` object.  It
supports a fair subset of Julia syntax including top-level declarations,
statements, and expressions.

    ex = quote
        fib(n::Number) = n > 1 ? fib(n-1) + fib(n-2) : n
        @show fib(10)
    end

    pprint(ex)
    #=>
    quote
        fib(n::Number) = n > 1 ? fib(n - 1) + fib(n - 2) : n
        @show fib(10)
    end
    =#


## Extending PrettyPrinting

It is customary to display a Julia object as a valid Julia expression that
constructs the object.  The ability of `pprint()` to format Julia code makes it
easy to implement this functionality for user-defined types.

For example, consider the following hierarchical data type.

    struct Node
        name::Symbol
        arms::Vector{Node}
    end

    Node(name) = Node(name, [])

Let us create a nested tree of this type.

    tree =
        Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage),
                                            Node(:anchorite)]),
                             Node(:anchovy),
                             Node(:antic, [Node(:anticipation)])]),
                  Node(:arc, [Node(:arch, [Node(:archduke),
                                           Node(:archer)])]),
                  Node(:awl)])
    #-> Node(:a, …)

To make `pprint()` format this tree, we need to implement the function
`quoteof(::Node)`, which should return an `Expr` object.

    import PrettyPrinting: quoteof

    quoteof(n::Node) =
        if isempty(n.arms)
            :(Node($(quoteof(n.name))))
        else
            :(Node($(quoteof(n.name)), $(quoteof(n.arms))))
        end

That's it!  Now `pprint()` displays a nicely formatted Julia expression that
represents the tree.

    pprint(tree)
    #=>
    Node(:a,
         [Node(:an,
               [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),
                Node(:anchovy),
                Node(:antic, [Node(:anticipation)])]),
          Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),
          Node(:awl)])
    =#

We can even override `show()` to make it display this representation.

    Base.show(io::IO, ::MIME"text/plain", n::Node) =
        pprint(io, n)

    display(tree)
    #=>
    Node(:a,
         [Node(:an,
               [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),
                Node(:anchovy),
                Node(:antic, [Node(:anticipation)])]),
          Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),
          Node(:awl)])
    =#


## Layout Expressions

Internally, PrettyPrinting represents all potential layouts of a data structure
in the form of a *layout expression*.

We will use the following definitions.

    using PrettyPrinting: best_fit, indent, list_layout, literal, pair_layout

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

The pretty-printing engine can search through all potential layouts to find the
best fit, which is expressed as a layout expression without the choice
operator.

    best_fit(l)
    #-> literal("salary") * (literal(" = ") * literal("101442"))

In addition to the primitive operations, PrettyPrinting can generate some
common layouts.  A delimiter-separated pair can be generated with
`pair_layout()`.

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


## Custom Layouts

We can customize how `pprint()` formats objects of a user-defined type by
implementing function `tile()`, which should map an object to the corresponding
layout expression.

Continuing with the type `Node` defined in section [Extending
PrettyPrinting](@ref), let us give it a custom layout generated with
`list_layout()`.

    import PrettyPrinting: tile

    tile(n::Node) =
        if isempty(n.arms)
            literal(n.name)
        else
            literal(n.name) *
            literal(" -> ") *
            list_layout(tile.(n.arms))
        end

Now `pprint()` will render a new representation of the tree.

    pprint(stdout, tree)
    #=>
    a -> (an -> (anchor -> (anchorage, anchorite),
                 anchovy,
                 antic -> (anticipation)),
          arc -> (arch -> (archduke, archer)),
          awl)
    =#

In summary, there are two ways to customize `pprint()` for a user-defined type
`T`.

1. Define `PrettyPrinting.quoteof(::T)`, which should return an `Expr` object.
2. Define `PrettyPrinting.tile(::T)`, which should return a layout expression.

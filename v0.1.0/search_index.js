var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#PPrint.jl-1",
    "page": "Home",
    "title": "PPrint.jl",
    "category": "section",
    "text": ""
},

{
    "location": "#Overview-1",
    "page": "Home",
    "title": "Overview",
    "category": "section",
    "text": "PPrint is a Julia library for optimal formatting of composite data structures on a fixed-width terminal."
},

{
    "location": "#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "Use the Julia package manager.julia> using Pkg\njulia> Pkg.add(\"PPrint\")"
},

{
    "location": "#Using-PPrint-1",
    "page": "Home",
    "title": "Using PPrint",
    "category": "section",
    "text": "First, import the module.using PPrintUse the function pprint() to print composite data structures formed of nested tuples, vectors, and dictionaries.  The data will be formatted to fit the screen size.To demonstrate how to use pprint(), we create a small dataset of city departments with associated employees.data = [(name = \"POLICE\",\n         employees = [(name = \"JEFFERY A\", position = \"SERGEANT\", salary = 101442, rate = missing),\n                      (name = \"NANCY A\", position = \"POLICE OFFICER\", salary = 80016, rate = missing)]),\n        (name = \"FIRE\",\n         employees = [(name = \"JAMES A\", position = \"FIRE ENGINEER-EMT\", salary = 103350, rate = missing),\n                      (name = \"DANIEL A\", position = \"FIRE FIGHTER-EMT\", salary = 95484, rate = missing)]),\n        (name = \"OEMC\",\n         employees = [(name = \"LAKENYA A\", position = \"CROSSING GUARD\", salary = missing, rate = 17.68),\n                      (name = \"DORIS A\", position = \"CROSSING GUARD\", salary = missing, rate = 19.38)])]The built-in print() function prints this data on a single line, making the output unreadable.print(data)\n#-> NamedTuple{(:name, :employees),T} where T<:Tuple[(name = \"POLICE\", employees = NamedTuple{ … }[ … ]) … ]By contrast, pprint() formats the data to fit the screen size.pprint(data)\n#=>\n[(name = \"POLICE\",\n  employees = [(name = \"JEFFERY A\",\n                position = \"SERGEANT\",\n                salary = 101442,\n                rate = missing),\n               (name = \"NANCY A\",\n                position = \"POLICE OFFICER\",\n                salary = 80016,\n                rate = missing)]),\n (name = \"FIRE\",\n  employees = [(name = \"JAMES A\",\n                position = \"FIRE ENGINEER-EMT\",\n                salary = 103350,\n                rate = missing),\n               (name = \"DANIEL A\",\n                position = \"FIRE FIGHTER-EMT\",\n                salary = 95484,\n                rate = missing)]),\n (name = \"OEMC\",\n  employees = [(name = \"LAKENYA A\",\n                position = \"CROSSING GUARD\",\n                salary = missing,\n                rate = 17.68),\n               (name = \"DORIS A\",\n                position = \"CROSSING GUARD\",\n                salary = missing,\n                rate = 19.38)])]\n=#The width of the output is controlled by the displaysize property of the output stream.pprint(IOContext(stdout, :displaysize => (24, 100)), data)\n#=>\n[(name = \"POLICE\",\n  employees = [(name = \"JEFFERY A\", position = \"SERGEANT\", salary = 101442, rate = missing),\n               (name = \"NANCY A\", position = \"POLICE OFFICER\", salary = 80016, rate = missing)]),\n (name = \"FIRE\",\n  employees =\n      [(name = \"JAMES A\", position = \"FIRE ENGINEER-EMT\", salary = 103350, rate = missing),\n       (name = \"DANIEL A\", position = \"FIRE FIGHTER-EMT\", salary = 95484, rate = missing)]),\n (name = \"OEMC\",\n  employees = [(name = \"LAKENYA A\", position = \"CROSSING GUARD\", salary = missing, rate = 17.68),\n               (name = \"DORIS A\", position = \"CROSSING GUARD\", salary = missing, rate = 19.38)])]\n=#"
},

{
    "location": "#Layout-expressions-1",
    "page": "Home",
    "title": "Layout expressions",
    "category": "section",
    "text": "PPrint can be extended to format any custom data structure.  To let PPrint format a data structure, we need to encode its possible layouts in the form of a layout expression.A fixed single-line layout is created with PPrint.literal().ll = PPrint.literal(\"salary\")\n#-> literal(\"salary\")Layouts could be combined using horizontal (*) and vertical (/) composition operators.lhz = PPrint.literal(\"salary\") * PPrint.literal(\" = \") * PPrint.literal(\"101442\")\n#-> literal(\"salary\") * literal(\" = \") * literal(\"101442\")\n\nlvt = PPrint.literal(\"salary\") * PPrint.literal(\" =\") /\n      PPrint.indent(4) * PPrint.literal(\"101442\")\n#-> literal(\"salary\") * literal(\" =\") / indent(4) * literal(\"101442\")Here, PPrint.indent(4) is equivalent to PPrint.literal(\" \"^4).Function PPrint.pprint() serializes the layout.pprint(ll)\n#-> salary\n\npprint(lhz)\n#-> salary = 101442\n\npprint(lvt)\n#=>\nsalary =\n    101442\n=#To indicate that we can choose between several different layouts, we use the choice (|) operator.l = lhz | lvt\n#=>\nliteral(\"salary\") * literal(\" = \") * literal(\"101442\") |\nliteral(\"salary\") * literal(\" =\") / indent(4) * literal(\"101442\")\n=#The pretty-printing engine can search through possible layouts to find the best fit, which is expressed as a layout expression without a choice operator.PPrint.best(PPrint.fit(l))\n#-> literal(\"salary\") * (literal(\" = \") * literal(\"101442\"))In addition, PPrint provides functions for generating some common layouts.  A delimiter-separated pair can be generated with PPrint.pair_layout().PPrint.pair_layout(PPrint.literal(\"salary\"),\n                   PPrint.literal(\"101442\"),\n                   sep=\" = \")\n#=>\n(literal(\"salary\") * literal(\" = \") |\n literal(\"salary\") * literal(\" =\") / indent(4)) *\nliteral(\"101442\")\n=#A delimiter-separated list of items can be generated with PPrint.list_layout().PPrint.list_layout([PPrint.literal(\"salary = 101442\"),\n                    PPrint.literal(\"rate = missing\")])\n#=>\n(literal(\"(\") | literal(\"(\") / indent(4)) *\n(literal(\"salary = 101442\") * literal(\",\") / literal(\"rate = missing\")) *\nliteral(\")\") |\nliteral(\"(\") *\n(literal(\"salary = 101442\") * literal(\", \") * literal(\"rate = missing\")) *\nliteral(\")\")\n=#"
},

{
    "location": "#Extending-PPrint-1",
    "page": "Home",
    "title": "Extending PPrint",
    "category": "section",
    "text": "We can make pprint() format objects of user-defined types.  For this purpose, we must implement the function PPrint.tile(), which should map an object to its layout expression.For example, consider a simple tree structure.struct Node\n    name::Symbol\n    arms::Vector{Node}\nend\n\nNode(name) = Node(name, [])\n\ntree =\n    Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage),\n                                        Node(:anchorite)]),\n                         Node(:anchovy),\n                         Node(:antic, [Node(:anticipation)])]),\n              Node(:arc, [Node(:arch, [Node(:archduke),\n                                       Node(:archer)])]),\n              Node(:awl)])\n#-> Node(:a, Main.index.md.Node[ … ])To make pprint() format this tree, we must implement the function PPrint.tile(::Node).  A suitable layout expression for this tree could be generated with PPrint.list_layout().function PPrint.tile(tree::Node)\n    if isempty(tree.arms)\n        return PPrint.literal(\"Node($(repr(tree.name)))\")\n    end\n    arm_lts = [PPrint.tile(arm) for arm in tree.arms]\n    return PPrint.list_layout(arm_lts, prefix=\"Node($(repr(tree.name)), \", par=(\"[\", \"])\"))\nendNow pprint() renders a nicely formatted representation of the tree.pprint(stdout, tree)\n#=>\nNode(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),\n                     Node(:anchovy),\n                     Node(:antic, [Node(:anticipation)])]),\n          Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),\n          Node(:awl)])\n=#"
},

{
    "location": "#Acknowledgements-1",
    "page": "Home",
    "title": "Acknowledgements",
    "category": "section",
    "text": "The algorithm for finding the optimal layout is based upon Phillip Yelland, A New Approach to Optimal Code Formatting, 2016."
},

{
    "location": "#PPrint.pprint",
    "page": "Home",
    "title": "PPrint.pprint",
    "category": "function",
    "text": "PPrint.pprint([io::IO], data)\n\nDisplays the data so that it fits the width of the output screen.\n\n\n\n\n\n"
},

{
    "location": "#API-Reference-1",
    "page": "Home",
    "title": "API Reference",
    "category": "section",
    "text": "PPrint.pprint"
},

{
    "location": "#Test-Suite-1",
    "page": "Home",
    "title": "Test Suite",
    "category": "section",
    "text": "The following function overrides the width of the output terminal.resize(w) = IOContext(stdout, :displaysize => (24, w))"
},

{
    "location": "#Formatting-built-in-data-structures-1",
    "page": "Home",
    "title": "Formatting built-in data structures",
    "category": "section",
    "text": "The function pprint() supports many built-in data structures.In particular, pprint() can format Pair objects.p = :deinstitutionalization => :counterrevolutionaries\n\npprint(p)\n#-> :deinstitutionalization => :counterrevolutionaries\n\npprint(resize(40), p)\n#=>\n:deinstitutionalization =>\n    :counterrevolutionaries\n=#pprint(::Pair) can handle composite keys and values.p = :deinstitutionalization => [:notation, :nation, :initialization, :intuition]\n\npprint(p)\n#-> :deinstitutionalization => [:notation, :nation, :initialization, :intuition]\n\npprint(resize(60), p)\n#=>\n:deinstitutionalization =>\n    [:notation, :nation, :initialization, :intuition]\n=#\n\npprint(resize(50), p)\n#=>\n:deinstitutionalization => [:notation,\n                            :nation,\n                            :initialization,\n                            :intuition]\n=#\n\npprint(resize(40), p)\n#=>\n:deinstitutionalization =>\n    [:notation,\n     :nation,\n     :initialization,\n     :intuition]\n=#\n\np = [:orientation, :interculture, :translucent] => :counterrevolutionaries\n\npprint(p)\n#-> [:orientation, :interculture, :translucent] => :counterrevolutionaries\n\npprint(resize(60), p)\n#=>\n[:orientation, :interculture, :translucent] =>\n    :counterrevolutionaries\n=#\n\npprint(resize(40), p)\n#=>\n[:orientation,\n :interculture,\n :translucent] =>\n    :counterrevolutionaries\n=#pprint() can also format tuples and vectors.pprint(())\n#-> ()\n\npprint([])\n#-> []\n\npprint((:deinstitutionalization,))\n#-> (:deinstitutionalization,)\n\npprint([:deinstitutionalization])\n#-> [:deinstitutionalization]\n\nt = (:notation, :nation, :initialization, :intuition)\n\npprint(t)\n#-> (:notation, :nation, :initialization, :intuition)\n\npprint(collect(t))\n#-> [:notation, :nation, :initialization, :intuition]\n\npprint(resize(40), t)\n#=>\n(:notation,\n :nation,\n :initialization,\n :intuition)\n=#\n\npprint(resize(40), collect(t))\n#=>\n[:notation,\n :nation,\n :initialization,\n :intuition]\n=#Finally, pprint() is implemented for dictionaries and named tuples.pprint(Dict())\n#-> Dict()\n\npprint((deinstitutionalization = :counterrevolutionaries,))\n#-> (deinstitutionalization = :counterrevolutionaries,)\n\npprint(Dict(:deinstitutionalization => :counterrevolutionaries))\n#-> Dict(:deinstitutionalization => :counterrevolutionaries)\n\nnt = (deinstitutionalization = [:notation, :nation, :initialization, :intuition],\n      counterrevolutionaries = [:orientation, :interculture, :translucent])\n\npprint(nt)\n#=>\n(deinstitutionalization = [:notation, :nation, :initialization, :intuition],\n counterrevolutionaries = [:orientation, :interculture, :translucent])\n=#The following test has to be skipped because the order of entries in a dictionary is unstable.pprint(Dict(pairs(nt)))\n#=>\nDict(:deinstitutionalization =>\n         [:notation, :nation, :initialization, :intuition],\n     :counterrevolutionaries => [:orientation, :interculture, :translucent])\n=#"
},

{
    "location": "#Using-pair_layout()-1",
    "page": "Home",
    "title": "Using pair_layout()",
    "category": "section",
    "text": "Function pair_layout() generates a layout expression for Pair-like objects.kl = PPrint.literal(:deinstitutionalization)\nvl = PPrint.literal(:counterrevolutionaries)\n\npl = PPrint.pair_layout(kl, vl)\n\npprint(pl)\n#-> deinstitutionalization => counterrevolutionaries\n\npprint(resize(40), pl)\n#=>\ndeinstitutionalization =>\n    counterrevolutionaries\n=#Use parameter sep to change the separator.pprint(PPrint.pair_layout(kl, vl, sep=\" -> \"))\n#-> deinstitutionalization -> counterrevolutionariesParameter sep_brk controls the position of the separator with respect to the line break.pprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:start))\n#=>\ndeinstitutionalization\n    => counterrevolutionaries\n=#\n\npprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:end))\n#=>\ndeinstitutionalization =>\n    counterrevolutionaries\n=#\n\npprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:both))\n#=>\ndeinstitutionalization =>\n    => counterrevolutionaries\n=#\n\npprint(resize(40), PPrint.pair_layout(kl, vl, sep_brk=:none))\n#=>\ndeinstitutionalization\n    counterrevolutionaries\n=#Parameter tab specifies the indentation level.pprint(resize(40), PPrint.pair_layout(kl, vl, tab=0))\n#=>\ndeinstitutionalization =>\ncounterrevolutionaries\n=#"
},

{
    "location": "#Using-list_layout()-1",
    "page": "Home",
    "title": "Using list_layout()",
    "category": "section",
    "text": "Function list_layout() generates a layout expression for list-like objects.ls = PPrint.literal.([:notation, :nation, :initialization, :intuition])\n\nll = PPrint.list_layout(ls)\n\npprint(ll)\n#-> (notation, nation, initialization, intuition)\n\npprint(resize(40), ll)\n#=>\n(notation,\n nation,\n initialization,\n intuition)\n=#Use parameter prefix to add a prefix to the list.  This is useful for generating functional notation.pprint(resize(30), PPrint.list_layout(ls, prefix=:deinstitutionalization))\n#=>\ndeinstitutionalization(\n    notation,\n    nation,\n    initialization,\n    intuition)\n=#Parameter par specifies the left and the right parentheses.pprint(PPrint.list_layout(ls, par=(\"[\",\"]\")))\n#-> [notation, nation, initialization, intuition]Parameter sep to specifies the separator.pprint(PPrint.list_layout(ls, sep=\" * \"))\n#-> (notation * nation * initialization * intuition)Parameter sep_brk controls the position of separators with respect to line breaks.pprint(resize(40), PPrint.list_layout(ls, sep_brk=:start))\n#=>\n(notation\n , nation\n , initialization\n , intuition)\n=#\n\npprint(resize(40), PPrint.list_layout(ls, sep_brk=:end))\n#=>\n(notation,\n nation,\n initialization,\n intuition)\n=#\n\npprint(resize(40), PPrint.list_layout(ls, sep_brk=:both))\n#=>\n(notation,\n , nation,\n , initialization,\n , intuition)\n=#\n\npprint(resize(40), PPrint.list_layout(ls, sep_brk=:none))\n#=>\n(notation\n nation\n initialization\n intuition)\n=#Parameter tab specifies the indentation level.pprint(resize(30), PPrint.list_layout(ls, prefix=:deinstitutionalization, tab=0))\n#=>\ndeinstitutionalization(\nnotation,\nnation,\ninitialization,\nintuition)\n=#"
},

]}

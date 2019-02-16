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
    "text": "First, import the module.using PPrintUse the function pprint() to print composite data structures formed of nested tuples, vectors, and dictionaries.  The data will be formatted to fit the screen size.To demonstrate how to use pprint(), we create a small dataset of city departments with associated employees.data = [(name = \"POLICE\",\n         employees = [(name = \"JEFFERY A\", position = \"SERGEANT\", salary = 101442, rate = missing),\n                      (name = \"NANCY A\", position = \"POLICE OFFICER\", salary = 80016, rate = missing)]),\n        (name = \"FIRE\",\n         employees = [(name = \"JAMES A\", position = \"FIRE ENGINEER-EMT\", salary = 103350, rate = missing),\n                      (name = \"DANIEL A\", position = \"FIRE FIGHTER-EMT\", salary = 95484, rate = missing)]),\n        (name = \"OEMC\",\n         employees = [(name = \"LAKENYA A\", position = \"CROSSING GUARD\", salary = missing, rate = 17.68),\n                      (name = \"DORIS A\", position = \"CROSSING GUARD\", salary = missing, rate = 19.38)])]The built-in print() function prints this data on a single line, making the output unreadable.print(data)\n#-> NamedTuple{(:name, :employees),T} where T<:Tuple[(name = \"POLICE\", employees = NamedTuple{ … }[ … ]) … ]By contrast, pprint() formats the data to fit the screen size.pprint(data)\n#=>\n[(name = \"POLICE\",\n  employees = [(name = \"JEFFERY A\",\n                position = \"SERGEANT\",\n                salary = 101442,\n                rate = missing),\n               (name = \"NANCY A\",\n                position = \"POLICE OFFICER\",\n                salary = 80016,\n                rate = missing)]),\n (name = \"FIRE\",\n  employees = [(name = \"JAMES A\",\n                position = \"FIRE ENGINEER-EMT\",\n                salary = 103350,\n                rate = missing),\n               (name = \"DANIEL A\",\n                position = \"FIRE FIGHTER-EMT\",\n                salary = 95484,\n                rate = missing)]),\n (name = \"OEMC\",\n  employees = [(name = \"LAKENYA A\",\n                position = \"CROSSING GUARD\",\n                salary = missing,\n                rate = 17.68),\n               (name = \"DORIS A\",\n                position = \"CROSSING GUARD\",\n                salary = missing,\n                rate = 19.38)])]\n=#"
},

{
    "location": "#Layout-expressions-1",
    "page": "Home",
    "title": "Layout expressions",
    "category": "section",
    "text": "PPrint can be extended to format any custom data structure.  To let PPrint format a data structure, we need to encode its possible layouts in the form of a layout expression.A fixed single-line layout is created with PPrint.literal().ll = PPrint.literal(\"salary\")\n#-> literal(\"salary\")Layouts could be combined using horizontal (*) and vertical (/) composition operators.lhz = PPrint.literal(\"salary\") * PPrint.literal(\" = \") * PPrint.literal(\"101442\")\n#-> literal(\"salary\") * literal(\" = \") * literal(\"101442\")\n\nlvt = PPrint.literal(\"salary\") * PPrint.literal(\" =\") /\n      PPrint.indent(4) * PPrint.literal(\"101442\")\n#-> literal(\"salary\") * literal(\" =\") / indent(4) * literal(\"101442\")Here, PPrint.indent(4) is equivalent to PPrint.literal(\" \"^4).Function PPrint.pprint() serializes the layout.pprint(ll)\n#-> salary\n\npprint(lhz)\n#-> salary = 101442\n\npprint(lvt)\n#=>\nsalary =\n    101442\n=#To indicate that we can choose between several different layouts, we use the choice (|) operator.l = lhz | lvt\n#=>\nliteral(\"salary\") * literal(\" = \") * literal(\"101442\") |\nliteral(\"salary\") * literal(\" =\") / indent(4) * literal(\"101442\")\n=#The pretty-printing engine can search through possible layouts to find the best fit, which is expressed as a layout expression without a choice operator.PPrint.best(PPrint.fit(l))\n#-> literal(\"salary\") * (literal(\" = \") * literal(\"101442\"))In addition, PPrint provides functions for generating common layouts.  A delimiter-separated pair can be generated with PPrint.pair_layout().PPrint.pair_layout(PPrint.literal(\"salary\"),\n                   PPrint.literal(\"101442\"),\n                   sep=\" = \")\n#=>\nliteral(\"salary\") * literal(\" = \") * literal(\"101442\") |\nliteral(\"salary\") * literal(\" =\") / (indent(4) * literal(\"101442\"))\n=#A delimiter-separated list of items can be generated with PPrint.list_layout().PPrint.list_layout([PPrint.literal(\"salary = 101442\"),\n                    PPrint.literal(\"rate = missing\")])\n#=>\n(literal(\"(\") | literal(\"(\") / indent(4)) *\n(literal(\"salary = 101442\") * literal(\",\") / literal(\"rate = missing\")) *\nliteral(\")\") |\nliteral(\"(\") *\n(literal(\"salary = 101442\") * literal(\", \") * literal(\"rate = missing\")) *\nliteral(\")\")\n=#"
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
    "text": "We start with creating a simple tree structure.struct Node\n    name::Symbol\n    arms::Vector{Node}\nend\n\nNode(name) = Node(name, [])\n\ntree =\n    Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),\n                           Node(:anchovy),\n                           Node(:antic, [Node(:anticipation)])]),\n               Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),\n               Node(:awl)])\n#-> Node(:a, Main.index.md.Node[ … ])To specify a layout expression for Node objects, we need to override PPrint.tile().  Layout expressions are assembled from PPrint.literal() primitives using operators * (horizontal composition), / (vertical composition), and | (choice).function PPrint.tile(tree::Node)\n    if isempty(tree.arms)\n        return PPrint.literal(\"Node($(repr(tree.name)))\")\n    end\n    arm_lts = [PPrint.tile(arm) for arm in tree.arms]\n    return PPrint.list_layout(arm_lts, prefix=\"Node($(repr(tree.name)), \", par=(\"[\", \"])\"))\nendNow we can use function pprint() to render a nicely formatted representation of the tree.pprint(stdout, tree)\n#=>\nNode(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),\n                     Node(:anchovy),\n                     Node(:antic, [Node(:anticipation)])]),\n          Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),\n          Node(:awl)])\n=#We can control the width of the output.pprint(IOContext(stdout, :displaysize => (24, 60)), tree)\n#=>\nNode(:a, [Node(:an, [Node(:anchor, [Node(:anchorage),\n                                    Node(:anchorite)]),\n                     Node(:anchovy),\n                     Node(:antic, [Node(:anticipation)])]),\n          Node(:arc, [Node(:arch, [Node(:archduke),\n                                   Node(:archer)])]),\n          Node(:awl)])\n=#We can display the layout expression itself, both the original and the optimized variants.PPrint.tile(tree)\n#=>\n(literal(\"Node(:a, [\") | literal(\"Node(:a, [\") / indent(4)) *\n(((literal(\"Node(:an, [\") | literal(\"Node(:an, [\") / indent(4)) *\n  (((literal(\"Node(:anchor, [\") | literal(\"Node(:anchor, [\") / indent(4)) *\n    ⋮\n=#\n\nPPrint.best(PPrint.fit(stdout, PPrint.tile(tree)))\n#=>\nliteral(\"Node(:a, [\") *\n(literal(\"Node(:an, [\") *\n (literal(\"Node(:anchor, [\") *\n  ⋮\n=#For some built-in data structures, automatic layout is already provided.data = [\n    (name = \"RICHARD A\", position = \"FIREFIGHTER\", salary = 90018),\n    (name = \"DEBORAH A\", position = \"POLICE OFFICER\", salary = 86520),\n    (name = \"KATHERINE A\", position = \"PERSONAL COMPUTER OPERATOR II\", salary = 60780)\n]\n\npprint(data)\n#=>\n[(name = \"RICHARD A\", position = \"FIREFIGHTER\", salary = 90018),\n (name = \"DEBORAH A\", position = \"POLICE OFFICER\", salary = 86520),\n (name = \"KATHERINE A\",\n  position = \"PERSONAL COMPUTER OPERATOR II\",\n  salary = 60780)]\n=#"
},

]}

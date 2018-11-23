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
    "text": "Module PPrint implements a pretty-printing engine for visualizing composite data structures.using PPrintTo format a data structure, we need to encode its possible layouts in the form of a layout expression.A fixed single-line layout is created with PPrint.literal().ll = PPrint.literal(\"department\")\n#-> literal(\"department\")PPrint could be combined using horizontal and vertical composition operators.lhz = PPrint.literal(\"department\") * PPrint.literal(\".\") * PPrint.literal(\"name\")\n#-> literal(\"department\") * literal(\".\") * literal(\"name\")\n\nlvt = PPrint.literal(\"department\") / PPrint.literal(\"name\")\n#-> literal(\"department\") / literal(\"name\")Function PPrint.pprint() serializes the layout.pprint(ll)\n#-> department\n\npprint(lhz)\n#-> department.name\n\npprint(lvt)\n#=>\ndepartment\nname\n=#To indicate that we can choose between several different layouts, use the choice operator.l = lhz | lvt\n#=>\nliteral(\"department\") * literal(\".\") * literal(\"name\")\n| literal(\"department\") / literal(\"name\")\n=#The pretty-printing engine can search through possible layouts to find the best fit, which is expressed as a layout expression without a choice operator.PPrint.best(PPrint.fit(l))\n#-> literal(\"department\") * (literal(\".\") * literal(\"name\"))"
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
    "text": "We start with creating a simple tree structure.struct Node\n    name::Symbol\n    arms::Vector{Node}\nend\n\nNode(name) = Node(name, [])\n\ntree =\n    Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),\n                           Node(:anchovy),\n                           Node(:antic, [Node(:anticipation)])]),\n               Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),\n               Node(:awl)])\n#-> Node(:a, Main.index.md.Node[ … ])To specify a layout expression for Node objects, we need to override PPrint.tile().  Layout expressions are assembled from PPrint.literal() primitives using operators * (horizontal composition), / (vertical composition), and | (choice).function PPrint.tile(tree::Node)\n    if isempty(tree.arms)\n        return PPrint.literal(\"Node($(repr(tree.name)))\")\n    end\n    arm_lts = [PPrint.tile(arm) for arm in tree.arms]\n    return PPrint.list_layout(arm_lts, prefix=\"Node($(repr(tree.name)), \", par=(\"[\", \"])\"))\nendNow we can use function pprint() to render a nicely formatted representation of the tree.pprint(stdout, tree)\n#=>\nNode(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),\n                     Node(:anchovy),\n                     Node(:antic, [Node(:anticipation)])]),\n          Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),\n          Node(:awl)])\n=#We can control the width of the output.pprint(IOContext(stdout, :displaysize => (24, 60)), tree)\n#=>\nNode(:a, [Node(:an, [Node(:anchor, [Node(:anchorage),\n                                    Node(:anchorite)]),\n                     Node(:anchovy),\n                     Node(:antic, [Node(:anticipation)])]),\n          Node(:arc, [Node(:arch, [Node(:archduke),\n                                   Node(:archer)])]),\n          Node(:awl)])\n=#We can display the layout expression itself, both the original and the optimized variants.PPrint.tile(tree)\n#=>\n(literal(\"Node(:a, [\") | literal(\"Node(:a, [\") / indent(4))\n* (((literal(\"Node(:an, [\") | literal(\"Node(:an, [\") / indent(4))\n    * (((literal(\"Node(:anchor, [\") | literal(\"Node(:anchor, [\") / indent(4))\n   ⋮\n=#\n\nPPrint.best(PPrint.fit(stdout, PPrint.tile(tree)))\n#=>\nliteral(\"Node(:a, [\")\n* (literal(\"Node(:an, [\")\n   * (literal(\"Node(:anchor, [\")\n   ⋮\n=#For some built-in data structures, automatic layout is already provided.data = [\n    (name = \"RICHARD A\", position = \"FIREFIGHTER\", salary = 90018),\n    (name = \"DEBORAH A\", position = \"POLICE OFFICER\", salary = 86520),\n    (name = \"KATHERINE A\", position = \"PERSONAL COMPUTER OPERATOR II\", salary = 60780)\n]\n\npprint(data)\n#=>\n[(name = \"RICHARD A\", position = \"FIREFIGHTER\", salary = 90018),\n (name = \"DEBORAH A\", position = \"POLICE OFFICER\", salary = 86520),\n (name = \"KATHERINE A\",\n  position = \"PERSONAL COMPUTER OPERATOR II\",\n  salary = 60780)]\n=#"
},

]}

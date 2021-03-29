var documenterSearchIndex = {"docs":
[{"location":"#PrettyPrinting.jl","page":"Home","title":"PrettyPrinting.jl","text":"","category":"section"},{"location":"#Overview","page":"Home","title":"Overview","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"PrettyPrinting is a Julia library for optimal formatting of composite data structures on a fixed-width terminal.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Use the Julia package manager.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using Pkg\njulia> Pkg.add(\"PrettyPrinting\")","category":"page"},{"location":"#Using-PrettyPrinting","page":"Home","title":"Using PrettyPrinting","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"First, import the module.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using PrettyPrinting","category":"page"},{"location":"","page":"Home","title":"Home","text":"Use the function pprint() to print composite data structures formed of nested tuples, vectors, and dictionaries.  The data will be formatted to fit the screen size.","category":"page"},{"location":"","page":"Home","title":"Home","text":"To demonstrate how to use pprint(), we consider a small dataset of city departments with associated employees.","category":"page"},{"location":"","page":"Home","title":"Home","text":"data = [(name = \"POLICE\",\n         employees = [(name = \"JEFFERY A\", position = \"SERGEANT\", salary = 101442, rate = missing),\n                      (name = \"NANCY A\", position = \"POLICE OFFICER\", salary = 80016, rate = missing)]),\n        (name = \"OEMC\",\n         employees = [(name = \"LAKENYA A\", position = \"CROSSING GUARD\", salary = missing, rate = 17.68),\n                      (name = \"DORIS A\", position = \"CROSSING GUARD\", salary = missing, rate = 19.38)])]","category":"page"},{"location":"","page":"Home","title":"Home","text":"The built-in print() function prints this data on a single line, making the output unreadable.","category":"page"},{"location":"","page":"Home","title":"Home","text":"print(data)\n#-> NamedTuple{ … } where T<:Tuple[(name = \"POLICE\", employees = NamedTuple{ … }[ … ]) … ]","category":"page"},{"location":"","page":"Home","title":"Home","text":"By contrast, pprint() formats the data to fit the screen size.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(data)\n#=>\n[(name = \"POLICE\",\n  employees = [(name = \"JEFFERY A\",\n                position = \"SERGEANT\",\n                salary = 101442,\n                rate = missing),\n               (name = \"NANCY A\",\n                position = \"POLICE OFFICER\",\n                salary = 80016,\n                rate = missing)]),\n (name = \"OEMC\",\n  employees = [(name = \"LAKENYA A\",\n                position = \"CROSSING GUARD\",\n                salary = missing,\n                rate = 17.68),\n               (name = \"DORIS A\",\n                position = \"CROSSING GUARD\",\n                salary = missing,\n                rate = 19.38)])]\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"The width of the output is controlled by the displaysize property of the output stream.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(IOContext(stdout, :displaysize => (24, 100)), data)\n#=>\n[(name = \"POLICE\",\n  employees = [(name = \"JEFFERY A\", position = \"SERGEANT\", salary = 101442, rate = missing),\n               (name = \"NANCY A\", position = \"POLICE OFFICER\", salary = 80016, rate = missing)]),\n (name = \"OEMC\",\n  employees = [(name = \"LAKENYA A\", position = \"CROSSING GUARD\", salary = missing, rate = 17.68),\n               (name = \"DORIS A\", position = \"CROSSING GUARD\", salary = missing, rate = 19.38)])]\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you want to add a newline after the output, use the function pprintln().","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprintln(data[1])\npprintln(data[2])\n#=>\n(name = \"POLICE\",\n employees = [(name = \"JEFFERY A\",\n               position = \"SERGEANT\",\n               salary = 101442,\n               rate = missing),\n              (name = \"NANCY A\",\n               position = \"POLICE OFFICER\",\n               salary = 80016,\n               rate = missing)])\n(name = \"OEMC\",\n employees = [(name = \"LAKENYA A\",\n               position = \"CROSSING GUARD\",\n               salary = missing,\n               rate = 17.68),\n              (name = \"DORIS A\",\n               position = \"CROSSING GUARD\",\n               salary = missing,\n               rate = 19.38)])\n=#","category":"page"},{"location":"#Layout-expressions","page":"Home","title":"Layout expressions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"PrettyPrinting can be extended to format any custom data structure.  To let PrettyPrinting format a data structure, we need to encode its possible layouts in the form of a layout expression.","category":"page"},{"location":"","page":"Home","title":"Home","text":"We will use the following definitions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using PrettyPrinting:\n    best_fit,\n    indent,\n    list_layout,\n    literal,\n    pair_layout","category":"page"},{"location":"","page":"Home","title":"Home","text":"A fixed single-line layout is created with literal().","category":"page"},{"location":"","page":"Home","title":"Home","text":"ll = literal(\"salary\")\n#-> literal(\"salary\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Layouts could be combined using horizontal (*) and vertical (/) composition operators.","category":"page"},{"location":"","page":"Home","title":"Home","text":"lhz = literal(\"salary\") * literal(\" = \") * literal(\"101442\")\n#-> literal(\"salary\") * literal(\" = \") * literal(\"101442\")\n\nlvt = literal(\"salary\") * literal(\" =\") /\n      indent(4) * literal(\"101442\")\n#-> literal(\"salary\") * literal(\" =\") / indent(4) * literal(\"101442\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"Here, indent(4) is equivalent to literal(\" \"^4).","category":"page"},{"location":"","page":"Home","title":"Home","text":"Function pprint() serializes the layout.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(ll)\n#-> salary\n\npprint(lhz)\n#-> salary = 101442\n\npprint(lvt)\n#=>\nsalary =\n    101442\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"To indicate that we can choose between several different layouts, we use the choice (|) operator.","category":"page"},{"location":"","page":"Home","title":"Home","text":"l = lhz | lvt\n#=>\nliteral(\"salary\") * literal(\" = \") * literal(\"101442\") |\nliteral(\"salary\") * literal(\" =\") / indent(4) * literal(\"101442\")\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"The pretty-printing engine can search through possible layouts to find the best fit, which is expressed as a layout expression without a choice operator.","category":"page"},{"location":"","page":"Home","title":"Home","text":"best_fit(l)\n#-> literal(\"salary\") * (literal(\" = \") * literal(\"101442\"))","category":"page"},{"location":"","page":"Home","title":"Home","text":"In addition, PrettyPrinting can generate some common layouts.  A delimiter-separated pair can be generated with pair_layout().","category":"page"},{"location":"","page":"Home","title":"Home","text":"pair_layout(literal(\"salary\"), literal(\"101442\"), sep=\" = \")\n#=>\n(literal(\"salary\") * literal(\" = \") |\n literal(\"salary\") * literal(\" =\") / indent(4)) *\nliteral(\"101442\")\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"A delimiter-separated list of items can be generated with list_layout().","category":"page"},{"location":"","page":"Home","title":"Home","text":"list_layout([literal(\"salary = 101442\"), literal(\"rate = missing\")])\n#=>\n(literal(\"(\") | literal(\"(\") / indent(4)) *\n(literal(\"salary = 101442\") * literal(\",\") / literal(\"rate = missing\")) *\nliteral(\")\") |\nliteral(\"(\") *\n(literal(\"salary = 101442\") * literal(\", \") * literal(\"rate = missing\")) *\nliteral(\")\")\n=#","category":"page"},{"location":"#Extending-PrettyPrinting","page":"Home","title":"Extending PrettyPrinting","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We can make pprint() format objects of user-defined types.  For this purpose, we must implement the function tile(), which should map an object to its layout expression.","category":"page"},{"location":"","page":"Home","title":"Home","text":"For example, consider a simple tree structure.","category":"page"},{"location":"","page":"Home","title":"Home","text":"struct Node\n    name::Symbol\n    arms::Vector{Node}\nend\n\nNode(name) = Node(name, [])\n\ntree =\n    Node(:a, [Node(:an, [Node(:anchor, [Node(:anchorage),\n                                        Node(:anchorite)]),\n                         Node(:anchovy),\n                         Node(:antic, [Node(:anticipation)])]),\n              Node(:arc, [Node(:arch, [Node(:archduke),\n                                       Node(:archer)])]),\n              Node(:awl)])\n#-> Node(:a, DocSrcIndexMd.Node[ … ])","category":"page"},{"location":"","page":"Home","title":"Home","text":"To make pprint() format this tree, we must implement the function tile(::Node).  A suitable layout expression for this tree could be generated with list_layout().","category":"page"},{"location":"","page":"Home","title":"Home","text":"import PrettyPrinting:\n    tile\n\nfunction tile(tree::Node)\n    if isempty(tree.arms)\n        return literal(\"Node($(repr(tree.name)))\")\n    end\n    return list_layout(tile.(tree.arms),\n                       prefix=\"Node($(repr(tree.name)), \", par=(\"[\", \"])\"))\nend","category":"page"},{"location":"","page":"Home","title":"Home","text":"Now pprint() renders a nicely formatted representation of the tree.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(stdout, tree)\n#=>\nNode(:a, [Node(:an, [Node(:anchor, [Node(:anchorage), Node(:anchorite)]),\n                     Node(:anchovy),\n                     Node(:antic, [Node(:anticipation)])]),\n          Node(:arc, [Node(:arch, [Node(:archduke), Node(:archer)])]),\n          Node(:awl)])\n=#","category":"page"},{"location":"#Acknowledgements","page":"Home","title":"Acknowledgements","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The algorithm for finding the optimal layout is based upon Phillip Yelland, A New Approach to Optimal Code Formatting, 2016.","category":"page"},{"location":"#API-Reference","page":"Home","title":"API Reference","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"PrettyPrinting.pprint\nPrettyPrinting.pprintln","category":"page"},{"location":"#PrettyPrinting.pprint","page":"Home","title":"PrettyPrinting.pprint","text":"pprint([io::IO], data)\n\nDisplays the data so that it fits the width of the output screen.\n\n\n\n\n\n","category":"function"},{"location":"#PrettyPrinting.pprintln","page":"Home","title":"PrettyPrinting.pprintln","text":"pprintln([io::IO], data)\n\nDisplays the data using pprint and adds a newline.\n\n\n\n\n\n","category":"function"},{"location":"#Test-Suite","page":"Home","title":"Test Suite","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The following function overrides the width of the output terminal.","category":"page"},{"location":"","page":"Home","title":"Home","text":"resize(w) = IOContext(stdout, :displaysize => (24, w))","category":"page"},{"location":"#Formatting-built-in-data-structures","page":"Home","title":"Formatting built-in data structures","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The function pprint() supports many built-in data structures.","category":"page"},{"location":"","page":"Home","title":"Home","text":"In particular, pprint() can format Pair objects.","category":"page"},{"location":"","page":"Home","title":"Home","text":"p = :deinstitutionalization => :counterrevolutionaries\n\npprint(p)\n#-> :deinstitutionalization => :counterrevolutionaries\n\npprint(resize(40), p)\n#=>\n:deinstitutionalization =>\n    :counterrevolutionaries\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(::Pair) can handle composite keys and values.","category":"page"},{"location":"","page":"Home","title":"Home","text":"p = :deinstitutionalization => [:notation, :nation, :initialization, :intuition]\n\npprint(p)\n#-> :deinstitutionalization => [:notation, :nation, :initialization, :intuition]\n\npprint(resize(60), p)\n#=>\n:deinstitutionalization =>\n    [:notation, :nation, :initialization, :intuition]\n=#\n\npprint(resize(50), p)\n#=>\n:deinstitutionalization => [:notation,\n                            :nation,\n                            :initialization,\n                            :intuition]\n=#\n\npprint(resize(40), p)\n#=>\n:deinstitutionalization =>\n    [:notation,\n     :nation,\n     :initialization,\n     :intuition]\n=#\n\np = [:orientation, :interculture, :translucent] => :counterrevolutionaries\n\npprint(p)\n#-> [:orientation, :interculture, :translucent] => :counterrevolutionaries\n\npprint(resize(60), p)\n#=>\n[:orientation, :interculture, :translucent] =>\n    :counterrevolutionaries\n=#\n\npprint(resize(40), p)\n#=>\n[:orientation,\n :interculture,\n :translucent] =>\n    :counterrevolutionaries\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint() can also format tuples and vectors.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(())\n#-> ()\n\npprint([])\n#-> []\n\npprint((:deinstitutionalization,))\n#-> (:deinstitutionalization,)\n\npprint([:deinstitutionalization])\n#-> [:deinstitutionalization]\n\nt = (:notation, :nation, :initialization, :intuition)\n\npprint(t)\n#-> (:notation, :nation, :initialization, :intuition)\n\npprint(collect(t))\n#-> [:notation, :nation, :initialization, :intuition]\n\npprint(resize(40), t)\n#=>\n(:notation,\n :nation,\n :initialization,\n :intuition)\n=#\n\npprint(resize(40), collect(t))\n#=>\n[:notation,\n :nation,\n :initialization,\n :intuition]\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"Finally, pprint() is implemented for sets, dictionaries and named tuples.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(Dict())\n#-> Dict()\n\npprint(Set())\n#-> Set()\n\npprint((deinstitutionalization = :counterrevolutionaries,))\n#-> (deinstitutionalization = :counterrevolutionaries,)\n\npprint(Dict(:deinstitutionalization => :counterrevolutionaries))\n#-> Dict(:deinstitutionalization => :counterrevolutionaries)\n\npprint(Set([:deinstitutionalization]))\n#-> Set([:deinstitutionalization])\n\nnt = (deinstitutionalization = [:notation, :nation, :initialization, :intuition],\n      counterrevolutionaries = [:orientation, :interculture, :translucent])\n\npprint(nt)\n#=>\n(deinstitutionalization = [:notation, :nation, :initialization, :intuition],\n counterrevolutionaries = [:orientation, :interculture, :translucent])\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"The following test has to be skipped because the order of entries in a dictionary is unstable.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(Dict(pairs(nt)))\n#=>\nDict(:deinstitutionalization =>\n         [:notation, :nation, :initialization, :intuition],\n     :counterrevolutionaries => [:orientation, :interculture, :translucent])\n=#\n\npprint(Set([:deinstitutionalization, :counterrevolutionaries]))\n#-> Set([:deinstitutionalization, :counterrevolutionaries])","category":"page"},{"location":"#Using-pair_layout()","page":"Home","title":"Using pair_layout()","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Function pair_layout() generates a layout expression for Pair-like objects.","category":"page"},{"location":"","page":"Home","title":"Home","text":"kl = literal(:deinstitutionalization)\nvl = literal(:counterrevolutionaries)\n\npl = pair_layout(kl, vl)\n\npprint(pl)\n#-> deinstitutionalization => counterrevolutionaries\n\npprint(resize(40), pl)\n#=>\ndeinstitutionalization =>\n    counterrevolutionaries\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"Use parameter sep to change the separator.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(pair_layout(kl, vl, sep=\" -> \"))\n#-> deinstitutionalization -> counterrevolutionaries","category":"page"},{"location":"","page":"Home","title":"Home","text":"Parameter sep_brk controls the position of the separator with respect to the line break.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(resize(40), pair_layout(kl, vl, sep_brk=:start))\n#=>\ndeinstitutionalization\n    => counterrevolutionaries\n=#\n\npprint(resize(40), pair_layout(kl, vl, sep_brk=:end))\n#=>\ndeinstitutionalization =>\n    counterrevolutionaries\n=#\n\npprint(resize(40), pair_layout(kl, vl, sep_brk=:both))\n#=>\ndeinstitutionalization =>\n    => counterrevolutionaries\n=#\n\npprint(resize(40), pair_layout(kl, vl, sep_brk=:none))\n#=>\ndeinstitutionalization\n    counterrevolutionaries\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"Parameter tab specifies the indentation level.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(resize(40), pair_layout(kl, vl, tab=0))\n#=>\ndeinstitutionalization =>\ncounterrevolutionaries\n=#","category":"page"},{"location":"#Using-list_layout()","page":"Home","title":"Using list_layout()","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Function list_layout() generates a layout expression for list-like objects.","category":"page"},{"location":"","page":"Home","title":"Home","text":"ls = literal.([:notation, :nation, :initialization, :intuition])\n\nll = list_layout(ls)\n\npprint(ll)\n#-> (notation, nation, initialization, intuition)\n\npprint(resize(40), ll)\n#=>\n(notation,\n nation,\n initialization,\n intuition)\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"Use parameter prefix to add a prefix to the list.  This is useful for generating functional notation.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(resize(30), list_layout(ls, prefix=:deinstitutionalization))\n#=>\ndeinstitutionalization(\n    notation,\n    nation,\n    initialization,\n    intuition)\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"Parameter par specifies the left and the right parentheses.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(list_layout(ls, par=(\"[\",\"]\")))\n#-> [notation, nation, initialization, intuition]","category":"page"},{"location":"","page":"Home","title":"Home","text":"Parameter sep to specifies the separator.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(list_layout(ls, sep=\" * \"))\n#-> (notation * nation * initialization * intuition)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Parameter sep_brk controls the position of separators with respect to line breaks.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(resize(40), list_layout(ls, sep_brk=:start))\n#=>\n(notation\n , nation\n , initialization\n , intuition)\n=#\n\npprint(resize(40), list_layout(ls, sep_brk=:end))\n#=>\n(notation,\n nation,\n initialization,\n intuition)\n=#\n\npprint(resize(40), list_layout(ls, sep_brk=:both))\n#=>\n(notation,\n , nation,\n , initialization,\n , intuition)\n=#\n\npprint(resize(40), list_layout(ls, sep_brk=:none))\n#=>\n(notation\n nation\n initialization\n intuition)\n=#","category":"page"},{"location":"","page":"Home","title":"Home","text":"Parameter tab specifies the indentation level.","category":"page"},{"location":"","page":"Home","title":"Home","text":"pprint(resize(30), list_layout(ls, prefix=:deinstitutionalization, tab=0))\n#=>\ndeinstitutionalization(\nnotation,\nnation,\ninitialization,\nintuition)\n=#","category":"page"}]
}

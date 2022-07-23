class Transpiler
    def initialize(tree)
        @tree = tree
    end

    def transpile
        f(@tree)
    end

    def f(node)
        case node["type"]
        when "program"
            node["program"].map{|expr| f(expr) }.join("\n")
        when "identifier"
            node["value"]
        when "method"
            "%s.%s(%s)" % [
                f(node["self"]),
                node["name"],
                node["args"].map{|x| f(x) }.join(", ")
            ]
        when "dot_identifier"
            method_name = node["name"]
            arguments = node["args"].map{|x| f(x) }
            self_name = rand_name()
            res = "lambda{ | %s | %s.%s(%s) }" % [self_name, self_name, method_name, arguments.join(", ")]
            res = "&" + res if node["as_arg"]
            res
        when "int", "float"
            node["value"]
        when "literal"
            f node["value"]
        when "array"
            "[#{node["value"].map{|x| f x }.join(", ")}]"
        when "assignment"
            p ["ass",node]
            f(node["left"]) + " = " + f(node["right"])
        when "nil"
            ""
        when "binary_operation"
            "(" + f(node["left"]) + " " + node["operator"] + " " + f(node["right"]) + ")"
        when "call"
            f(node["func"]) + "(" + node["args"].map{|x| f x }.join(", ") + ")"
        when "string"; "\"#{node["value"]}\""
        when "string_interpolate_start"; "\"#{node["value"]}#\{"
        when "string_interpolate_middle"; "}#{node["value"]}#\{"
        when "string_interpolate_end"; "}#{node["value"]}\""
        else
            p node
            "no"
        end
    end

    def rand_name
        "var_" + 20.times.map{rand 10}.join
    end
end



# {
#     "type"=>"program",
#     "program"=>[
#         {
#             "type"=>"method",
#             "self"=>{"type"=>"identifier", "value"=>"a"}, "na
# me"=>"map", "args"=>[{"type"=>"dot_identifier", :n
# ame=>"to_s", :args=>[{"type"=>"literal", "value"=>
# {"type"=>"int", "value"=>"16"}}]}]}]}

# sum not string
# somewhere I use : instead of =>
# # from that vv
# code = "a.map(.to_i(2))"
# # lets put it all together main.rb
# # a.map(&lambda{ | var_69690452667024246038 | var_69690452667024246038..to_i(2) })
# tree = {
#     "type": "program",
#     "program": [
#       {
#         "type": "method",
#         "self": {
#           "type": "identifier",
#           "value": "a"
#         },
#         "name": "map",
#         "args": [
#           {
#             "type": "dot_identifier",
#             "name": "to_i",
#             "args": [
#               {
#                 "type": "literal",
#                 "value": {
#                   "type": "int",
#                   "value": "2"
#                 }
#               }
#             ]
#           }
#         ]
#       }
#     ]
#   }

# f = -> h {
#     Hash === h ? h.transform_keys(&:to_s).transform_values(&f) : Array === h ? h.map(&f) : h
# }

# tree = f.(tree)

# transpiler = Transpiler.new tree

# puts transpiler.transpile
class Transpiler
    def initialize(tree)
        @tree = tree
    end

    def transpile
        f(@tree)
    end

    def f(node)
        type = node["type"]
        value = node["value"]
        case type
        when "program"
            node["program"].map{|expr| f(expr) }.join("\n")
        when "identifier"
            value
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
            "lambda{ | %s | %s.%s(%s) }" % [self_name, self_name, method_name, arguments.join(", ")]
        when "int", "float"
            value
        when "literal"
            f value
        when "array"
            "[#{value.map{|x| f x }.join(", ")}]"
        when "assignment"
            f(node["left"]) + " = " + f(node["right"])
        when "nil"
            ""
        when "binary_operation"
            "(" + f(node["left"]) + " " + node["operator"] + " " + f(node["right"]) + ")"
        when "call"
            if node["args"].empty? && !node["parens"]
                return f(node["func"]) + ".try_call(" + node["args"].map{|x| f x }.join(", ") + ")"
            end
            f(node["func"]) + ".call(" + node["args"].map{|x| f x }.join(", ") + ")"
        when "string"; "\"#{value}\""
        when "string_interpolate_start"; "\"#{value}#\{"
        when "string_interpolate_middle"; "}#{value}#\{"
        when "string_interpolate_end"; "}#{value}\""
        when "prefix"
            if %w"++ --".include?(node["operator"])
                operand = f(node["right"])
                return "(#{operand} #{node["operator"] == "++" ? "+" : "-"}= 1)"
            end
            "(#{node["operator"]} #{f(node["right"])})"
        when "postfix"
            if %w"++ --".include?(node["operator"])
                operand = f(node["left"])
                op = node["operator"] == "++" ? "+" : "-"
                return "((#{operand} #{op}= 1) #{op} -1)"
            end
            "<postfix>"
        when "amp_identifier"
            value
        when "amp_method"
            args = node["args"]
            if args.nil?
                return "%s.method(\"%s\")" % [
                    f(node["self"]),
                    node["name"]
                ]
            end
            "%s.%s(%s)" % [
                f(node["self"]),
                node["name"],
                node["args"].map{|x| f(x) }.join(", ")
            ]
        when "special_dollar"
            value
        when "func"
            args = node["args"].map{|x|f x}.join(", ")
            argc = node["args"].size
            var = rand_name()
            return "lambda{|*#{var}| #{f(node["body"])} }" if argc == 0
            return "lambda{|#{args}| #{f(node["body"])} }" if argc == 1
            "lambda{|*#{var}| #{args} = #{var}; #{f(node["body"])} }"
        # when "func"
        #     # "|%s|%s" % [node["args"].map{|x|f x}.join(", "), f(node["body"])]
        #     args = node["args"]
        #     p args
        #     if args.empty?
        #         return "lambda{%s}" % f(node["body"])
        #     end
        #     "lambda{|%s|%s}" % [args.map{|x|f x}.join(", "), f(node["body"])]
        else
            puts "can't stringify"
            p node
            p "no"
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
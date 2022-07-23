PRECEDENCE = {
    "=": 2,
    "||": 4,
    "?": 3,
    ":": 3,
    "&&": 5,
    "<": 10, ">": 10, "<=": 10, ">=": 10,
    "==": 9, "!=": 9,
    "+": 12, "-": 12,
    "*": 13, "/": 13, "%": 13,
}
PRECEDENCE.transform_keys!(&:to_s)

class Parser
    def initialize(tokens)
        @tokens = tokens
    end

    def parse
        @tokens
        parsed = []
        while @tokens.size > 0
            p "trying to parse next expr:"
            expression = parseExpression()
            p "expression:"
            p expression
            parsed << expression
        end
        return {"type" => "program", "program" => parsed}
    end
    def next_token()
        @tokens[0] && @tokens.shift()
    end

    def parseExpression() 
        expression = parseAtom()
        p ["expr moment", expression]
        expression = maybe_call(expression)
        expression = maybe_method(expression)
        expression = maybe_binary(expression, 0)  #this hsould eat = this fails
        p "expr: #{expression}"
        return expression
    end
    def parseAtom()
        return {"type"=> "nil"} if @tokens.size == 0 
        
        first = @tokens[0]
        p ["in parse atom", first ]# ["identifier", "a"]
        #input is array, not hash
        # ok
        type = first["type"]
        puts "first: #{first}"
        puts "type: #{type}"
        if type == "left_paren"
            next_token()
            expression = parseExpression()
            skipNextType("right_paren")
            return expression
        end
        
        if type =~ /(int|float|string|bool|nil)/
            next_token()
            return {
                "type" => "literal",
                "value" => first
            }
        end
        if type == "dot_identifier"
            skipNextType("dot_identifier")
            args = parse_args(first)["args"]
            p args
            return {
                "type" => "dot_identifier",
                "name" => first["value"],
                "args" => args
            }
        end
        if type == "identifier"
            p "it's identifier!"
            skipNextType("identifier")
            return first
        end
        if type == "whitespace"
            next_token()
            return parseAtom()
        end
        if first["value"] == "[" 
            values = delimited("[", "]", [","], method(:parseExpression))
            p "values:"
            p values
            return {
                "type" => "array",
                "value" => values
            }
        end
        if type =~ /comment/
            next_token() # no next? we probably don't need to save the comments lol
            return parseAtom()
        end
# I lost access to terminla  works! lets fix transpiler

        puts("didn't parse:")
        puts(first)
        throw "Didn't parse an atom"
    
    end
    
    def skipNextType(type)
        if @tokens[0]&.[]("type") == type
            return @tokens[0] && @tokens.shift()
        end
        p type
        throw "Invalid token to skip"
    end
    
    def skipNextValue(value)
        if @tokens[0]&.[]("value") == value
            return @tokens[0] && @tokens.shift()
        end
        throw "Invalid value to skip"
    end

    def isNextType(type)
        return @tokens[0]&.[]("type") == type
    end

    def isNextValue(value)
        return @tokens[0]&.[]("value") == value
    end
    
    def delimited(start, eend, (separator_value, separator_type), parser_func)
        parsed = []
        first_iteration = true
        skipNextValue(start) if start
        
        while @tokens.length > 0
            skipAllSpace()
            break if Array === eend ? eend.any?{|x| isNextValue(x)} : isNextValue(eend)
            
            if(first_iteration)
                first_iteration = false
            else
                # sep_value is prio
                # doesn't reach
                p ["is next val", separator_value, isNextValue(separator_value)]
                if(separator_value && isNextValue(separator_value)) # where is this false
                    # nil is false i think if it's false that won't run
                    # nil is just false in ruby
                    puts("skipping next '#{separator_value}'")
                    skipNextValue(separator_value)
                else
                    puts("skipping next '#{separator_type}'")
                    puts(separator_value)
                    skipNextType(separator_type) # skip nil?
                end
            end
            

            break if Array === eend ? eend.any?{|x| isNextValue(x)} : isNextValue(eend)
            expression = parser_func.()
            parsed.push(expression)
        
        end
    
        skipNextValue(eend)
        return parsed
    end
    
    def skipAllSpace()
        skipNextType("whitespace") while isNextType("whitespace")
    end

    def maybe_binary(left, precedence)
        # ignore space
        skipNextType("whitespace") while isNextType("whitespace")
        is_operator = isNextType("operator") && !isNextValue(",") #master bug remover large brain comment errors now lol smh
        operator = @tokens[0]

        p ["in maybe binary is operator?", is_operator]
        if(is_operator)
            p operator["value"]
            other_precedence = PRECEDENCE[operator["value"]]
            # comma isn't operator right? it's syntax
            # you didn't pass in the type for the separator
            # maybe that mess it up
            if(other_precedence > precedence)
                if(operator["value"] == "?")
                    condition = left
                    skipNextValue("?")
                    truthy = parseExpression()
                    skipNextValue(":")
                    falsy = parseExpression()
                    return {
                        "type" => "ternary",
                        "condition" => condition,
                        "truthy" => truthy,
                        "falsy" => falsy
                    }

                end
                return left if(operator["value"] == ":")

                skipNextType("operator")
                atom = parseAtom()
                right = maybe_call(maybe_binary(atom, other_precedence))
                binary = {
                    "type" => "binary_operation",
                    "operator" => operator["value"],
                    "left" => left,
                    "right" => right
                }
                binary["type"] = "assignment" if operator["value"] == "="
                return maybe_binary(binary, precedence)
            end
        end

        return left
    end
    
    def maybe_call(expression)
        # return isNextType("left_paren") ? parse_call(expression) : expression
        if isNextType("left_paren") 
            return parse_call(expression)
        else
            skipNextType("whitespace") while isNextType("whitespace")
            if isNextType("identifier") || isNextType("literal")
                # but not delimited this time
                # hm is the end symbol always [\n;] ?
                # then we have to replace ; with \n or not
                # we can add manually
                #not var, Class Class === var ) == ( var instanceof class)
                # o ok
                # you can do
                # case "ASD" when String # because case uses ===

                args = delimited(nil, ["\n", ";"], [","], method(:parseExpression))
                return {
                    "type" => "call",
                    "func" => func,
                    "args" => args
                }
            end       
        end
    end
    
    def parse_call(func)
        args = delimited("(", ")", [","], method(:parseExpression))
        return {
            "type" => "call",
            "func" => func,
            "args" => args,
        }
    end
    def maybe_method(expression)
        return isNextType("dot") ? parse_method(expression) : expression
    end
    def parse_method(func)
        skipNextType("dot")
        # p @tokens[0]
        throw "method name is not a valid name lol" unless isNextType("identifier")
        name = next_token()
        return {
            "type" => "method",
            "self" => func,
            "name" => name["value"],
            "args" => parse_args({
                "type" => "method",
                "self" => func,
                "name" => name
            })["args"]
        }
    end
    def parse_args(func)
        if isNextType("left_paren")
            return parse_call(func)
        else
            return {
                "type" => "call",
                "func" => func,
                "args" => []
            }
        end
    end
end

# tokens = 
# [
    
#     # ["identifier", "f"],
#     # ["left_paren", "("],
#     # ["right_paren", ")"],
#     # ["identifier", "a"],
#     # ["dot", "."],
#     # ["identifier", "map"],
#     # ["left_paren", "("],
#     # ["dot_identifier", ".to_i"],
#     # ["left_paren", "("],
#     # ["int", "2"],
#     # ["right_paren", ")"],
#     # ["right_paren", ")"]
# ].map{|k,v|
#     {"type" => k, "value" => v}
# }

# # code = "a.map(.to_i(2))"
# code = "f()"

# parser = Parser.new tokens

# parsed = parser.parse

# require "json"
# puts JSON.pretty_generate parsed

# do you somewhat get how that^^^ works?
# mainly maybe_...()
# yeah
#I want to transpile that v to ruby again
# alright
# can you find anything else that needs anything
# I don't think this parser will work for the samples we have, ...yet
# {
#     "type": "method",
#     "self": {
#         "type": "identifier",
#         "value": "a"
#     },
#     "name": {
#         "type": "identifier",
#         "value": "map"
#     },
#     "args": [
#         {
#             "type": "dot_identifier",
#             "args": [
#                 {
#                     "type": "literal",
#                     "value": {
#                         "type": "int",
#                         "value": "2"
#                     }
#                 }
#             ]
#         }
#     ]
# }

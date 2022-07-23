PRECEDENCE = {
    "="=> 2,
    "||"=> 4,
    "?"=> 3,
    "=>"=> 3,
    "&&"=> 5,
    "<"=> 10, ">"=> 10, "<="=> 10, ">="=> 10,
    "=="=> 9, "!="=> 9,
    "+"=> 12, "-"=> 12,
    "*"=> 13, "/"=> 13, "%"=> 13,
}


class Parser
    def initialize(tokens)
        @tokens = tokens.select{|x| x["type"] != "comment_single"}
    end

    def parse
        @tokens
        parsed = []
        while @tokens.size > 0
            # p "trying to parse next expr:"
            expression = parseExpression()
            # p "expression:"
            # p expression
            parsed << expression
        end
        return {"type" => "program", "program" => parsed}
    end
    def next_token()
        @tokens[0] && @tokens.shift()
    end

    def parseExpression(as_arg = false) 
        expression = parseAtom(as_arg)
        # expression = parse_args_no_paren(expression)
        p ["expr parseatom", expression]
        expression = maybe_call(expression, call_need_parens(expression))
        p ["expr maybecall", expression, call_need_parens(expression)]
        expression = maybe_method(expression)
        p ["expr maybemethod", expression]
        expression = maybe_binary(expression, 0)  #this hsould eat = this fails
        p ["expr binary", expression]
        # p "expr: #{expression}"
        return expression
        # call is making them all nil
    end
    def parseAtom(as_arg = false)
        return {"type"=> "nil"} if @tokens.size == 0 
        
        first = @tokens[0]
        # p ["in parse atom", first ]# ["identifier", "a"]
        #input is array, not hash
        # ok
        type = first["type"]
        puts "first: #{first}"
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
            return {
                "type" => "dot_identifier",
                "name" => first["value"],
                "args" => args,
                "as_arg" => as_arg
            }
        end
        if type == "identifier"
            skipNextType("identifier")
            return first
        end
        if type == "whitespace"
            next_token()
            return parseAtom()
        end
        if first["value"] == "[" 
            values = delimited("[", "]", [","], method(:parseExpression))
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
            p ["curr parsed", parsed, @tokens[0]]
            # skipAllSpace() # here ofc
            break if String === eend ? isNextValue(eend) : @tokens[0]["value"] =~ eend #this should stop v
            
            if(first_iteration)
                first_iteration = false
            else
                # it trying to delimit the comment? idk
                # now it says it collected /demilited "a", but then keeps looking, doesn't see newline
                 p ["is next val", separator_value, isNextValue(separator_value)]
                p ["real next val", @tokens[0]]
                if(separator_value && isNextValue(separator_value)) # where is this false  #this from being false ri ght?
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
            
            # I think isNextValue() here it is exact, but the token is any whitespace
            # break if Array === eend ? eend.any?{|x| isNextValue(x)} : isNextValue(eend) #check here no need to check down there
            break if String === eend ? isNextValue(eend) : @tokens[0]["value"] =~ eend #check here no need to check down there
            #  method(:parseExpression) f[] === f.() === f.call()
            expression = parser_func.()
            # break unless expression
            parsed.push(expression)
        
        end
        # think it's that nil you passed earlier to delimited no, that was start
        
    
        # skipNextValue(eend)
        next_token()
        return parsed
    end
    
    def skipAllSpace()
        skipNextType("whitespace") while isNextType("whitespace")
    end
    def skipAllHoriSpace()
        skipped = false
        (skipped = true; skipNextType("whitespace")) while isNextType("whitespace") && !(@tokens[0]["value"] =~ /\n/)
        skipped
    end

    def maybe_binary(left, precedence)
        # ignore space
        skipNextType("whitespace") while isNextType("whitespace")
        is_operator = isNextType("operator") && !isNextValue(",") #master bug remover large brain comment errors now lol smh
        operator = @tokens[0]

        # p ["in maybe binary is operator?", is_operator]
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
                right = maybe_binary(atom, other_precedence)
                right = maybe_call(right, true)
                right = maybe_method(right)
                # CHEEEEEEEEEEEEEEEEEEEEESE 1 10001 11!!!!!
                # I didn't think we had to parse this much, ah well
                # it's ok you sound like ...
                # :)
                # ok i go now i come back tomorrow 5:43 am, it's already tomorrow
                # lol
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
    
    def isLiteral(expr)
        case expr
        when "int", "float", /string/; true
        else; false
        end 
    end

    def maybe_call(expression, parens_needed = true)
        
        if isNextType("left_paren") 
            ret = parse_call(expression)
            p "ret from maybe_call with parens: #{ret}"
            return ret
        elsif !parens_needed
            skipped_space = skipAllHoriSpace()
            if expression["type"] == "identifier" && @tokens[0]["type"] != "operator" && @tokens[0]["value"] !~ /[\n;\.]/
                return parse_args_no_paren(expression)
            else
                return expression
            end
                did_skip_newline = false
            (did_skip_newline ||= @tokens[0]["value"] =~ /\n/; skipNextType("whitespace")) while isNextType("whitespace")
            
            p ["in maybe call check token 0", @tokens[0]]
            # expression is kinda @tokens[-1] (previous head)
            if expression["type"] == "identifier" && !did_skip_newline && (isNextType("identifier") || isNextType("literal")) # what?? next type is dot wait
                puts "function without parens named: #{expression["value"]}"
                # aaaaaaa
                # I think it works now, new error
                # check for nil?
                # puts "monoid in a category of endofunctors #"
                # name = next_token() # 
                # p name
                # p @tokens[0,2]
                
                # but not delimited this time
                # hm is the end symbol always [\n;] ?
                # then we have to replace ; with \n or not
                # we can add manually
                #not var, Class Class === var ) == ( var instanceof class)
                # o ok
                # you can do
                # case "ASD" when String # because case uses ===

                args = delimited(nil, /[\n;]/, [","], method(:parseExpression))
                ret = {
                    "type" => "call",
                    "func" => expression,
                    "args" => args
                }
                p "ret from maybe_call no parens: #{ret}"
                return ret
            end       
        end
        p "ret from maybe_call no call: #{expression}"
        return expression

    end
    def call_need_parens(expr)
        puts "need parens?"
        p expr
        res = case expr["type"]
            when "identifier"; false
            else; true
        end
        p res
        return res
    end
    
    def parse_call(func)
        # args = delimited("(", ")", [","], method(:parseExpression))
        args = delimited("(", ")", [","], lambda{parseExpression(true)})
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
            "args" => isNextType("left_paren") ? parse_args({
                "type" => "method",
                "self" => func,
                "name" => name
            })["args"] : parse_args_no_paren({
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
    def parse_args_no_paren(func)
        puts "parsing name #{func} args, no parens"
        args = []
        loop do
            if (isNextType("whiteSpace") && @tokens[0]["value"] =~ /\n/) || isNextValue(";") || isNextValue(".")
                return {
                    "type" => "call",
                    "func" => func,
                    "args" => args
                }
            end
            if isNextType("whiteSpace")
                next_token()
                next
            end
            expr = parseExpression(true)
            args << expr
            puts "parsed no-paren arg: #{expr}"
            skipAllHoriSpace()
            if isNextValue(",")
                next_token()
            else
                return {
                    "type" => "call",
                    "func" => func,
                    "args" => args
                }
            end

        end

        # delimited(nil, /[\n;]/, [","], method(:parseExpression))
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

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
    "++"=> 14, "--"=> 14,
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
        p "expr: #{expression}"
        return expression
        # call is making them all nil
    end
    def parseAtom(as_arg = false)
        return {"type"=> "nil"} if @tokens.size == 0 
        
        first = @tokens[0]
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
            next_token()
            return parseAtom()
        end
        if type == "newline" || type == "semicolon"
            next_token()
            return parseAtom()
        end 
        if type == "operator"
            puts "prefix"
            next_token()
            return {
                "type" => "prefix",
                "operator" => first["value"],
                "right" => parseAtom()
            }
        end
        if type == "amp_identifier"
            next_token()
            return first
        end
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
            # p ["curr parsed", parsed, @tokens[0]]
            # skipAllSpace() # here ofc
            break if String === eend ? isNextValue(eend) : @tokens[0]["value"] =~ eend #this should stop v
            
            if(first_iteration)
                first_iteration = false
            else
                # it trying to delimit the comment? idk
                # now it says it collected /demilited "a", but then keeps looking, doesn't see newline
                #  p ["is next val", separator_value, isNextValue(separator_value)]
                # p ["real next val", @tokens[0]]
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
        is_operator = isNextType("operator") && !isNextValue(",") #master bug remover large brain
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
                need_parens = operator["value"] !~ /^=/
                right = maybe_call(right, need_parens)
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
    def is_prefix_op(op)
        %w"+ - ++ -- ~ !".include?(op)
    end
    def is_prefix_only_op(op)
        %w"~ !".include?(op)
    end
    def maybe_call(expression, parens_needed = true)
        p ["in maybe_call", expression, parens_needed]
        
        if isNextType("left_paren") 
            ret = parse_call(expression)
            p "ret from maybe_call with parens: #{ret}"
            return ret
        elsif !parens_needed
            skipped_space = skipAllHoriSpace()
            p "@tokens:"
            p @tokens
            return expression if @tokens.empty?
            non_whitespace = @tokens.drop_while{|token| token["type"] == "whitespace"}
            if expression["type"] == "identifier" && @tokens[0]["type"] != "operator" && @tokens[0]["value"] !~ /[\n;\.]/
                return parse_args_no_paren(expression)
            # elsif expression["type"] == "identifier" && skipped_space && is_prefix_op(non_whitespace[0]["value"]) && non_whitespace[1]["type"] !~ /(whitespace|newline)/
            elsif expression["type"] == "identifier" && (is_prefix_only_op(non_whitespace[0]["value"]) || (skipped_space && is_prefix_op(non_whitespace[0]["value"]))) && non_whitespace[1]["type"] !~ /(whitespace|newline)/
                puts "prefix arg no paren"
                return parse_args_no_paren(expression)
            else
                return expression
            end
                did_skip_newline = false
            (did_skip_newline ||= @tokens[0]["value"] =~ /\n/; skipNextType("whitespace")) while isNextType("whitespace")
            
            # p ["in maybe call check token 0", @tokens[0]]
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
        p @tokens
        return isNextType("dot") ? maybe_method(parse_method(expression)) : expression
    end
    def parse_method(func)
        skipNextType("dot")
        throw "method name is not a valid name lol" unless isNextType("identifier") || isNextType("amp_identifier")
        if isNextType("identifier")
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
        else
            name = next_token()
            return {
                "type" => "amp_method",
                "self" => func,
                "name" => name["value"]
            }    
        end
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
            if isNextType("newline") || isNextValue(";") || isNextValue(".")
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

=begin
# valid examples 
*a =
*a,b =
a, =
a,*b=
a,*,b=  wtf is this idk it is valid
a,*_,b= ?
(a,)=
(a,(b,c)),*d= [[a,[b,c]],d,d,d]
idk how to parse something like this

*a,b=[1, * [1,2,3]]
trying to parse
*a,b
just sorta give a all the values and strip it down 1 by 1 (for b)
wdym=
so like initially you get a = [1,1,2,3]
and then you see there's b, so you rip one value off a, 
only considering the parsing, ruby will run the transpiled code
1 sec turning translucent background off
i'm playing csgo, so brb lol


ident = \w+

assignment_pattern =
      ident "," ?
    | ident ("," ident) * "," ?
    | "*" ident
    | "(" assignment_pattern ")"

=end
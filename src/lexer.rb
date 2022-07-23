require_relative "parser.rb"

# todo
# haha nothing
# 🤔

class Lexer
    
    attr :tokens

    def initialize(source, debug = false)
        @source = source
        @debug = debug
    end

    def lex()

        tokens = []
        code = @source.dup
        p code if @debug
        brackets = []
        next_can_be_identifier = true
        last_was_whitespace = false         # to be able to separate a .b / a(.b) and a&b / a &b 
        loop do
            # p code
            $_ = code
            
            if ~/\A#[^\n]*$/ # single line-comment
                tokens << ["comment_single", $&]
                code = $'
            elsif ~/\A^=begin.+^=end/m
                tokens << ["comment_multi", $&]
                code = $'
            elsif ~/\A([1-9][0-9]*|0)/ # int
                tokens << ["int", $&]
                code = $'
            elsif ~/\A([1-9][0-9]*|0)\.[0-9]+/ # float
                tokens << ["float", $&]
                code = $'
            elsif ~/\A'([^']*)'/ # raw string, single quote
                tokens << ["raw_string", $1]
                code = $'
            elsif ~/\A"((\\.|(?!#\{)[^\\"])*?)"/ # normal string, double quote "abc"
                tokens << ["string", $1]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A"((\\.|[^\\"])*?)#\{/ # "abc#{
                tokens << ["string_interpolate_start", $1]
                code = $'
                brackets << "string"
            elsif ~/\A\}((\\.|[^\\"])*?)#\{/ && brackets[-1] == "string" # }abc#{
                tokens << ["string_interpolate_middle", $1]
                code = $'
            elsif ~/\A\}((\\.|[^\\"])*?)"/ && brackets[-1] == "string" # }abc"
                tokens << ["string_interpolate_end", $1]
                code = $'
                brackets.pop
            elsif ~/\A`((\\.|[^\\`])*)`/ # shell string, backtick
                tokens << ["shell", $1]
                code = $'
            elsif ~/\A&((?!\d)\w+)/ && (last_was_whitespace || next_can_be_identifier) # &puts
                tokens << ["amp_identifier", $1]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\.((?!\d)\w+)/ && next_can_be_identifier #.to_a
                tokens << ["dot_identifier", $1]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\?(.)/m && next_can_be_identifier # ?a
                tokens << ["char", $1]
                code = $'
                next_can_be_identifier = false
=begin
            elsif ~/\A(\+\+|--|~|!)/ # prefix operators, problem with -?
                tokens << ["prefix_operator", $&]   
can we decide that calling functions wihtout args require parens?
or is that non-consistent
it is non-consistent...
                code = $'
                next_can_be_identifier = true
=end
                #when see prefix op, treat left as nil, pretend it is infix?, lets try
                #have to separate + and - from infix
                #in `p -a` `p - a`
                # !== === ... <=> -> .. != =~ !~ == || && ** <= >= = ^ | & % / * - + ? : < > ,
                # &&= ||= **= += -= *= /= %=  &= |= ^= << >> <<= >>=
            elsif ~/\A(\+\+|--|~|!(?![=~]))/ || ~/\A(!==|===|&&=|<<=|>>=|\|\|=|\*\*=|\.\.\.|\.\.|<=>|<<|>>|->|\+=|-=|\*=|-=|\/=|%=|&=|\|=|\^=|<=|>=|!=|=~|!~|==|\|\||&&|\*\*|<|>|=|\^|\||&|%|\/|\*|-|\+|\?|:|,)/ # operators
                tokens << ["operator", $&]
                code = $'
                next_can_be_identifier = true
            elsif ~/\A\$./ #  $<
                tokens << ["special_dollar", $&]
                code = $'
            elsif ~/\A\$\w+/ # $asd
                tokens << ["dollar", $&]
                code = $'
            elsif ~/\A(do|while|end|until|loop|def|end|lambda|if|else|case|when|elsif|in)(?!\w)/
                tokens << ["keyword", $&]
                code = $'
            elsif ~/\A(true|false)(?!\w)/
                tokens << ["bool", $&]
                code = $'
            elsif ~/\A(?!\d)\w+/ # asd
                tokens << ["identifier", $&]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\./ # .
                tokens << ["dot", "."]
                code = $'
            elsif ~/\A\r?\n/ # newline
                # go over all whitespace refs in naaa_parser
                tokens << ["newline", $&]
                code = $'
            elsif ~/\A\s+/ # whitespace
                tokens << ["whitespace", $&]
                code = $'
            elsif ~/\A;/ # semicolon
                tokens << ["semicolon", ";"]
                code = $'
            elsif ~/\A\{/
                tokens << ["left_curly", "{"]
                code = $'
                next_can_be_identifier = true
            elsif ~/\A\}/
                tokens << ["right_curly", "}"]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\[/
                tokens << ["left_square", "["]
                code = $'
                next_can_be_identifier = true
            elsif ~/\A\]/
                tokens << ["right_square", "]"]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\(/
                tokens << ["left_paren", "("]
                code = $'
                next_can_be_identifier = true
            elsif ~/\A\)/
                tokens << ["right_paren", ")"]
                code = $'
                next_can_be_identifier = false
            else
                STDERR.puts "couldn't parse #{code}"
                exit 1
            end
            p tokens[-1] if @debug
            last_was_whitespace = tokens[-1][0] == "whitespace"
            if code == ""
                return @tokens = tokens.map{|k,v|
                    {
                        "type" => k, "value" => v
                    }
                }
            end


        end

    end
    def to_s(sep = "")
        @tokens.map{|type, value|
            case type
            when "int"; value
            when "float"; value
            when "operator"; value
            when "identifier"; value
            when "raw_string"; "'#{value}'"
            when "string"; "\"#{value}\""
            when "string_interpolate_start"; "\"#{value}\#{"
            when "string_interpolate_middle"; "}#{value}\#{"
            when "string_interpolate_end"; "}#{value}\""
            when "shell"; "`#{value}`"
            when "amp_identifier"; "&" + value
            when "dot_identifier"; "." + value
            when "special_dollar"; value
            when "dollar"; value
            when "keyword"; value
            when "dot"; value
            when "left_curly"; value
            when "right_curly"; value
            when "left_square"; value
            when "right_square"; value
            when "left_paren"; value
            when "right_paren"; value
            when "whitespace"; value
            when "comment_single"; value
            when "comment_multi"; value
            when "semicolon"; value
            when "char"; "?#{value}"
            when "bool"; value
            else; "'''other #{value}'''"
            end

        }.map{|x|
            block_given? ? (yield x) : x
        }.join(sep)
    end
end

#look in temp.rb
# we need to parse so we can:
# a.map(&puts) -> a.map(&method(:puts))
# *but* also with arguments
# a.map(.to_i(1)) -> a.map(lambda{|asd|asd.to_i(1))))

# code = File.read("./ugly-bin/sample3.rb")

# code = "3+1*2"
# # code = "a.map(.to_i(2))"
# #what are you working on ?
# ### I am successful in my parsing, go from there?
# # ok

# out_file = File.open("./ugly-bin/temp.rb", "w")
# lexer = Lexer.new(code)
# lexer.lex
# tokens = lexer.tokens
# p tokens
# ast = Parser.new(tokens)
# ast.parse().map{|x| p x}



# out_file.write tokens.map{|line|line.inspect}*$/ + "

# "+lexer.to_s+"

# " + lexer.to_s(" "){|x|"(#{x} haha)"}


# "int", "float", "raw_string", "string", "shell", "amp_identifier", "operator", "special_dollar", "dollar", "keyword", "identifier", "dot", "left_curly", "right_curly", "left_square", "right_square", "left_paren", "right_paren"
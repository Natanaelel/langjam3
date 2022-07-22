# todo
# haha nothing
# 🤔

class Lexer
    
    attr :tokens

    def initialize(source)
        @source = source
    end

    def lex()

        tokens = []
        code = @source.dup
        p code
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
            elsif ~/\A&(?!\d)\w+/ && (last_was_whitespace || next_can_be_identifier)
                tokens << ["amp_identifier", $&]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\.(?!\d)\w+/ && next_can_be_identifier
                tokens << ["dot_identifier", $&]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\?(.)/m && next_can_be_identifier
                tokens << ["char", $1]
                code = $'
                next_can_be_identifier = false
                # !== === ... <=> -> .. != =~ == || && ** <= >= = ! ~ ^ | & % / * - + ? : < > ,
                # &&= ||= **= += -= *= /= %=  &= |= ^= << >> <<= >>=
            elsif ~/\A(!==|===|&&=|<<=|>>=|\|\|=|\*\*=|\.\.\.|\.\.|<=>|<<|>>|->|\+=|-=|\*=|-=|\/=|%=|&=|\|=|\^=|<=|>=|!=|=~|==|\|\||&&|\*\*|<|>|=|!|~|\^|\||&|%|\/|\*|-|\+|\?|:|,)/ # operators
                tokens << ["operator", $&]
                code = $'
                next_can_be_identifier = true
            elsif ~/\A\$./ #  $<
                tokens << ["special_dollar", $&]
                code = $'
            elsif ~/\A\$\w+/
                tokens << ["dollar", $&]
                code = $'
            elsif ~/\A(do|while|end|until|loop|def|end|lambda|if|else|case|when|elsif|in)(?!\w)/
                tokens << ["keyword", $&]
                code = $'
            elsif ~/\A(?!\d)\w+/ # asd
                tokens << ["identifier", $&]
                code = $'
                next_can_be_identifier = false
            elsif ~/\A\./ # .to_s
                tokens << ["dot", "."]
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
                tokens << ["left_round", "("]
                code = $'
                next_can_be_identifier = true
            elsif ~/\A\)/
                tokens << ["right_round", ")"]
                code = $'
                next_can_be_identifier = false
            else
                STDERR.puts "couldn't parse #{code}"
                exit 1
            end
            p tokens[-1]
            last_was_whitespace = tokens[-1][0] == "whitespace"
            if code == ""
                return @tokens = tokens
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
            when "amp_identifier"; value
            when "dot_identifier"; value
            when "special_dollar"; value
            when "dollar"; value
            when "keyword"; value
            when "dot"; value
            when "left_curly"; value
            when "right_curly"; value
            when "left_square"; value
            when "right_square"; value
            when "left_round"; value
            when "right_round"; value
            when "whitespace"; value
            when "comment_single"; value
            when "comment_multi"; value
            when "semicolon"; value
            when "char"; "?#{value}"
            else; "'''other #{value}'''"
            end

        }.map{|x|
            block_given? ? (yield x) : x
        }.join(sep)
    end
end
#fixed it
# ok
# could not parse the {
#I see no output when I run command it seems like
#where is temp.rb

# it's not there because you exit 1 after couldn't parse
#try again now

code = File.read("./ugly-bin/sample3.rb")

out_file = File.open("./ugly-bin/temp.rb", "w")
lexer = Lexer.new(code)
lexer.lex
tokens = lexer.tokens

out_file.write tokens.map{|line|line.inspect}*$/ + "

"+lexer.to_s+"

" + lexer.to_s(" ")#{|x|"#{x}"}


# "int", "float", "raw_string", "string", "shell", "amp_identifier", "operator", "special_dollar", "dollar", "keyword", "identifier", "dot", "left_curly", "right_curly", "left_square", "right_square", "left_round", "right_round"
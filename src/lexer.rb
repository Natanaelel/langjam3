# todo
# string interpolation

class Lexer
    def initialize(source)
        @source = source
    end

    def lex()

        tokens = []
        code = @source.dup
        p code
        loop do
            case code
            when /^-?[1-9][0-9]*|0/ # int
                tokens << ["int", $&]
                code = $'
            when /^-?([1-9][0-9]*|0)\.[0-9]+/ # float
                tokens << ["float", $&]
                code = $'
            when /^'([^']*)'/ # raw string, single quote
                tokens << ["raw_string", $1]
                code = $'
            when /^"((\\.|[^\\"])*)"/ # normal string, double quote
                tokens << ["string", $1]
                code = $'
            when /^`((\\.|[^\\`])*)`/ # shell string, backtick
                tokens << ["shell", $1]
                code = $'
            # !== === ... <=> .. != =~ == || && ** <= >= = ! ~ ^ | & % / * - + ? : < > 
            when /^&(?!\d)\w+/
                tokens << ["amp_identifier", $&]
                code = $'    
            when /^(!==|===|\.\.\.|\.\.|<=>|<=|>=|!=|=~|==|\|\||&&|\*\*|<|>|=|!|~|\^|\||&|%|\/|\*|-|\+|\?|:)/ # operators
                tokens << ["operator", $&]
                code = $'
            when /^\$./ #  $<
                tokens << ["special_dollar", $&]
                code = $'
            when /^\$\w+/
                tokens << ["dollar", $&]
                code = $'
            when /^(do|while|end|until|loop|def|end|lambda|if|else|case|when|elsif|in)/
                tokens << ["keyword", $&]
                code = $'
            when /^(?!\d)\w+/ # asd
                tokens << ["identifier", $&]
                code = $'
            when /^\.(?!\d)\w+/ # .to_s
                tokens << ["dot_identifier", $&]
                code = $'
            when /^\s+/ # skip whitespace
                code = $'
            when /^\{/
                tokens << ["left_curly", "{"]
                code = $'
            when /^\}/
                tokens << ["right_curly", "}"]
                code = $'
            when /^\[/
                tokens << ["left_square", "["]
                code = $'
            when /^\]/
                tokens << ["right_square", "]"]
                code = $'
            when /^\(/
                tokens << ["left_round", "("]
                code = $'
            when /^\)/
                tokens << ["right_round", ")"]
                code = $'
            else
                STDERR.puts "couldn't parse #{code.inspect}"
                exit 1
            end
            p code
            p tokens
            if code == ""
                return tokens
            end
        end

    end
    def self.cool()
        puts "cool"
    end
end
#fixed it
# ok
# could not parse the {
#I see no output when I run command it seems like
#where is temp.rb

# it's not there because you exit 1 after couldn't parse
#try again now

code = File.read("./ugly-bin/sample2.rb")

out_file = File.open("./ugly-bin/temp.rb", "w")
tokens = Lexer.new(code).lex
out_file.write tokens.map{|line|line.inspect}*$/ + "

"+tokens.map{|k,v|v}*" "

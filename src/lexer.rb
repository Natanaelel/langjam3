# def cool()
#     puts "test"
# end
class Lexer
    def initialize(source)
        @sourcce = source
    end

    def lex()

        tokens = []
        code = @source.dup
        
        loop do
            # how I usually lex    
            # ok
            case code
            when /^-?[1-9][0-9]*/ # int
                tokens << ["int", $&]
                code = $'
            when /^-?([1-9][0-9]*|0)\.[0-9]+/ # float
                tokens << ["float", $&]
                code = $'
            when /^(["'])((\\.|[^\\"])*)\1/ # string, double or single quote
                tokens << ["string", $2]
                code = $'
                # think specific operator would be better
                # ok
                # but I love unicode (raku) but idk
            # when /^[^0-9a-z_]/i # .*fix operator or symbol idk [+-*/...]
            when /^(\*\*|[^0-9a-z_*\/%])/i # .*fix operator or symbol idk [+-*/...]
                tokens << ["operator", $&]
                code = $'
            when /^\s+/ # skip whitespace right?
                code = $'
                # lets not get too far, we don't even know the theme yet
            else
                STDERR.puts "couldn't parse #{code.inspect}"
                exit 1
            end
            if code == ""
                return tokens
            end
        end

    end
    def self.cool()
        puts "cool"
    end
end
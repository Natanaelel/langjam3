class Parser
    def initialize(token_arr)
        @token_arr = token_arr
        @token_curr = nil
        @token_ind = -1
    end

    def eat() 
        @token_ind += 1
        @token_curr = @token_arr[@token_ind]
        @token_curr
    end

    def parse()
        while @token_arr.size != 0 do
            tok_typ, tok_val = eat()
            case tok_typ
                when "int"
                when "float"
                when "string"
                when "operator"
            end
        end
    end
end
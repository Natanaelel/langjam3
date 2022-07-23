require_relative "lexer.rb"
require_relative "natanaaaaellaleelalellelelll_parser.rb"
require_relative "transpiler.rb"

file_in_name = ARGV.shift
file_out_name = ARGV.shift

p file_in_name
p file_out_name
p ARGV

code = File.read file_in_name

p code

[
    {"type"=>"identifier", "value"=>"a"},
    {"type"=>"whitespace", "value"=>" "},
    {"type"=>"operator", "value"=>"="},
    {"type"=>"whitespace", "value"=>" "},
    {"type"=>"left_square", "value"=>"["},
    {"type"=>"int", "value"=>"1"},
    {"type"=>"operator", "value"=>","},
    {"type"=>"int", "value"=>"2"},
    {"type"=>"operator", "value"=>","},
    {"type"=>"int", "value"=>"3"},
    {"type"=>"right_square", "value"=>"]"},
    {"type"=>"whitespace", "value"=>"\r\n"},
    {"type"=>"identifier", "value"=>"a"},
    {"type"=>"dot", "value"=>"."},
    {"type"=>"identifier", "value"=>"map"},
    {"type"=>"left_paren", "value"=>"("},
    {"type"=>"dot_identifier", "value"=>"to_s"},
    {"type"=>"left_paren", "value"=>"("},
    {"type"=>"int", "value"=>"16"},
    {"type"=>"right_paren", "value"=>")"},
    {"type"=>"right_paren", "value"=>")"},
    {"type"=>"whitespace", "value"=>"\r\n"},
    {"type"=>"comment_single", "value"=>"# I have implemented comments lol\r"},
    {"type"=>"whitespace", "value"=>"\n"},
    {"type"=>"comment_single", "value"=>"# that is good"}]

tokens = Lexer.new(code).lex
puts p," -- tokens --",p,"nvm"
# p tokens
tree = Parser.new(tokens).parse
puts p," -- tree --",p
p tree
transpiled = Transpiler.new(tree).transpile
# p transpiled
File.write(file_out_name, transpiled)
puts `ruby #{file_out_name} #{ARGV * " "}`

# def die_func
#     exit 69
# end

# def run(code)

#     alias 🧀 puts
#     alias ☀️ die_func
#     eval code
    #imagine a syntax where {} was replaced by () and () were optinal,
    #like ruby but cleaner, and more "beautiful"
    # eval code.gsub(/\(|\)/,?(=>?{, ?)=>?}) # that might work idk
    # that is look very werird
# end
# run %{🧀 'hello'
# ☀️
# 🧀 'hello' }

=begin
we could [
    interpret
    transpile
    give up
    <s>compile</s>
]
"beautiful assembly"
"beautiful" <- take that word
syntax, no noise
I like unicode, ☺

=end
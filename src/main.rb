require_relative "lexer.rb"
#ah didn't know that
file_name, *argv = ARGV

p file_name
p ARGV
def run_code(source)
    puts "true"
    puts "source: #{source.lines.reverse.join.inspect}"
    eval source.lines.reverse.join
end


Lexer.new()

run_code File.read(file_name)
=begin
the parsing isn't, unless you make a stack lang, "parsed = tokens = source.split' '"
same
o i did a bit but im not the best
>lets write top to bottom
ok
>nice
what theme do you think it's gonna be?
what would you like it to be?

idk bottom to top exec might be cool
no idea either
sounds stupid
lol
fixed
easy clap
=end
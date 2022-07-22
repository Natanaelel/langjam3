require_relative "lexer.rb"
#ah didn't know that
file_name, *argv = ARGV

p file_name
p ARGV

code = file_name



# run_code File.read(file_name)

def die_func
    exit 69
end

def run(code)

    alias 🧀 puts
    alias ☀️ die_func
    eval code
    #imagine a syntax where {} was replaced by () and () were optinal,
    #like ruby but cleaner, and more "beautiful"
    # eval code.gsub(/\(|\)/,?(=>?{, ?)=>?}) # that might work idk
    # that is look very werird
end
run %{🧀 'hello'
☀️
🧀 'hello' }

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

where?
use the session chat it's kinda better
live share tab, and below theres session chat
=end
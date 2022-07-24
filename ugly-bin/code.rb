# worship the big beautiful cheese
# the program will be an assembly of individuals who are extreme caseophile's 
# it will have lots of the unicode
# the program will look cool

# changes to make:
# a.map(.asd(2)) -> a.map{|x|x.asd(2)}
# a.map(&asd) -> a.map{|x|asd x}
# &a -> method(:a)
# a.&b -> a.method(:b)
# .asd -> lambda{|x|x.asd}
# .asd(123) -> lambda{|x|x.asd(123)}
# {|x| code } -> lambda{|x| code } ? maybe

f = { |x| code }
#now:
f = lambda{ |x| code }
f = -> (x) { code }

༼ つ ◕_◕ ༽つ # their name is bob
# hi bob
#
bob 🧍
bob.🛐 # bob worships the cheese
🧀 bob.💪 # the cheese declares bob's status
anita 🧍
anita ⬅️ bob # set anita to copy bob's stats
🧀 anita # cheese declares anita 
☀️ # cheese die

can you find some noisy ruby code? to test on as in not "beautiful"
noisy as in bad? ugly?
imma just get previous clash codes

w️hat about ternary, do we fix?
what is wrong with it? the extra spaces needed sometimes
# no implicit mutation only reassignment? nah
remove symbols and methods? that? have? trailing? questionmarks? and explaksfjlaskjfaslk! uniq!
ye





def die_func (
    exit 69
)

def run(code) (

    alias 🧀 puts
    alias ☀️ die_func
    # imagine a syntax where {} was replaced by () and () were optinal,
    # like ruby but cleaner, and more "beautiful"
    eval code.tr "()", "{}" # wait tr
    #just example code in "bc"
)
run "🧀 'hello'"
️
-----------------------️

--- testing syntax ---

Glang  = require "./glang.js"
fs = require "fs"

a ⊂ b ⊇ c
(⊢ + ⊣) I love apl syntax and stuff
and pointfree
got more tacks than tackshooter

# ⊃⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎⊏⊐⊑⊒⊓⊔⊕⊖⊗⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩⊪⊫⊬⊭⊮⊯⊰⊱⊲⊳⊴⊵⊶⊷⊸⊹⊺⊻⊼⊽⊾⊿⋀⋁⋂⋃⋄⋅⋆⋇⋈⋉⋊⋋⋌⋍⋎⋏⋐⋑⋒⋓⋔⋕⋖⋗⋘⋙⋚⋛⋜⋝⋞⋟⋠⋡⋢⋣⋤⋥⋦⋧⋨⋩⋪⋫⋬⋭⋮⋯⋰⋱⋲⋳⋴⋵⋶⋷⋸⋹⋺⋻⋼⋽⋾⋿⌀⌁⌂⌃⌄⌅⌆⌇⌈⌉⌊⌋
a.map{|x|f x}
a.map{|x|x.f}
a.map(f)
a.map(x -> x.f)
a.map(x→x.f)
a.map(x↝x.f)
a.map(.to_s(2)) # that is nice, instead of lambda {|x|x.f
that is obj method
that vv is global "func" method
"f(a)" vs "a.f()"
[].map(f) # not possible in ruby yet
[].map(&method(:f)) # how to do currently
[].map(&f) # how to solve if
[].map(.f)
[].map(&(a, b) => a+b) 
[].map((a, b) -> a+b) 
[].map (+1)
[].map(&+((1)))


# [].map(.+1)
# ok
#partial application as syntax idk 
# I know
f((1)) == lambda{|*args| f(1,*args)}
# so if the function only takes 1 item?
# &f is like method(:f), it referenced the function but doesn't call it
#could also do:
a.&to_s
#instead of
a.method(:to_s)
# clean?
# yeah i guess
#basically syntax replaces keywords
#basically & replaces "method"
# so you can do both .f and &f
#no, &f replaces method(:f)
# .f replaces lambda{|bruh|bruh.f}

# ok i see
#that is 2 changes
#any more cheese?
#keywords
#end -> stop
# why egg

#can we remove "def" ?
#> make it death
#I don't like keywords as "end", "}" is better but noisy still

#I like js arrows
f↝(args)
f = (a, b) => a + b

ok
feta f(args)
thats longer...
nothing? indentation?
no
#I know

if a == b
	puts "somethings"
ok
def f(g)

ok
#better than ruby
#transpiling ruby from ruby to ruby but butter?
# it is similar
# can we just remove all ruby keywords and make neccesary ones unicode symbols?

# we can just reassign them to nil or something well maybe not keywords
# something to 
# so we dont replace string contents
# and then back to ruby
#basically just tokenize, replace some tokens, then back to ruby?
if token == "method"
	ident = rand_ident()
	code = "lambda{ |#{ident}|   #{ident} . #{method} (*#{args} ) }" 
end
# yes
# start?
# make a list of changes to be made
# method(:puts) -> &puts?
a.map(&puts) #is then possible
# isn't it .puts?
what do you mean?
↑↓←→↔↕ 

def  test_programs()(
	programs = fs.readFileSync("./test_programs.txt").to_s.split(/\s*\*\*\*\s*/).filter(x => x != "")

	for(program in programs)(
		g = Glang(program)
		g.run
		print(g.stack.pretty)
		print(g.stack.top)
		print("")

	)
)
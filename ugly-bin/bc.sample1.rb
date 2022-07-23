a = 10
hex = .to_s(16)
## that doesn't work yet
# a()# a()# a()# a()#also hex is a lambda, I was thinking of "removing" non-lambdas, making everything consistent
#so .map takes lambda/proc instead of converting block to proc and calling with &
# now : .map(&lambda)
# my idea: .map( &lambda ) in this, &lambda is one token which references var/func named "lambda"
# basically f == f()  # &f == f
#this could then work:
# a = .to_s;
# a(10)
# (&a)10
you know about ruby array#grep?
# kinda
its different from most array methods because it takes proc/lambda as arg, not block,
a.map(&:to_i) a.map{|x|x.to_i} # block
a.grep(lambda{|x| asd }) # proc/lambda
a.grep( -> x { asd } ) # proc/lambda
# no it's ok
# you get it? 
# ya
# so transpile "puts" -> "puts()"
# so transpile "&puts" -> "method(:puts)"
# so transpile "&puts(1)" -> "method(:puts).call(1)"
# hmm, maybe "alias old_puts puts; undef puts; puts = lambda {|*x| old_puts *x}

# total desc #
# replace all functions with lambdas, so every function call is with .call and not implicit,
# but implicitly add .call unless prefixed with &
f = <lambda>
f(1) # works
a = f
a(1) # doesn't, a is result of f()

a = &f
a(1) # does, a is f
# makes sense?


# ok in the first one it is a = f() yes
# then a = lambda {|x| f x} yes, or  lambda {|x| f.call x} if you so please
#basicaly, in
# a = &f, a == f
# a = f, a == f() 
# ok
# so we have to transform ruby built-ins to lambdas and stuff
#runtime.fixer.thing.rb

# wait wtf it can take regex and range as well? https://apidock.com/ruby/Enumerable/grep
# apparently
# aaaaaaaaaaaaaaaaaaaaaaaaaaaaaab
p [30,40,50].map(&hex)
# that is hacker
# wait a sec
# puts -a
# p a
# p +a
# p~a
# p -a
# p a++
# p ++a

#  -a * 2
#  - a * 2

# p a -> p(a)
# p+a -> (p + a)
# p + a -> (p + a)
# p+ a -> (p + a)
# p +a -> p(+a)
# p~a -> p(+a)
# *a = 1 # why newline disappear
#prefix operators next problem?
# - ~ ++ -- !
# ++ can be before and after a var
# how would you convert it to ruby doe
# a++ -> ((a+=1)-1)
# ++a -> (a+=1)
#ngl very nice
# so add it in precedence i'd imagine?
# it can't parse prefix yet I think but yes
# I want to recognize left of "=" as an assignment pattern

# puts + a # not  valid, puts returns nil
# puts +a # valid, outputs a

# p a
# p p
# p b
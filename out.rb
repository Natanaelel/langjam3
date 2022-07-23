module Enumerable
    alias _old_map map
    def map(block) = _old_map(&block)
end

class Array
    alias all all?
    alias any any?
    alias one one?
    alias none none?
    alias has include?
    
    alias _old_max max; def max(block) = block ? map(&block)._old_max : _old_max
    alias _old_min min; def min(block) = block ? map(&block)._old_min : _old_min
    alias _old_map map; def map(block) = _old_map(&block) # takes lambda, not block

end
def lambify(name)
    eval "alias _old_#{name} #{name};
    undef :#{name};
    lambda{|*x|_old_#{name}(*x)}", TOPLEVEL_BINDING
end
# https://ruby-doc.org/core-3.1.2/Kernel.html
puts = lambify("puts")
putc = lambify("putc")
print = lambify("print")
printf = lambify("printf")
warn = lambify("warn")
p = lambify("p")
# eval = lambify("eval")  #eval is special case, I imagine we want to eval as bc, not as rb? also this breaks lambify

#next todo? &asfs ?
# ok
# hm
# now puts doesn't "implicitly" call, you need .call or .()
# this code runs, try it!

## end of runtime.fixer.thing.rb
ten = 10.method("to_s")
print.call(((["Hello", "World!"] * ", ") + "!"))
puts.call()
p.call([2, 10].map(10.method("to_s")))

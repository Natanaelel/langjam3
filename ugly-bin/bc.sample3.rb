double = |x| x * 2
triple = | a |a * 3
add = |x, y| x + y

p double 10
puts triple 123
p add 1,2

dosomething = || puts rand 10
f = dosomething
p f
puts "."
# [1,2,3].map(|x|p x + 1)
# f = |x,y|(p x,y);
# 5.times.with_index.to_a.map(&f)
# p 5.times(||p p)#.map(&f)

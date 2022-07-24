# done
`|arg|body` <br>
`|*arg,x|body` <br>
`.method` <br>
`.&method` <br>
`&func` (writing `func` without parens also works, you need parens to call function, you don't need parens for methods)
# todo
### lambda/function definition/syntax
don't use `def` keyword
```rb
# multiple args with splat ✔
f = |arg0, *args, cheese| cheese.taste

#no args ✔
f = || puts $<.map(.chop)

# multi- line/statement ✔
f = |a|
(
    puts 0
    puts 1; a[2] = 3
)
```
`||` eats 1 expression, if you want 0, do `||()` or `||;` ✔

### examples
```rb
# ✔
5.times(||
    puts rand i
)

[1,2,3].map(|x|x+1)# ✔

a.each(|bill|bill.delete) # ✔
# or
a.each(.delete) # ✔

a.each(|meme| puts meme) # ✔
# or 
a.each(&puts) # ✔
# or
a.each &puts # ✔

a.each | cheese | say(cheese) # not valid,
# must have parens or something to differtiate from:
# bitwise or: |
# logical or: ||
# for example
greet = |arg| puts "hello #{arg}!"
#     =
5.times(|arg| puts "hello #{arg}!")
#      (                          )
```
## progress
none

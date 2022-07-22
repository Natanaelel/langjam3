["identifier", "f"]
["operator", "="]
["operator", "->"]
["identifier", "s"]
["operator", ","]
["identifier", "b"]
["left_curly", "{"]
["identifier", "s"]
["left_square", "["]
["int", "1"]
["right_square", "]"]
["operator", "?"]
["identifier", "b"]
["whitespace", " "]
["operator", "?"]
["whitespace", " "]
["char", "("]
["operator", "+"]
["identifier", "f"]
["left_square", "["]
["identifier", "s"]
["left_square", "["]
["operator", ".."]
["operator", "-"]
["int", "2"]
["right_square", "]"]
["operator", ","]
["operator", "!"]
["identifier", "b"]
["right_square", "]"]
["operator", "+"]
["string", ") "]
["operator", "+"]
["identifier", "s"]
["left_square", "["]
["operator", "-"]
["int", "1"]
["right_square", "]"]
["operator", ":"]
["identifier", "s"]
["left_square", "["]
["int", "0"]
["right_square", "]"]
["operator", "+"]
["string", " ("]
["operator", "+"]
["identifier", "f"]
["left_square", "["]
["identifier", "s"]
["left_square", "["]
["int", "1"]
["operator", ".."]
["right_square", "]"]
["operator", ","]
["operator", "!"]
["identifier", "b"]
["right_square", "]"]
["operator", "+"]
["char", ")"]
["operator", ":"]
["whitespace", " "]
["identifier", "s"]
["left_square", "["]
["int", "0"]
["right_square", "]"]
["right_curly", "}"]
["whitespace", "\n"]
["special_dollar", "$>"]
["operator", "<<"]
["identifier", "f"]
["left_square", "["]
["identifier", "gets"]
["dot", "."]
["identifier", "split"]
["operator", ","]
["int", "0"]
["right_square", "]"]
["whitespace", "\n\n"]
["comment_single", "# f=(s,b)→s[1]?b?\"(\"+f(s[..-2],!b)+\") \"+s[-1]:s[0]+\" (\"+f(s[1..],!b)+\")\":s[0]}"]
["whitespace", "\n"]
["comment_single", "# ⏪f(gets.split,0)"]
["whitespace", "\n\n\n"]
["comment_single", "# raku? "]
["whitespace", "\n"]
["comment_single", "# kinda"]
["whitespace", "\n"]
["comment_single", "# a.f(*g) === f(a,*g) ?"]
["whitespace", "\n"]
["comment_single", "# it looks clean, but I think it maybe has gone too far idk, ok"]
["whitespace", "\n"]
["comment_single", "# lol alright it might be confusing"]
["whitespace", "\n"]
["comment_single", "# its no longer changes in syntax, but that shouldnt really matter, but its a big ... thing to implement"]
["whitespace", "\n"]
["comment_single", "# so maybe not then"]
["whitespace", "\n"]
["comment_single", "# lets start code  the first parts then?"]
["whitespace", "\n"]
["comment_single", "# sure"]
["whitespace", "\n"]
["comment_single", "# I will try to tokenize almost all possible ruby code, not as ruby does it, but as it should be done :)"]
["whitespace", "\n"]
["comment_single", "# alright"]
["whitespace", "\n"]

f=->s,b{s[1]?b ? ?(+f[s[..-2],!b]+") "+s[-1]:s[0]+" ("+f[s[1..],!b]+?): s[0]}
$><<f[gets.split,0]

# f=(s,b)→s[1]?b?"("+f(s[..-2],!b)+") "+s[-1]:s[0]+" ("+f(s[1..],!b)+")":s[0]}
# ⏪f(gets.split,0)


# raku? 
# kinda
# a.f(*g) === f(a,*g) ?
# it looks clean, but I think it maybe has gone too far idk, ok
# lol alright it might be confusing
# its no longer changes in syntax, but that shouldnt really matter, but its a big ... thing to implement
# so maybe not then
# lets start code  the first parts then?
# sure
# I will try to tokenize almost all possible ruby code, not as ruby does it, but as it should be done :)
# alright


f = -> s , b { s [ 1 ] ? b   ?   ?( + f [ s [ .. - 2 ] , ! b ] + ") " + s [ - 1 ] : s [ 0 ] + " (" + f [ s [ 1 .. ] , ! b ] + ?) :   s [ 0 ] } 
 $> << f [ gets . split , 0 ] 

 # f=(s,b)→s[1]?b?"("+f(s[..-2],!b)+") "+s[-1]:s[0]+" ("+f(s[1..],!b)+")":s[0]} 
 # ⏪f(gets.split,0) 


 # raku?  
 # kinda 
 # a.f(*g) === f(a,*g) ? 
 # it looks clean, but I think it maybe has gone too far idk, ok 
 # lol alright it might be confusing 
 # its no longer changes in syntax, but that shouldnt really matter, but its a big ... thing to implement 
 # so maybe not then 
 # lets start code  the first parts then? 
 # sure 
 # I will try to tokenize almost all possible ruby code, not as ruby does it, but as it should be done :) 
 # alright 

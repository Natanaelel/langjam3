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

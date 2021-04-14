add wave x
add wave y
add wave overflow
add wave zero
add wave output
add wave addsub_out
add wave func
add wave add_sub

#set add_sub, func, x and y inputs
force add_sub 0
force func 10

force x 00000000000000000000000000000001                                                   
force y 00000000000000000000000000000001 
run 5

force x 10000000000000000000000000000001                                                   
force y 00000000000000000000000000000001 
run 5

force x 00000000000000000000000000001001                                                   
force y 10000000000000000000000000000001 
run 5



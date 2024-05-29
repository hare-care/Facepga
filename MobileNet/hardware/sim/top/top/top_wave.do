add wave -noupdate -group top_tb/top_inst/
add wave -noupdate -group top_tb/top_inst/ -radix hexadecimal top_tb/top_inst/*

add wave -noupdate -group top_tb/top_inst/mobilenet/
add wave -noupdate -group top_tb/top_inst/mobilenet/ -radix hexadecimal top_tb/top_inst/mobilenet/*

add wave -noupdate -group top_tb/top_inst/mobilenet/conv_layer
add wave -noupdate -group top_tb/top_inst/mobilenet/conv_layer -radix hexadecimal top_tb/top_inst/mobilenet/conv_layer/*
 
add wave -noupdate -group /top_tb/top_inst/mobilenet/conv_layer/genblk1[3]/convolutional_layer/
add wave -noupdate -group /top_tb/top_inst/mobilenet/conv_layer/genblk1[3]/convolutional_layer/ -radix hexadecimal /top_tb/top_inst/mobilenet/conv_layer/genblk1[3]/convolutional_layer/*

history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/conv/conv.prj
project -run  
project -new /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/conv.prj
add_file conv.sv
add_file window.sv
add_file -verilog ../top/convolutional_layer.sv
project -run  
design close d:0
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/resize/resizer.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/conv/conv.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/conv.prj

history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/window.prj
add_file -verilog ../sv/conv/conv.sv
project -run  
project -save /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/window.prj 
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/window.prj

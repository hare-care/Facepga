history clear
project -load /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/window.prj
project -new /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/other_layers/fc.prj
add_file fc.sv
project -run  
project -save fc /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/fc/fc.prj
project -close /home/ted4152/Winter24/FPGA/hw6/implementation/sv/cordic_module.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/window.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/fc/fc.prj

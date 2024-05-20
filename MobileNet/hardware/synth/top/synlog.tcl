history clear
project -load /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/conv/conv.prj
project -new /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/window.prj
add_file window.sv
add_file conv.sv
add_file ../other_layers/avg_pool/avg_pool.sv
add_file ../other_layers/avg_pool/div_synth.sv
add_file ../other_layers/fc.sv
add_file ../other_layers/resizer.sv
add_file ../top/convolutional_layer.sv
add_file ../top/network_components.sv
add_file ../top/processing_state_controller.sv
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -run  
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/synth/conv/conv.prj
project -close /home/ted4152/Spring24/Facepga/MobileNet/hardware/sv/conv/window.prj

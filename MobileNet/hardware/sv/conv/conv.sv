


/*Implementation


Inner loop state - perform MAC (mult and add???)
Above, move window across, then down
Above, move beteen slices over depth
*/
module conv#(
    parameter filter_dim = 3;
)(

);

typedef enum logic[3:0] { multiply, moveWindow,} name;



endmodule


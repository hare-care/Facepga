void conv(const float in[],
          const float weights[], 
          const float bias[],
          float out[],
          const unsigned kh,
          const unsigned kw,
          const unsigned ih,
          const unsigned iw,
          const unsigned id, 
          const unsigned oh, 
          const unsigned ow, 
          const unsigned od,
          const unsigned s,
          char layer) {

    unsigned o_s;
    unsigned i_s;
    unsigned o_x;
    unsigned o_y;
    unsigned f_x;
    unsigned f_y;

    float sum;
    float * in_el;
    float * f_el;
    float * in_slice;
    float * filter_slice;
    float * in_line;
    float * o_line;
    float * out_slice;

    unsigned ls = s * ih;

    for ( o_s = 0; o_s < od; o_s++) { //Iterating over out slices
        out_slice = &out[ o_s * oh * ow ]; // Out slice <= square slice out of kube
        for ( i_s = 0; i_s < id ; i_s++) { //Iterating over in depth
            filter_slice = &weights[ (o_s * kh * kw * id) + (i_s * kh * kw) ]; //Get correct filters from array
            in_slice = &in[ i_s * ih * iw ]; //get correct inputs
            o_line = out_slice; //get correct line of output for write
            for ( o_y = 0; o_y < oh; o_y++) {
                in_line = in_slice; 
                for ( o_x = 0; o_x < ow; o_x++) {
                    in_el = in_line;
                    f_el = filter_slice;
                    sum = 0.0;
                    for ( f_y = 0; f_y < kh; f_y++) {
                        for ( f_x = 0; f_x < kw; f_x++) {
                            sum += f_el[f_x] * in_el[f_x];
                        }
                        f_el += kw;
                        in_el += iw;
                    }
                    o_line[o_x] += sum;
                    in_line += s;
                }
                o_line += ow;
                in_slice += ls;
            }
        }

        for(o_x = 0; o_x < oh*ow; o_x++) {
            out_slice[o_x] += bias[o_s];
        }
    }
}
int main(char** argv, int argc){
    return 0;
}
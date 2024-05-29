#include <iostream>
#include <fstream>
#include <vector>



unsigned char gray(char r, char b, char g){
     return ((unsigned char)r + (unsigned char)g + (unsigned char)b)/3;
}


int main(int argc, char** argv){

    
    const std::vector<char> weights = {-1,-2,-1,0,0,0,1,2,1};
    //const std::vector<char> weights = {1,1,1,1,1,1,1,1,1};
    const std::vector<char> biases = {0,0,0,0,0,0,0,0,0};

    std::ifstream inputFile;
    std::ofstream outputFile("cppOut.bmp",std::ios::binary);

    inputFile.open(argv[1],std::ios::binary);

    if (!inputFile.is_open() || !outputFile.is_open()) {
        std::cerr << "Failed to open the file." << std::endl;
        return 1;
    }

    char bmpheader[54];

    inputFile.read(bmpheader,54);

    //printf("%0x %0x %0x %0x \n",bmpheader[5],bmpheader[4],bmpheader[3],bmpheader[2]);
    /*bmpheader[36] = 2;
    bmpheader[35] = 0x4c;
    bmpheader[4] = 2;
    bmpheader[3] = 0x4c;
    bmpheader[2] = 0x36;
    bmpheader[28] = 0x18;
    bmpheader[18] = 224;
    bmpheader[19] = 0;
    bmpheader[22] = 224;
    bmpheader[23] = 0; */

    for (int i = 0; i < 54; i ++){
        outputFile << bmpheader[i];
    }

    std::vector<char> pixels(std::istreambuf_iterator<char>(inputFile), {});
    
    printf("%d",pixels.size());
    for(int i = 0; i < pixels.size()/3;i++){
        //outputFile << pixels[i];
        const int xCord = i % 224;
        const int yCord = i / 224;
        int total = 0;
        if (xCord == 0 || xCord == 223 || yCord == 0 || yCord == 223){
            outputFile << (char)0 << (char)0 << (char)0;
        } else {
            total += (pixels[3*(((yCord + 1) * 224 + xCord - 1))] * weights[0]) + biases[0];
            //if (i < 1200) printf("Pix %d * weight %d = %d\n",(cropped_pix[(yCord + 1) * 224 + xCord - 1] * weights[0]),weights[0],total);
            total += (pixels[3*((yCord + 1) * 224 + xCord)] * weights[1]) + biases[1];
            //if (i < 1200) printf("Pix %d * weight %d = %d\n",(cropped_pix[(yCord + 1) * 224 + xCord] * weights[1]),weights[1],total);
            total += (pixels[3*((yCord + 1) * 224 + xCord + 1)] * weights[2]) + biases[2];
          //  if (i < 1200) printf("Pix %d * weight %d = %d\n",(cropped_pix[(yCord + 1) * 224 + xCord + 1] * weights[2]),weights[2],total);
            total += (pixels[3*(yCord * 224 + xCord - 1)] * weights[3]) + biases[3];
            total += (pixels[3*(yCord * 224 + xCord)] * weights[4]) + biases[4];
            total += (pixels[3*(yCord * 224 + xCord + 1)] * weights[5]) + biases[5];
            total += (pixels[3*((yCord - 1) * 224 + xCord - 1)] * weights[6]) + biases[6];
            total += (pixels[3*((yCord - 1) * 224 + xCord)] * weights[7]) + biases[7];
            total += (pixels[3*((yCord - 1) * 224 + xCord + 1)] * weights[8]) + biases[8];
            //if (i < 1200) printf("Pixel #%d evaluates to: %d -> %d \n",i,total,abs(total));
            total = abs(total);
            while(total > 255){
                total -= 256;
            }
            outputFile << (char)total << (char)total << (char)total;
        }
    }
    
    outputFile.close();
    inputFile.close();
    return 0;
}
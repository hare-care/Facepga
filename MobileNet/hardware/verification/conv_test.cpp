#include <iostream>
#include <fstream>
#include <vector>



unsigned char gray(char r, char b, char g){
     return ((unsigned char)r + (unsigned char)g + (unsigned char)b)/3;
}


int main(int argc, char** argv){

    
    //const std::vector<char> weights = {-1,-2,-1,0,0,0,1,2,1};
    const std::vector<char> weights = {1,1,1,1,1,1,1,1,1};
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

    bmpheader[18] = 224;
    bmpheader[19] = 0;
    bmpheader[22] = 224;
    bmpheader[23] = 0; 
    bmpheader[39] = 0xC4;

    for (int i = 0; i < 54; i ++){
        outputFile << bmpheader[i];
    }

    std::vector<char> pixels(std::istreambuf_iterator<char>(inputFile), {});
    std::vector<unsigned char> gray_pixels;

    for(int i = 0; i < pixels.size()/3; i++){
        const int xCord = i % 720;
        const int yCord = i / 720;
        const unsigned char grayPix = gray(pixels[3*i],pixels[3*i + 1],pixels[3*i + 2]);
        gray_pixels.push_back(grayPix);
    }

    std::vector<unsigned char> cropped_pix;
    int total = 0;
    for (int i = 0; i < pixels.size()/3; i++) {
        const int xCord = i % 720;
        const int yCord = i / 720;
        if (xCord > 23 && xCord < 696 && yCord < 696 && yCord > 23){
            if (xCord % 3 == 0 && yCord % 3 == 0){
                total ++;
                cropped_pix.push_back(gray_pixels[yCord * 720 + xCord]);
            }
        }
    }
    std::cout << "Reduced 720x720 to " << total << " pixels\n";
    for(int i = 0; i < cropped_pix.size();i++){
        const int xCord = i % 224;
        const int yCord = i / 224;
        int total = 0;
        if (xCord == 0 || xCord == 223 || yCord == 0 || yCord == 223){
            outputFile << (char)0  << (char)0  << (char)0;
        } else {
            total += (cropped_pix[(yCord + 1) * 224 + xCord - 1] * weights[0]) + biases[0];
            //if (i < 1200) printf("Pix %d * weight %d = %d\n",(cropped_pix[(yCord + 1) * 224 + xCord - 1] * weights[0]),weights[0],total);
            total += (cropped_pix[(yCord + 1) * 224 + xCord] * weights[1]) + biases[1];
            //if (i < 1200) printf("Pix %d * weight %d = %d\n",(cropped_pix[(yCord + 1) * 224 + xCord] * weights[1]),weights[1],total);
            total += (cropped_pix[(yCord + 1) * 224 + xCord + 1] * weights[2]) + biases[2];
          //  if (i < 1200) printf("Pix %d * weight %d = %d\n",(cropped_pix[(yCord + 1) * 224 + xCord + 1] * weights[2]),weights[2],total);
            total += (cropped_pix[yCord * 224 + xCord - 1] * weights[3]) + biases[3];
            total += (cropped_pix[yCord * 224 + xCord] * weights[4]) + biases[4];
            total += (cropped_pix[yCord * 224 + xCord + 1] * weights[5]) + biases[5];
            total += (cropped_pix[(yCord - 1) * 224 + xCord - 1] * weights[6]) + biases[6];
            total += (cropped_pix[(yCord - 1) * 224 + xCord] * weights[7]) + biases[7];
            total += (cropped_pix[(yCord - 1) * 224 + xCord + 1] * weights[8]) + biases[8];
        //    if (i < 1200) printf("Pixel #%d evaluates to: %d -> %d \n",i,total,abs(total));
            total = abs(total)/9;
            outputFile << (char)total << (char)total << (char)total;
        }
    }

    for(int i = 0; i < 100; i ++){
        //printf("%d\n",cropped_pix[i]);
    }
    
    outputFile.close();
    inputFile.close();
    return 0;
}
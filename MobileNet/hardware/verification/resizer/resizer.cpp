#include <iostream>
#include <fstream>
#include <vector>





int main(int argc, char** argv){

    std::ifstream inputFile;
    std::ofstream cameraCrop("tracksCameraCrop.bmp",std::ios::binary);
    std::ofstream resizerCrop("tracksResizerCrop.bmp",std::ios::binary);

    inputFile.open(argv[1],std::ios::binary);

    if (!inputFile.is_open() || !resizerCrop.is_open() || !cameraCrop.is_open()) {
        std::cerr << "Failed to open the file." << std::endl;
        return 1;
    }

    char bmpheader[54];

    inputFile.read(bmpheader,54);

    bmpheader[18] = 224;
    bmpheader[19] = 0;
    bmpheader[22] = 224;
    bmpheader[23] = 0; 

    for (int i = 0; i < 54; i ++){
        resizerCrop << bmpheader[i];
    }
    bmpheader[18] = 0x80;
    bmpheader[19] = 0x02;
    bmpheader[22] = 0xe0;
    bmpheader[23] = 0x01;
    for (int i = 0; i < 54; i ++){
        cameraCrop << bmpheader[i];
    }

    std::vector<char> pixels(std::istreambuf_iterator<char>(inputFile), {});
    std::vector<unsigned char> croppedPixels = {};

    int writeCount = 0;
    for(int i = 0; i < pixels.size()/3; i++){
        const int xCord = i % 720;
        const int yCord = i / 720;
        if (xCord > 39 && xCord < 680){
            if (yCord > 119 && yCord < 600){
                
                cameraCrop << (char)pixels[3*i] << (char)pixels[(3*i) + 1] << (char)pixels[(3*i) + 2];
                croppedPixels.push_back(pixels[3*i]);
                croppedPixels.push_back(pixels[(3*i) + 1]);
                croppedPixels.push_back(pixels[(3*i) + 2]);
               // std::cout << "(" << xCord << " , " << yCord << ")" << "i = " << i << "\n";
            }
        }
    }
    for(int i = 0; i < pixels.size()/3; i++){
        const int xCord = i % 720;
        const int yCord = i / 720;
        if (xCord > 135 && xCord < 584){
            if (yCord > 135 && yCord < 584){//In crop range
                if(yCord%2 == 0 && xCord%2 == 0){
                    
                    int totalR = abs(pixels[3*i]) + abs(pixels[(3*i) + 3]) + abs(pixels[(3*i) + (720*3)]) + abs(pixels[(3*i) + (720 * 3) + 3]);
                    int totalG = abs(pixels[(3*i) + 1]) + abs(pixels[(3*i) + 4]) + abs(pixels[(3*i) + (720 * 3) + 1]) + abs(pixels[(3*i) + (720 *3) + 4]);
                    int totalB = abs(pixels[(3*i) + 2]) + abs(pixels[(3*i) + 5]) + abs(pixels[(3*i) + (720 * 3) + 2]) + abs(pixels[(3*i) + (720 * 3) + 5]);
                    unsigned char R = totalR / 4;
                    unsigned char G = totalG / 4;
                    unsigned char B = (totalB / 4);
                    //resizerCrop << R << G << B;
                }
            }
        }
    }

    //std::cout << writeCount;
    cameraCrop.close();
    resizerCrop.close();
    inputFile.close();
    return 0;

}
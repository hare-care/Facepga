#include <iostream>

int main(){

    int total = 0;
    for(int i = 0; i < 1024; i++){
        total += (i%256) * ((i+3) % 4);
    }
    std::cout << "FC result: " << total << "\n";

    return 0;
}
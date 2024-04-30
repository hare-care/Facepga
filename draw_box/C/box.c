#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#define THRESHOLD 50
#define BOX_X 0
#define BOX_Y 100
#define BOX_HEIGHT 50
#define BOX_WIDTH 50
	

struct pixel {
   unsigned char b;
   unsigned char g;
   unsigned char r;
};

int check_pixel_box(int in_x, int in_y) {
    // if correct y (bottom or top) check if in bound of x, draw red
    if ((in_y == (BOX_Y + (BOX_HEIGHT/2))) || (in_y == (BOX_Y - (BOX_HEIGHT/2)))) 
    {
        if (((BOX_X - (BOX_WIDTH/2)) <= in_x) && (in_x <= (BOX_X + (BOX_WIDTH/2)))) return 1;    
    } 
    else if ((in_x == (BOX_X + (BOX_WIDTH/2))) || (in_x == (BOX_X - (BOX_WIDTH/2)))) 
    {
        if (((BOX_Y - (BOX_HEIGHT/2)) <= in_y) && (in_y <= (BOX_Y + (BOX_HEIGHT/2)))) return 1;
    }
     
    return 0;
}

// Read BMP file and extract the pixel values (store in data) and header (store in header)
// data is data[0] = BLUE, data[1] = GREEN, data[2] = RED, etc...
int read_bmp(FILE *f, unsigned char* header, int *height, int *width, struct pixel* data) 
{
	printf("reading file...\n");
	// read the first 54 bytes into the header
   if (fread(header, sizeof(unsigned char), 54, f) != 54)
   {
		printf("Error reading BMP header\n");
		return -1;
   }   

   // get height and width of image
   int w = (int)(header[19] << 8) | header[18];
   int h = (int)(header[23] << 8) | header[22];

   // Read in the image
   int size = w * h;
   if (fread(data, sizeof(struct pixel), size, f) != size){
		printf("Error reading BMP image\n");
		return -1;
   }   

   *width = w;
   *height = h;
   return 0;
}

// Write the grayscale image to disk.
void write_bmp(const char *filename, unsigned char* header, struct pixel* data) 
{
   FILE* file = fopen(filename, "wb");

   // get height and width of image
   int width = (int)(header[19] << 8) | header[18];
   int height = (int)(header[23] << 8) | header[22];
   int size = width * height;
   
   // write the 54-byte header
   fwrite(header, sizeof(unsigned char), 54, file); 
   fwrite(data, sizeof(struct pixel), size, file); 
   
   fclose(file);
}


void highlight_image(struct pixel * data, int height, int width, struct pixel * img_out) 
{
    for (int y = 0; y < height; y++) 
    {
        for (int x = 0; x < width; x++) 
        {
            img_out[y * width + x] = data[y * width + x];
            if (check_pixel_box(x, y))
            {
               img_out[y * width + x].r = 0xff;
               img_out[y * width + x].g = 0x00;
               img_out[y * width + x].b = 0x00;
            }
        }
    }
}


int main(int argc, char *argv[]) 
{
	struct pixel *base_frame = (struct pixel *)malloc(768*576*sizeof(struct pixel));
	struct pixel *out_frame = (struct pixel *)malloc(768*576*sizeof(struct pixel));
	unsigned char header[64];
	int height, width;

	FILE * base_file = fopen("base.bmp","rb");
	if ( base_file == NULL ) return 0;

	// read the bitmap
	read_bmp(base_file, header, &height, &width, base_frame);

	highlight_image(base_frame, height, width, out_frame);
	write_bmp("img_out.bmp", header, out_frame);

	return 0;
}



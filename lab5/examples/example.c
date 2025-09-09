#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "image.h"

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_ONLY_PNG

#include "stb_image.h"
#include "stb_image_write.h"

int main(int argc, char * argv[]){
        long png=0x0a1a0a0d474e5089;
        char buf[8];
        FILE * f;
        struct timespec t, t1, t2;
        void * imgfrom, * imgto;
        int x, y, n, x1, y1, x2, y2, new_width, new_height;

        //проверяем кол-во аргументов
        if (argc != 8){
                fprintf(stderr, "Usage: %s input.png output_c.png output_asm.png x1 y1 x2 y2\n", argv[0]);
                return 1;
        }

        //проверка на открытие файла
        if ((f=fopen(argv[1], "r"))==NULL){
                perror(argv[1]);
                return 1;
        }
        fread(buf, 1, sizeof(long), f);
        fclose(f);

        //проверяем сигнатуру PNG
        if (*(long *)buf!=png){
                fprintf(stderr, "%s - not correct signature png_file\n", argv[1]);
                return 1;
        }

        //считываем байты PNG
        if ((imgfrom=stbi_load(argv[1], &x, &y, &n, 4))==NULL){
                fprintf(stderr, "%s - not correct png_file\n", argv[1]);
                return 1;
        }
        printf("Image loads: %d*%d pixels, %d channels\n", x, y, n);

        //получаем координаты
        x1 = atoi(argv[4]);
        y1 = atoi(argv[5]);
        x2 = atoi(argv[6]);
        y2 = atoi(argv[7]);

        //проверяем координаты
        if (x1 < 0 || x2 >= x || y1 < 0 || y2 >= y || x1 > x2 || y1 > y2) {
                fprintf(stderr, "Invalid crop coordinates\n");
                stbi_image_free(imgfrom);
                return 1;
        }

        new_width = x2 - x1 + 1;
        new_height = y2 - y1 + 1;

        //выделяем память под обрезанное изображение
        imgto = malloc(new_width * new_height * 4);
        if (!imgto) {
                fprintf(stderr, "Memory allocation failed\n");
                stbi_image_free(imgfrom);
                return 1;
        }

        //C версия
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
        work_image_c(imgfrom, imgto, x, y, x1, y1, x2, y2);
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
        t.tv_sec=t2.tv_sec-t1.tv_sec;
        if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
                t.tv_sec--;
                t.tv_nsec+=1000000000;
        }
        printf("C: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
        if (stbi_write_png(argv[2], new_width, new_height, 4, imgto, new_width * 4) == 0)
                printf("Cannot write image_c to file\n");

        memset(imgto, 0, new_width * new_height * 4);

        //asm версия
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
        work_image_asm(imgfrom, imgto, x, y, x1, y1, x2, y2);
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
        t.tv_sec=t2.tv_sec-t1.tv_sec;
        if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
                t.tv_sec--;
                t.tv_nsec+=1000000000;
        }
        printf("Asm: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
        if (stbi_write_png(argv[3], new_width, new_height, 4, imgto, new_width * 4) == 0)
                printf("Cannot write image_asm to file\n");

        //освобождаем память
        free(imgfrom);
        free(imgto);
        return 0;
}


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stddef.h>
#include "image.h"

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_ONLY_JPEG

#include "stb_image.h"
#include "stb_image_write.h"


static void create_tmp_image(unsigned char *src, unsigned char *dst, size_t w, size_t h) {
    size_t tmp_w = w + 2;
    size_t row_size = w * 4; // байтов в строке исходника

    // Заполняем центр (строка за строкой)
    for (size_t y = 0; y < h; y++) {
        memcpy(dst + (y + 1) * tmp_w * 4 + 4, 
               src + y * row_size, 
               row_size);

        // Дублируем левый и правый пиксели на этой строке
        unsigned char *src_row = src + y * row_size;
        unsigned char *dst_row = dst + (y + 1) * tmp_w * 4;
        memcpy(dst_row, src_row, 4);                    // левый пиксель
        memcpy(dst_row + (w + 1) * 4, src_row + (w-1)*4, 4); // правый пиксель
    }

    // Верхняя строка (копия первой строки исходника)
    memcpy(dst + 4, src, row_size);                                // центр
    memcpy(dst, src, 4);                                           // угол слева
    memcpy(dst + (w+1)*4, src + (w-1)*4, 4);                       // угол справа

    // Нижняя строка (копия последней строки исходника)
    unsigned char *src_last = src + (h-1)*row_size;
    unsigned char *dst_last = dst + (h+1)*tmp_w*4;
    memcpy(dst_last + 4, src_last, row_size);                      // центр
    memcpy(dst_last, src_last, 4);                                 // угол слева
    memcpy(dst_last + (w+1)*4, src_last + (w-1)*4, 4);             // угол справа
}


int main(int argc, char * argv[]){
    if (argc != 4){
        fprintf(stderr, "Usage: %s input.jpg output_c.jpg output_asm.jpg\n", argv[0]);
        return 1;
    }

    const char *infile = argv[1];
    const char *out_c = argv[2];
    const char *out_asm = argv[3];

    int w = 0;
    int h = 0;
    int n = 0;
    void *img = stbi_load(infile, &w, &h, &n, 4);
    if (!img) {
        fprintf(stderr, "Cannot load '%s'\n", infile);
        return 1;
    }
    printf("Loaded: %s (%d x %d), channels in file: %d -> using 4 (RGBA)\n", infile, w, h, n);

    int tmp_w = w + 2;
    int tmp_h = h + 2;
    size_t tmp_size = (size_t)tmp_w * tmp_h * 4;
    size_t output_size = (size_t)w * h * 4;

    unsigned char *tmp_image = malloc(tmp_size);
    if (!tmp_image) {
        fprintf(stderr, "Memory allocation failed\n");
        stbi_image_free(img);
        return 1;
    }
    memset(tmp_image, 0, tmp_size);
    create_tmp_image((unsigned char *)img, tmp_image, w, h);

    unsigned char *dst = malloc(output_size);
    if (!dst) {
        fprintf(stderr, "Memory allocation failed\n");
        free(tmp_image);
        stbi_image_free(img);
        return 1;
    }

    struct timespec t1, t2, dt;

    //C version
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
    work_image_c(tmp_image, dst, tmp_w, tmp_h, w, h);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
    dt.tv_sec = t2.tv_sec - t1.tv_sec;
    dt.tv_nsec = t2.tv_nsec - t1.tv_nsec;
    if (dt.tv_nsec < 0) { dt.tv_sec--; dt.tv_nsec += 1000000000; }
    printf("C time: %ld.%09ld\n", dt.tv_sec, dt.tv_nsec);
    if (!stbi_write_jpg(out_c, w, h, 4, dst, 95)) {
        fprintf(stderr, "Cannot write %s\n", out_c);
    }

    //zero into buffer before asm
    memset(dst, 0, output_size);

    //ASM version
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
    work_image_asm(tmp_image, dst, tmp_w, tmp_h, w, h);
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
    dt.tv_sec = t2.tv_sec - t1.tv_sec;
    dt.tv_nsec = t2.tv_nsec - t1.tv_nsec;
    if (dt.tv_nsec < 0) { dt.tv_sec--; dt.tv_nsec += 1000000000; }
    printf("ASM time: %ld.%09ld\n", dt.tv_sec, dt.tv_nsec);
    if (!stbi_write_jpg(out_asm, w, h, 4, dst, 95)) {
        fprintf(stderr, "Cannot write %s\n", out_asm);
    }

    free(tmp_image);
    free(dst);
    stbi_image_free(img);
    return 0;
}

#include <stdint.h>
#include <stddef.h>
#include "image.h"

void work_image_c(void *tmp_src, void *dst, int tmp_w, int tmp_h, int orig_w, int orig_h) {
    unsigned char *ts = (unsigned char *)tmp_src;
    unsigned char *out = (unsigned char *)dst;

    //свёртка 3x3
    int kernel[3][3] = {
        {-1, -1, -1},
        {-1,  8, -1},
        {-1, -1, -1}
    };

    for (int y = 0; y < orig_h; y++) {
        for (int x = 0; x < orig_w; x++) {
            int sum[3] = {0,0,0};
            // проход по окрестности 3x3
            for (int ky = -1; ky <= 1; ky++) {
                for (int kx = -1; kx <= 1; kx++) {
                    int coeff = kernel[ky+1][kx+1];
                    unsigned char *p = ts + ((size_t)(y+1+ky)*tmp_w + (x+1+kx))*4;
                    sum[0] += coeff * p[0];
                    sum[1] += coeff * p[1];
                    sum[2] += coeff * p[2];
                }
            }
            // адрес выходного пикселя
            unsigned char *d = out + ((size_t)y*orig_w + x)*4;
            // обрезка и запись
            for (int c = 0; c < 3; c++) {
                if (sum[c] < 0) sum[c] = 0;
                if (sum[c] > 255) sum[c] = 255;
                d[c] = (unsigned char)sum[c];
            }
            // альфа — без изменений
            unsigned char *center = ts + ((size_t)(y+1)*tmp_w + (x+1))*4;
            d[3] = center[3];
        }
    }
}


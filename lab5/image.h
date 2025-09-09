#ifndef IMAGE
#define IMAGE

void work_image_c(void *tmp_src, void *dst, int tmp_w, int tmp_h, int orig_w, int orig_h);
void work_image_asm(void *tmp_src, void *dst, int tmp_w, int tmp_h, int orig_w, int orig_h);

#endif


void work_image_c(void *src, void *dst, int src_width, int src_height,
                  int x1, int y1, int x2, int y2) {
        unsigned char *src_pixels = (unsigned char *)src;
        unsigned char *dst_pixels = (unsigned char *)dst;

        int dst_width = x2 - x1 + 1;
        int dst_height = y2 - y1 + 1;

        for (int y_dst = 0; y_dst < dst_height; y_dst++) {
                for (int x_dst = 0; x_dst < dst_width; x_dst++) {
                        //координаты в исходном изображении
                        int x_src = x1 + x_dst;
                        int y_src = y1 + y_dst;

                        //проверка на выход за границы (на случай ошибок)
                        if (x_src >= src_width || y_src >= src_height) continue;

                        //копируем 4 канала (RGBA)
                        for (int c = 0; c < 4; c++) {
                                dst_pixels[(y_dst * dst_width + x_dst) * 4 + c] = src_pixels[(y_src * src_width + x_src) * 4 + c];
            }
        }
    }
}


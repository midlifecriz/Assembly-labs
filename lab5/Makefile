AS = /usr/bin/nasm
LD = /usr/bin/ld

CCFLAGS = -c -Ofast
ASFLAGS = -g -f elf64
LDFLAGS = -static -z noexecstack

LIBS = -lm    # math library must go last

SRCS = lab.c image.c imageasm.s
OBJS = lab.o image.o imageasm.o
HEAD = image.h stb_image.h stb_image_write.h
EXE = lab

all: $(EXE)

$(EXE): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $(EXE) $(LIBS)

lab.o: lab.c $(HEAD)
	$(CC) $(CCFLAGS) lab.c -o lab.o

image.o: image.c $(HEAD)
	$(CC) $(CCFLAGS) image.c -o image.o

imageasm.o: imageasm.s
	$(AS) $(ASFLAGS) imageasm.s -o imageasm.o

clean:
	rm -f $(EXE) $(OBJS)


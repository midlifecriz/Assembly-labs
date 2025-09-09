AS = /usr/bin/nasm
LD = /usr/bin/ld

CC = gcc

ASFLAGS = -g -f elf64
LDFLAGS = -no-pie -z noexecstack

SRCS = lab.s
OBJS = $(SRCS:.s=.o)

EXE = lab

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -lm -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@


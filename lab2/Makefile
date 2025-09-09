AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

EXE = lab

all: ascending

ascending: ascending.o
	$(LD) $(LDFLAGS) $< -o $(EXE)

descending: descending.o
	$(LD) $(LDFLAGS) $< -o $(EXE)

ascending.o: ascending_sort.s
	$(AS) $(ASFLAGS) $< -o $@

descending.o: descending_sort.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -rf $(EXE) *.o


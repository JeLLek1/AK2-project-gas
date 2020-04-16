AS_FLAGS = -g --32		#flagi 32 bit komendy as
LD_FLAGS = -m elf_i386		#flagi 32 bit komendy ld

S_FILES := $(wildcard src/*.s)	#pliki GAS
O_FILES := $(S_FILES:.s=.o)	#pliki object
KERNEL_BIN := prime		#plik wynikowy

all: $(KERNEL_BIN)

clean:
	rm -f $(KERNEL_BIN) $(O_FILES)

$(KERNEL_BIN): $(O_FILES)
	$(LD) $(LD_FLAGS) -o $@ $^

%.o: %.s
	$(AS) $(AS_FLAGS) -o $@ $<

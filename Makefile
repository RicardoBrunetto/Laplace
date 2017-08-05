FILE=linear_float

all: clear

montagem:
	@as -32 $(FILE).s -o $(FILE).o
	@ld -m elf_i386 $(FILE).o -l c -dynamic-linker /lib/ld-linux.so.2 -o $(FILE)

clear: montagem
	@\rm *.o
	@echo "\nMontagem concluída com sucesso!\n"

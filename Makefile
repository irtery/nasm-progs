SOURCES=read_number.asm print_number.asm catn.asm
OBJECTS=$(SOURCES:.asm=.o)
EXECUTABLE=catn

$(EXECUTABLE): $(OBJECTS)
	ld -macosx_version_min 10.7.0 $(OBJECTS) -o $@

catn.o: catn.asm
	nasm -f macho catn.asm -g -l catn.lst

read_number.o: read_number.asm
	nasm -f macho read_number.asm -g -l read_number.lst

print_number.o: print_number.asm
	nasm -f macho print_number.asm -g -l print_number.lst

clean:
	rm *.o
	rm $(EXECUTABLE)

run: $(EXECUTABLE)
	./$(EXECUTABLE) source.txt destination.txt

SOURCES=read_number.asm print_number.asm sum.asm
OBJECTS=$(SOURCES:.asm=.o)
EXECUTABLE=sum

$(EXECUTABLE): $(OBJECTS)
	ld -macosx_version_min 10.7.0 $(OBJECTS) -o $@

sum.o: sum.asm 
	nasm -f macho sum.asm -g -l sum.lst

read_number.o: read_number.asm 
	nasm -f macho read_number.asm -g -l read_number.lst

print_number.o: print_number.asm 
	nasm -f macho print_number.asm -g -l print_number.lst

clean:
	rm *.o
	rm $(EXECUTABLE)

run: $(EXECUTABLE)
	./$(EXECUTABLE) 3 -4 5 2 -1

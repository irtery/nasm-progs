SOURCES=read_number.asm print_number.asm quadratic_equation.asm
OBJECTS=$(SOURCES:.asm=.o)
EXECUTABLE=quadratic_equation

$(EXECUTABLE): $(OBJECTS)
	ld -macosx_version_min 10.7.0 $(OBJECTS) -o $@

quadratic_equation.o: quadratic_equation.asm 
	nasm -f macho quadratic_equation.asm -g -l quadratic_equation.lst

read_number.o: read_number.asm 
	nasm -f macho read_number.asm -g -l read_number.lst

print_number.o: print_number.asm 
	nasm -f macho print_number.asm -g -l print_number.lst

clean:
	rm *.o
	rm $(EXECUTABLE)

run: $(EXECUTABLE)
	./$(EXECUTABLE)

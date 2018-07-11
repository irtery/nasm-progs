hello_world.o: hello_world.asm
	nasm -f macho hello_world.asm

hello_world: hello_world.o
	ld -macosx_version_min 10.7.0 -o hello_world hello_world.o

clean:
	rm *.o
	rm hello_world

run: hello_world
	./hello_world

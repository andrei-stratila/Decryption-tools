decryption-tools: decryption-tools.asm
	nasm -f elf32 -o decryption-tools.o $<
	gcc -m32 -o $@ decryption-tools.o

run-XOR:
	@cp examples/input1.dat .
	@./decryption-tools 1 
	@rm input1.dat
run-rollingXOR:
	@cp examples/input2.dat .
	@./decryption-tools 2 
	@rm input2.dat
run-hexaXOR:
	@cp examples/input3.dat .
	@./decryption-tools 3 
	@rm input3.dat
run-base32:
	@cp examples/input4.dat .
	@./decryption-tools 4 
	@rm input4.dat
run-bruteforce:
	@cp examples/input5.dat .
	@./decryption-tools 5 
	@rm input5.dat
run-vigenere:
	@cp examples/input6.dat .
	@./decryption-tools 6
	@rm input6.dat
clean:
	rm -f decryption-tools decryption-tools.o

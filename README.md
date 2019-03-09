# Decryption-tools
  
An assembly x86 program that implements six decryption tools: 
1. XOR between two strings
2. Rolling XOR
3. XOR between two hexadecimal strings
4. Decrypt string in base32
5. Bruteforce on XOR with one byte key
6. Vigenere Cypher

## Installation
```
git clone https://github.com/andrei-stratila/Decryption-tools.git
cd Decryption-tools && make
```

## How it works!
If you want to run the executable on examples, you should use the below commands: 
```
make run-XOR
make run-rollingXOR
make run-hexaXOR
make run-base32
make run-bruteforce
make run-vigenere
````
Running on custom input is done by having the input file in the same directory with the executable. The name of the input file should be input<*Number of tool you want to use(1-6)*>.dat.
```
./decryption-tools <tool-number>
```

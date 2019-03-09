extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

formatPrintf:		  db "%d", 0
fmtstr:						db "Key: %d",0xa, 0
usage:						 db "Usage: %s <tool-no> (tool-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:		 db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

;###
;##### TOOL 1 - BEGIN #####
xor_strings:
		push ebp
		mov ebp, esp
		
		mov edi, [ebp + 8]			; edi contains the strings
		xor edx, edx 				; edx = 0, size of string

reach_key_1:					; Parse the string till the begin of key 
		mov bl, byte [edi + edx]	; bl has a byte from string
		inc edx 					; increment size of string
		cmp bl, 0 					; if bl is 0 then we reach end of string
		jne reach_key_1

parse_strings_1:				; Parse both strings and xor them
		mov bl, byte [edi]			; bl has a byte from string
		xor bl, byte [edi + edx]	; xor between bl and correspondent from key
		mov byte [edi], bl 			; Update the byte in string with xored value
		inc edi 					; Increment size
		cmp bl, 0 					; continue till the end of key
		jne parse_strings_1
		
		pop ebp
		ret
;##### TOOL 1 - END #####
;###



;###
;##### TOOL 2 - BEGIN #####
rolling_xor:
		push ebp
		mov ebp, esp
		
		mov ecx, [ebp + 8]		; ecx contains the strings
		xor edx, edx 			; edx = 0 size of string
		  
length_2:					; Find lenght of string
		mov bl, byte [ecx + edx]
		inc edx 				; Increment size of string (edx)
		cmp bl, 0				; until bl equals to 0
		jne length_2

		dec edx
		mov esi,1				; esi = 1 (first byte of decyphered string)
reverse_parse_2:
		xor al, al 				; Initialize al = 0
		xor edi, edi 			; Initialize edi = 0
parse_strings_2:
		mov bl, byte [ecx + edi]	; bl has a byte from string
		xor al, bl 					; xor al with bl
		inc edi 					; increment size
		cmp edi, esi 				; parse until edi == esi
		jnz parse_strings_2
 
		xor byte [ecx + esi], al; Update new value in string
		inc esi 				; Increment esi (byte of decyphered string)
		cmp esi, edx 			; Continue till esi == size of string
		jne reverse_parse_2
				
		pop ebp
		ret
;##### TOOL 2 - END #####
;###



;###
;##### TOOL 3 - BEGIN #####
xor_hex_strings:
		push ebp
		mov ebp, esp
		
		mov edi, [ebp + 8]		; edi contains the strings
		xor edx, edx 			; edx = 0 size of string
		xor esi, esi 			; esi = 0 size of hex string

STRING_convert_ASCII_to_HEX:	; Convert ASCII string to hex values
		mov ah, byte [edi + edx]	; Take first nibble
		inc edx 					; Increment size of string
		cmp ah, 0 					; Test if we reach the end of string 
		je out_string_3 			; Jump to the part where we convert the key

		mov al, byte [edi + edx] 	; Take second nibble
		inc edx 					; Increment size of string
		
		cmp ah, '9' 				; If ah is greater than '9'
		jg STRING_A_F_upper			; then ah is 'A','B','C','D','E' or 'F'
		sub ah, '0'					; else ah is '0' - '9' => ah = ah - '0' 
		jmp STRING_out_upper		; jump Done converting AH
STRING_A_F_upper:
		sub ah, 87 					; ah = ah ('A' - 'F') - 87 = 10 - 15
STRING_out_upper:		


		cmp al, '9'					; Repeat the steps from ah for al
		jg STRING_A_F_lower
		sub al, '0'
		jmp STRING_out_lower
STRING_A_F_lower:
		sub al, 87

STRING_out_lower:
		shl ah, 4					; Create the hex value
		add ah, al 					; from ASCII 
		mov byte [edi + esi], ah 	; Update value in hex (ah) in the string
		inc esi 					; Increment size of hex string
		jmp STRING_convert_ASCII_to_HEX
out_string_3:
		mov byte [edi + esi], 0		; Add 0 at the end of the string
		inc esi 					; Increment size of hex string


KEY_convert_ASCII_to_HEX:		; Convert ASCII key to hex values
		mov ah, byte [edi + edx]	; Repeat the previous algorithm 
		inc edx
		cmp ah, 0
		je out_key_3
		
		mov al, byte [edi + edx]
		inc edx
		
		cmp ah, '9'
		jg KEY_A_F_upper
		sub ah, '0'
		jmp KEY_out_upper
KEY_A_F_upper:
		sub ah, 87 
KEY_out_upper:		
		

		cmp al, '9'
		jg KEY_A_F_lower
		sub al, '0'
		jmp KEY_out_lower
KEY_A_F_lower:
		sub al, 87
KEY_out_lower:

		shl ah, 4
		add ah, al
		mov byte [edi + esi], ah
		inc esi
		jmp KEY_convert_ASCII_to_HEX
out_key_3:
		mov byte [edi + esi], 0
		inc esi



		xor edx, edx 				; edx = 0, size of key
get_key_length_3: 				; Compute key length
		mov bl, byte [edi + edx]
		inc edx
		cmp bl, 0
		jne get_key_length_3
		
		xor esi, esi 				; esi = 0, index for parsing string
xor_hex_strings_3:
		mov al, byte [edi + esi]	; byte from string
		mov bl, byte [edi + edx]	; byte from key
		xor al, bl 					; xor them
		mov byte [edi + esi], al 	; Update value in string
		inc esi
		inc edx
		cmp al, 0
		jne xor_hex_strings_3
		
		pop ebp
		ret
;##### TOOL 3 - END #####
;###



;###
;##### TOOL 4 - START #####
base32decode:
		push ebp
		mov ebp, esp
		sub esp, 4 					; Allocate space for local variable
		
		mov ecx, [ebp + 8] 			; ecx contains the string
		
		xor edi, edi
parse_STRING_4: 				; Parse the entire string
		xor edx, edx 				; edx = 0
		xor eax, eax 				; eax = 0
		xor ebx, ebx 				; ebx = 0
		
		mov esi, 8 					; esi = 8, number of ASCII to compute
parse_8_ASCII_4: 				; Compute 8 values ASCII to decypher them
		xor edx, edx 				; edx = 0, register used to store byte
		mov dl, byte [ecx + edi] 	; dl contains a byte from those 8 
		cmp dl, 0 					; Test for end of string
		je end_ofString_4

		cmp dl, '=' 				; Test for padding char
		je equalSign
		cmp dl, 'A' 				; Test if not letter
		jl notLetter_4
		sub dl, 'A' 				; If letter, dl = dl (A - Z) - 'A'
		jmp done_converting_ASCII_4

notLetter_4: 					; If not letter, then is a digit
		sub dl, '2' 				; dl = dl ('2' - '7') - '2'
		add dl, 26 					; 26 = value of 2 in Base32 table
		jmp done_converting_ASCII_4
equalSign: 						; If equal sign for padding
		xor dl, dl
done_converting_ASCII_4:
   
		;Store in eax and bl all the bits (8 values[5bits]->40 bits): 32-eax and 8-bl
		;First 6 values and 2 bits from the 7th value are stored in eax
		;Last char and 3 bits from the 7th value are stored in bl
		cmp esi, 2				; Test if we reached the last two values
		je lastTwo_Values
		cmp esi, 1				; Test if we reached the last value 
		je lastOne_Value

		add eax, edx 			
		cmp esi, 3				; If eax is full (we added the first 5 chars)
		je done_saving_Nibbles
		shl eax, 5 				; If not full, shift the bits to the left
		jmp done_saving_Nibbles

lastTwo_Values: 				; The second to last value is splitted
		push edx 				; Save value of edx on stack
		shr edx, 3 				; Save the first 2 bits from edx
		shl eax, 2 				; And add them to eax
		add eax, edx 			; now eax is full
		
		pop edx 				; Restore value of edx 
		and edx, 7 				; Save the last 3 bits from edx 
		add bl, dl 				; And add them to bl
		shl ebx, 5						  ; Make space for last value in bl
		jmp done_saving_Nibbles

lastOne_Value: 					; Add the last value in bl
		add bl, dl

done_saving_Nibbles:
		inc edi 				; increment index for the entire string
		dec esi 				; decrement size of 8 ASCII string
		cmp esi, 0
		jne parse_8_ASCII_4
		

		mov esi, dword [ebp -4]		; local variable = size of final string
   
		push eax 					; Save value of eax
		shr eax, 16 				; Take 2 decyphered values from eax
		mov byte [ecx + esi + 0], ah		
		mov byte [ecx + esi + 1], al
		pop eax 					; Restore eax and take the other 2 from eax
		mov byte [ecx + esi + 2], ah		
		mov byte [ecx + esi + 3], al
		mov byte [ecx + esi + 4], bl; Take decyphered value from bl
		add esi, 5 					; Update size of decyphered string
		
		mov dword [ebp - 4], esi 	; Save value of local var on stack
		
		jmp parse_STRING_4
end_ofString_4: 
		
		leave
		ret
;##### TOOL 4 - END #####
;###


;###
;##### TOOL 5 - BEGIN #####
bruteforce_singlebyte_xor:
		push ebp
		mov ebp, esp
		
		mov ecx, [ebp + 8]			; ecx contains the string
		xor eax, eax 				; 
		mov al, 255					; al = value of key to be tried

try_key_bruteforce:
		mov edi, ecx 				; Store string in edi
		xor edx, edx 				; edx = index for string parsing
		
parse_String_5:
		mov bl, byte [edi + edx]; Store byte from string in bl
		inc edx 				; Increment index
		cmp bl, 0 				; Test for end of string
		je out_parse_String_5
		xor bl, al 				; Xor byte from string with key
		cmp bl, 'f' 			; Compare bl with known pattern
		jne not_yet 			
		
		; Repeat the previous algorithm 4 more time to check for pattern "force"
		mov bl, byte [edi + edx]
		inc edx
		cmp bl, 0
		je out_parse_String_5
		xor bl, al
		cmp bl, 'o'
		jne not_yet
		
		mov bl, byte [edi + edx]
		inc edx
		cmp bl, 0
		je out_parse_String_5
		xor bl, al
		cmp bl, 'r'
		jne not_yet
		
		mov bl, byte [edi + edx]
		inc edx
		cmp bl, 0
		je out_parse_String_5
		xor bl, al
		cmp bl, 'c'
		jne not_yet
		
		mov bl, byte [edi + edx]
		inc edx
   		cmp bl, 0
		je out_parse_String_5
		xor bl, al
		cmp bl, 'e'
		jne not_yet
		
		; If we reach this zone we found the key
		xor edx, edx 			; index for parsing = 0
		jmp found_key
not_yet:
		jmp parse_String_5 		; Continue parsing string with al key

out_parse_String_5:
		inc al 						; Change key
		jmp try_key_bruteforce

   
found_key: 						; Key found
		mov bl, byte [ecx + edx] 	; bl byte from string
		cmp bl, 0 					; Check if end of string
		je done_4
		xor bl, al 					; xor byte with key
		mov byte [ecx + edx], bl 	; Update value in string
		inc edx		   				; Increment index
		jmp found_key
done_4:
		pop ebp
		ret 
;##### TOOL 5 - END #####
;###



;### 
;##### TOOL 6 - BEGIN #####
decode_vigenere:
		push ebp
		mov ebp, esp
		
		
		mov ecx, [ebp + 8]			; ecx contains string
		mov eax, [ebp + 12]				 ; eax contains key
		xor esi, esi   				; index for string
		xor edi, edi						; index for key
parse_String_6:
		mov bl, byte [ecx + esi] 	; Store byte from string in bl
		cmp bl, 0 					; Check if end of string
		je out_parse_String_6
		cmp bl, 'a' 				; Check if not letter
		jl notLetter_6
		cmp bl, 'z' 				; Check if not letter
		jg notLetter_6
		
take_byte_Key_6: 				; If letter then
		mov dl, byte [eax + edi] 	; Store byte from key in dl
		inc edi 					; Increment index of key
		cmp dl, 0 					
		jne not_endOfKey_6
		xor edi, edi 				; If we reached the end of key
		jmp take_byte_Key_6 		; index of key(edi) = 0
not_endOfKey_6:

		sub dl, 'a' 				; Decypher byte from string 
		sub bl, dl 					; Using byte from key
		cmp bl, 'a'
		jge done_byte_6
		add bl, 26

done_byte_6:
		mov byte [ecx + esi], bl 	; Update byte in string
		
notLetter_6: 					; Continue parsing
		inc esi 					; Increment index of string
		jmp parse_String_6
		
out_parse_String_6:
		pop ebp	
		ret
;##### TOOL 6 - END #####
;###


main:
		mov ebp, esp; for correct debugging
		push ebp
		mov ebp, esp
		sub esp, 2300

		; test argc
		mov eax, [ebp + 8]
		cmp eax, 2
		jne exit_bad_arg

		; get tool no
		mov ebx, [ebp + 12]
		mov eax, [ebx + 4]
		xor ebx, ebx
		mov bl, [eax]
		sub ebx, '0'
		push ebx

		; verify if tool no is in range
		cmp ebx, 1
		jb exit_bad_arg
		cmp ebx, 6
		ja exit_bad_arg

		; create the filename
		lea ecx, [filename + 7]
		add bl, '0'
		mov byte [ecx], bl

		; fd = open("./input{i}.dat", O_RDONLY):
		mov eax, 5
		mov ebx, filename
		xor ecx, ecx
		xor edx, edx
		int 0x80
		cmp eax, 0
		jl exit_no_input

		; read(fd, ebp - 2300, inputlen):
		mov ebx, eax
		mov eax, 3
		lea ecx, [ebp-2300]
		mov edx, [inputlen]
		int 0x80
		cmp eax, 0
		jl exit_cannot_read

		; close(fd):
		mov eax, 6
		int 0x80

		; all input{i}.dat contents are now in ecx (address on stack)
		pop eax
		cmp eax, 1
		je tool1
		cmp eax, 2
		je tool2
		cmp eax, 3
		je tool3
		cmp eax, 4
		je tool4
		cmp eax, 5
		je tool5
		cmp eax, 6
		je tool6
		jmp tool_done

tool1:
		push ecx
		call xor_strings
		add esp, 4

		push ecx
		call puts								   ;print resulting string
		add esp, 4

		jmp tool_done

tool2:
		push ecx
		call rolling_xor
		add esp, 4
		
		push ecx
		call puts
		add esp, 4

		jmp tool_done

tool3:
		push ecx
		call xor_hex_strings
		add esp, 4
		   
		push ecx										 ;print resulting string
		call puts
		add esp, 4

		jmp tool_done

tool4:
		push ecx
		call base32decode
		add esp, 4	

		push ecx
		call puts										;print resulting string
		pop ecx
		
		jmp tool_done

tool5:
		push ecx
		call bruteforce_singlebyte_xor
		add esp, 4				
		
		mov esi, eax
		
		push ecx										;print resulting string
		call puts
		pop ecx
		 
		mov eax, esi
		
		push eax										;eax = key value
		push fmtstr
		call printf								 ;print key value
		add esp, 8

		jmp tool_done

tool6:

		push ecx
		call strlen
		pop ecx

		add eax, ecx
		inc eax

		push eax
		push ecx								   ;ecx = address of input string 
		call decode_vigenere
		pop ecx
		add esp, 4

		push ecx
		call puts
		add esp, 4

tool_done:
		xor eax, eax
		jmp exit

exit_bad_arg:
		mov ebx, [ebp + 12]
		mov ecx , [ebx]
		push ecx
		push usage
		call printf
		add esp, 8
		jmp exit

exit_no_input:
		push filename
		push error_no_file
		call printf
		add esp, 8
		jmp exit

exit_cannot_read:
		push filename
		push error_cannot_read
		call printf
		add esp, 8
		jmp exit

exit:
		mov esp, ebp
		pop ebp
		ret

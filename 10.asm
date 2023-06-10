**#############-------------#############-------------################**
METHOD 1- ADD AND SHIFT METHOD
**#############-------------#############-------------################**

section .data
	msg1 db 10,10,'***Multiplication by add & shift***'
	msg1_len equ $-msg1
	msg2 db 10,'Enter two digit number: ' 
	msg2_len equ $-msg2
	msg3 db 10,'Multiplication is: '
	msg3_len equ $-msg3

section .bss
	numascii resb 03            ; reserve 3 byte for numascii
	multi1 resb 02              ; reserve 2 byte for multi1
	multi2 resb 02              ; reserve 2 byte for multi2
	resl resb 02                ; reserve 2 byte for resl
	dispbuff resb 04            ; reserve 4 byte for dispbuff
	
%macro dispmsg 2          ; macro dispmsg of length 2
	mov eax,04        ; 4 indicates sys_write-->display
	mov ebx,01        ; move 1 to ebx
	mov ecx,%1        ; call the first parameter
	mov edx,%2        ; call the second parameter
	int 80h           ; interrupt to call the system
%endmacro

%macro accept 2           ; macro accept of length 2
	mov eax,03        ; 3 indicates sys_read--->accept input
	mov ebx,00        ; move 0 to ebx
	mov ecx,%1        ; call the first parameter
	mov edx,%2        ; call the second parameter
	int 80h	          ; interrupt to call the system
%endmacro

section .text
global _start
_start:
	dispmsg msg1,msg1_len
	dispmsg msg2,msg2_len
	accept numascii,03
	call packnum
	mov [multi1],bl
	dispmsg msg2,msg2_len
	accept numascii,03
	call packnum
	mov [multi2],bl
	mov al,[multi1]
	mov cl,00
	mov edx,00
	mov edx,08

	add1:
		rcr al,01              ; rotate with carry right by 1 
		jnc next1              ; jump if not carry to next1 method
		mov bh,00h             ; move 0 to bh (higher byte)
		shl bx,cl	       ; shl=shift left, cl to bx 
		add [resl],bx          ; add bx with the content at effective address of resl 
		mov bl,[multi2]        ; move content of effective address of multi2 to bl
	next1:
		inc cl                 ; increment cl
		dec edx                ; decrement edx
		jnz add1               ; jump if not zero to add1 method
		dispmsg msg3,msg3_len  ; display message for multiplication result
		mov bx,[resl]          ; move content at effective address of resl to bx
		call disp16            ; call disp16 method
		mov eax,01   	       ; 1 indicates sys_exit
		mov ebx,00             ; move 0 to ebx
		int 80h                ; interrupt to call the system(similar to syscall)
	
	packnum:
		mov bl,00              ; move 0 to bl(lower byte)
		mov ecx,02             ; move 2 to ecx
		mov esi,numascii       ; move the numascii to source index

	up1:    ; method for ascii to hex conversion
		rol bl,04
		mov al,[esi]
		cmp al,39h
		jbe skip1
		sub al,07h
		
	skip1:
		sub al,30h
		add bl,al
		inc esi
		loop up1
		ret

	disp16:
		mov ecx,4        ; 4 indicates sys_write
		mov edi,dispbuff ; move dispbuff to destination index

	dub1:    ;method for hex to ascii conversion
		rol bx,4
		mov al,bl
		and al,0fh
		cmp al,09h
		jbe x1
		add al,07
	x1:
		add al,30h
		mov [edi],al
		inc edi
		loop dub1
		dispmsg dispbuff,4
	ret 



**#############-------------#############-------------################**
//METHOD 2- SUCCESSIVE ADDITION
**#############-------------#############-------------################**

section .data
	msg1 db 10,10,'***Multiplication by successive addition***'
	msg1_len equ $-msg1
	msg2 db 10,10,'Enter two digit number: ' 
	msg2_len equ $-msg2
	msg3 db 10,10,'Multiplication is: '
	msg3_len equ $-msg3

section .bss
	numascii resb 03          
	multi1 resb 02
	resl resb 02
	resh resb 01
	dispbuff resb 04
	
%macro dispmsg 2   
	mov eax,04
	mov ebx,01
	mov ecx,%1
	mov edx,%2
	int 80h
%endmacro

%macro accept 2
	mov eax,03
	mov ebx,00
	mov ecx,%1
	mov edx,%2
	int 80h	
%endmacro

section .text
global _start
_start:
	dispmsg msg1,msg1_len
	dispmsg msg2,msg2_len          ; display message to enter 2 digit number
	accept numascii,03             ; accept number from user
	call packnum                   ; call packnum method
	mov [multi1],bl                ; move bl to the effective address of multi1 
	dispmsg msg2,msg2_len          ; display message to enter 2 digit number
	accept numascii,03             ; accept number from user
	call packnum                   ; call packnum method
	mov ecx,00h                    ; move 0 to ecx
	mov eax,[multi1]               ; move the content present at effective address of multi1 to eax
	add1:        ; method to add the given numbers
		add ecx,eax             ; add eax and ecx
		dec bl                  ; decrement bl
		jnz add1		; checks bl is 0 or not
		mov [resl],ecx          ; move ecx to the effective address of resl 

		dispmsg msg3,msg3_len   ; display message for multiplication result
		mov ebx,[resl]          ; move the content present at effective address of resl to ebx
		call disp16             ; call disp16 method
		mov eax,01              ; 1 indicates sys_exit
		mov ebx,00              ; move 0 to the ebx
		int 80h                 ; interrupt 80 call the system (similar to syscall)
	
	packnum:
		mov bl,0        ; move 0 to bl
		mov ecx,02      ; move 02 to ecx
		mov esi,numascii   ; move numascii to the source index
	up1:    ; method for ascii to hex
		rol bl,04
		mov al,[esi]
		cmp al,39h
		jbe skip1
		sub al,07h
	skip1:
		sub al,30h
		add bl,al
		inc esi
		loop up1
		ret


	disp16:  ; method to display
		mov ecx,4      ; 4 indicate sys_write--> display
		mov edi,dispbuff    ; mov dispbuff to the destination index


	dub1:     ; method for hex to ascii
		rol bx,4
		mov al,bl
		and al,0fh
		cmp al,09h
		jbe x1
		add al,07
	x1:
		add al,30h
		mov [edi],al
		inc edi
		loop dub1
		dispmsg dispbuff,4
		ret 

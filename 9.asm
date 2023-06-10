//***PERFORM OVERLAP BLOCK TRANSFER***//
-------------------------------------------------------------------
section .data
	menumsg db 10,10,'***Overlap block transfer***',10
		db 10,'1.Block transfer without string '
		db 10,'2.Block transfer with string '
		db 10,'3.exit   '
	menumsg_len equ $-menumsg
	wrmsg db 10,10,'Wrong choice entered',10,10
	wrmsg_len equ $-wrmsg
	bfrmsg db 10,'**Block contents before transfer: '
	bfrmsg_len equ $-bfrmsg
	afrmsg db 10,'**Block contents after transfer:'
	afrmsg_len equ $-afrmsg
	srcmsg db 10,'*_*Source block contents   '
	srcmsg_len equ $-srcmsg
	dstmsg db 10,'*_*Destination block contents   '
	dstmsg_len equ $-dstmsg
	srcblk db 01h,02h,03h,04h,05h       ; pre-defined values given in source block
	dstblk times 3 db 0	
	cnt equ 05
	spacechar db 20h
	lfmsg db 10,10
	
section .bss
	optionbuff resb 02     ; reserve 2 byte for option
	dispbuff resb 02       ; reserve 2 byte for dispbuff

%macro dispmsg 2        ; dispmsg macro of length 2
	mov eax,04      ; 4 indicates sys_write--> display 
	mov ebx,01      ; move 1 to bx
	mov ecx,%1      ; call to the first parameter
	mov edx,%2      ; call to the second parameter
	int 80h         ; interrupt 80 is to call the system (similar to syscall)
%endmacro

%macro accept 2         ; accept macro of length 2
	mov eax,03      ; 3 indicates sys_read---> accept input
	mov ebx,00      ; move 0 to bx
	mov ecx,%1      ; call to the first parameter
 	mov edx,%2      ; call to the second parameter
	int 80h	        ; syscall
%endmacro

section .text
global _start
_start:
	dispmsg bfrmsg,bfrmsg_len       ; display the content before the block transfer
	call show                       ; call show method
	menu:
		dispmsg menumsg,menumsg_len    ; display menu 
		accept optionbuff,02           ; accept the choice from user
		cmp byte [optionbuff],'1'      ; compare the choice if =1
		jne case2                      ; jump to case2 if choice!=1
		call wos		       ; else call the wos(without string) method
		jmp exit1                      ; jump to exit1 method

	case2:
		cmp byte [optionbuff],'2'      ; compare if choice==2
		jne case3                      ; jump to case3 if choice !=2
		call ws			       ; call the ws(with string) method
		jmp exit1                      ; jump to exit1 method
	
	case3:
		cmp byte [optionbuff],'3'      ; compare if choice==3	
		je exit                        ; jump to exit method if choice==3
		dispmsg wrmsg,wrmsg_len        ; else display the wrong messsage
		jmp menu                       ; jump to the menu method
	
	exit1:
		dispmsg afrmsg,afrmsg_len      ; display messgage after block transfer
		call show	               ; call show method
		dispmsg lfmsg,2                
	exit:        ; method for exiting the program
		mov eax,01       ; 1 indicates sys_exit(for 32-bit)
		mov ebx,00       ; move 0 to rbx
		int 80h          ; interrupt 80h to call the system(similar to syscall)
	
//MAIN LOGIC///	
	dispblk:
		mov rcx,cnt      ; move count into cx
		
	rdisp:	     ; method to display the content after block transfer
		push rcx         ; push count onto stack 
		mov bl,[esi]     ; move the effective address of source index to bl
		call disp8       ; call disp8 method
		inc esi          ; increment source index
		dispmsg spacechar,1   
		pop rcx          ; pop count from stack
		loop rdisp       ; loop method rdisp
	        ret
	
	wos:        ; without string method
		mov esi,srcblk + 04h       ; point source index to source block+04 
		mov edi,dstblk + 02h       ; point destination index to destination block+02
		mov ecx,cnt                ; move count into cx
	x:           ; method for block transfer
		mov al,[esi]               ; mov content present at effective address of source index to al
		mov [edi],al               ; mov the content of al into the effective address of destination index
		dec esi                    ; decrement source index 
		dec edi                    ; decrement destination index
		loop x                     ; loop method x	
		ret  

	ws:          ; with string method 
		mov esi,srcblk + 04h       ; point source index to source block +04
		mov edi,dstblk + 02h       ; point destination index to destination block +02
		mov ecx,cnt                ; move count into ecx
		std			   ;set direction flag
		rep movsb                  ; repeat string operation while equal

	show:        ; method to display source and destination block content
		dispmsg srcmsg,srcmsg_len   ; display source block content 
		mov esi,srcblk
		call dispblk                ; call dispblk method
		dispmsg dstmsg,dstmsg_len   ; display destination block content
		mov esi,dstblk-02h          
		call dispblk                ; call dispblk method
		ret 
	
	disp8:       ; 
		mov ecx,02                  ; move 2 to ecx
		mov edi,dispbuff            ; move dispbuff to destination index
	


       dub1:         ; method for conversion from hex to ascii
		rol bl,4
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
		dispmsg dispbuff,3     ; 3 indicates sys_read --> accept input
		ret 

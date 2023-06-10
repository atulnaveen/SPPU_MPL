//***NON-OVERLAP BLOCK TRANSFER***//
----------------------------------------------------------------------------------
section .data
	menumsg db 10,10,'***Nonoverlap block transfer***',10
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
	srcblk db 01h,02h,03h,04h,05h       ; predefined value for source block
	dstblk times 5 db 0	                   
	cnt equ 05
	spacechar db 20h
	lfmsg db 10,10
	
section .bss
	optionbuff resb 02                   ; reserve 2 byte for optionbuff
	dispbuff resb 02                     ; reserve 2 byte for dispbuff

%macro dispmsg 2              ; macro dispmsg of length 2
	mov eax,04            ; 4 indicates sys_write-->display
	mov ebx,01            ; move 1 to ebx
	mov ecx,%1            ; call the first parameter
	mov edx,%2            ; call the second parameter
	int 80h               ; interrupt 80h to call the system (similar to syscall)
%endmacro

%macro accept 2               ; macro accept of length 2
	mov eax,03            ; 3 indicates sys_read---> accept input
	mov ebx,00            ; move 0 to ebx
	mov ecx,%1            ; call the first parameter
	mov edx,%2            ; call the second parameter
	int 80h	              ; interrupt to call the system
%endmacro

section .text
global _start
_start:
	dispmsg bfrmsg,bfrmsg_len            ; display block content before transfer
	call show                            ; call show method
	menu:
		dispmsg menumsg,menumsg_len  
		accept optionbuff,02
		cmp byte [optionbuff],'1'
		jne case2
		call wos			
		jmp exit1

	case2:
		cmp byte [optionbuff],'2'	
		jne case3
		call ws			
		jmp exit1
	
	case3:
		cmp byte [optionbuff],'3'	
		je exit
		dispmsg wrmsg,wrmsg_len
		jmp menu
	
//MAIN LOGIC//

	exit1:
		dispmsg afrmsg,afrmsg_len         ; display message after block transfer
		call show	                  ; call show method
		dispmsg lfmsg,2                   
	exit:       ; method for exiting the program
		mov eax,01                        ; 1 indicates sys_exit
		mov ebx,00                        ; move 0 in ebx
		int 80h                           ; interrupt to call the system
		
	dispblk:       ; method for display block
		mov rcx,cnt
		
	rdisp:	       ; method to display the content after block transfer
		push rcx               ; push count onto stack
		mov bl,[esi]           ; move the effective address of source index to bl
		call disp8             ; call disp8 method
		inc esi                ; increment source index
		dispmsg spacechar,1    
		pop rcx                ; pop count from stack
		loop rdisp
	        ret
	
	wos:      ; method for without string
		mov esi,srcblk       ; move source block to the source index
		mov edi,dstblk       ; move destination block to the destination index
		mov ecx,cnt          ; move count to ecx
	x:        ; method for block transfer
		mov al,[esi]     ; move the content of effective address of source index into al
		mov [edi],al     ; move the content of al into effective address of destination index
		inc esi          ; increment source index 
		inc edi          ; increment destination index
		loop x	         ; loop method x
		ret

	ws:       ; method for with string
		mov esi,srcblk       ; move source block to source index
		mov edi,dstblk       ; move destination block to destination index
		mov ecx,cnt          ; move count into ecx
		cld	             ; clear the direction flag			
		rep movsb            ; repeat string operation while equal

	show:     ; method to display the source and destination block content
		dispmsg srcmsg,srcmsg_len    
		mov esi,srcblk 
		call dispblk
		dispmsg dstmsg,dstmsg_len
		mov esi,dstblk
		call dispblk
		ret 
	
	disp8:  
		mov ecx,02          ; move 2 to ecx
		mov edi,dispbuff    ; move dispbuff to destination index
	

       dub1:     ; method for hex to ascii conversion
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
		dispmsg dispbuff,3
		ret 

//***ALP TO COUNT THE NO. OF POSITIVE AND NEGATIVE NUMBERS***//
----------------------------------------------------------------

section .data
  wmsg db 10,"Count positive and negative numbers in an array"
  wmsg_len equ $-wmsg
  pmsg db 10,"Count of +ve no: "
  pmsg_len equ $-pmsg
  nmsg db 10,"Count of -ve no: "
  nmsg_len equ $-nmsg
  nwline db 10
  array dw 90ffh,850fh,8a9fh,8a9fh,88h     ; array with predefined values 
  arrcnt equ 5    ; count of the elements in an array
  pcnt db 0       ; initializing positive count as 0
  ncnt db 0       ; initializing negative count as 0


section .bss
  dispbuff resb 2    ; reserving 2 byte for dispbuff 
  %macro print 2     ; macro print of length 2
    mov eax,4        ; 4 indicates the sys_write(i.e. to display) for 32 bit processor
    mov ebx,1        ; mov 1 to the bx
    mov ecx,%1       ; call to the first parameter(i.e pcnt)
    mov edx,%2       ; call to the second parameter(i.e ncnt)
    int 80h          ; call to the system(for 32-bit) - similar to the syscall
  %endmacro


section .text
  global _start
  _start:
   print wmsg,wmsg_len
   mov esi,array         ; move array elements to the source index
   mov cnt,arrcnt        ; move count of the array elements to the cnt variable

//MAIN LOGIC of program///
up1:      ; up1 method  
   bt word[esi],5     ; bt- bit test, checks if carry is present
   jnc pnxt           ; jump to pnext method if carry not present
   inc byte[ncnt]     ; else increment the count of negative number
   jmp pskip          ; jump to the pskip method
pnxt:     ; pnxt method 
   inc byte[pcnt]        ;  increment the count of positive number
pskip:    ; pskip method
   inc esi               ; increment the source index
   loop up1              ; loop the method up1
   print pmsg,pmsg_len   ; print the pmsg- for positive msg
   mov bl,[pcnt]         ; move the count of positive number to bl
   call disp8num         ; call to disp8num method
   print nmsg,nmsg_len   ; print the nmsg- for negative msg
   mov bl,[ncnt]         ; move the count of negative number to bl
   call disp8num         ; call disp8num method
   print nwline,1        
exit: mov eax,01     ; 1 indicates sys_exit (only for 32 bit)
      mov ebx,0      ; move 0 to ebx
      int 80h        ; 80h is the interrupt to call the system (similar to syscall)
disp8num:
    mov ecx,2         ; 2 indicates sys_fork--> actually creates a new process by duplicating the calling process
    mov edi,dispbuff  ; points destination index to the dispbuff


dup1:          ; method for converting from hex to ascii 
   rol bl,4
   mov al,bl
   and al,0fh
   cmp al,09
   jbe dskip
   add al,07h
dskip:          ; execution only after hex to ascii conversion
   add al,30h
   mov [edi],al
   inc edi
   loop dup1
   print dispbuff,2
   ret          ; return from the program

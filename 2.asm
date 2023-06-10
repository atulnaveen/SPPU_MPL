//***ACCEPT STRING AND DISPLAY ITS LENGTH***//
------------------------------------------------------

section .data
 msg1 db 10,13,"Enter a string"   
 len1 equ $-msg1

section .bss
 str1 resb 200
 result resb 16

section.text
 global _start
  _start:

    ; display msg1 
   mov rax,1   ; 1 for sys_write 
   mov rdi,1   ; 
   mov rsi,msg1 ; mov msg1 to source index
   mov rdx,len1 ; mov length of the msg1 to rdx
   syscall

;accepting the string
mov rax,0    ; 0 for sys_read-> to accept input
mov rdi,0    ; mov 0 to destination index
mov rsi,str1 ; mov str1 to source index
mov rdx,200  ; mov length of the str1 to rdx
syscall      ; call to the system
call display ; calling display method

;exit system call
mov rax,60   ; 60 for sys_exit-> exit from program
mov rdi,0    ; move 0 to destination index
syscall      

%macro displaymsg 2     ; creating a macro named displaymsg of length 2
mov rax,1      ; 1 for sys_write--> to display
mov rdi,1      ; mov 1 to rdi
mov rsi,%1     ; calling the first parameter (i.e. str1)
mov rdx,%2     ; calling the second parameter (i.e. result)
syscall        ; call to the system
%endmacro

display:       ; display method
  mov rbx,rax   ; move content of rax into rbx
  mov rdi,result  ; move result into rdi
  mov cx,16       ; move 16 to counter

  
up1:             ; hex to ascii conversion 
   rol rbx 04    ; rotate left the content of rbx by 4 bits
   mov al,bl     ; mov content of bl into al
   and al,0fh    ; and al with 0 (just to get the LSB only)
   cmp al,09h    ; compare al content with 09
   jg add_37     ; if (al>09) then jump to method add_37
   add al,30h    ; else(al<09) then add 30 to the al
   jmp skip      ; then jump to skip method

add_37:          ; add_37 method
   add al,37h    ; add 37 to the al

skip:            ; skip method
   mov [rdi],al  ; mov the al into the content of rdi
   inc rdi       ; increment the destination index
   dec cx        ; decrement the counter
   jnz up1       ; jump if not zero to method up1
   displaymsg result,16    ; call the macro displaymsg 
ret

//***ALP TO FIND THE LARGEST OF GIVEN BYTE/WORD/DOUBLEWORD***//
----------------------------------------------------------------------

section .data
 array db 11h,55h,33h,22h,44h           ; declaring the pre-defined elements in an array
 msg1 db 10,13,"largest no in an array is: "      ; msg1
 len1 equ $-msg1       ; length of msg1

section .bss
  cnt resb 1      ;     reserve memory of 1 byte for cnt(count)
  result resb 16  ;     reserve memory of 16 byte for result
 
section .text
 global _start
 _start:
  mov byte[cnt],5    ;  move 5 to the effective address 
  mov rsi,array      ;  point source index to the array
  mov al,0           ;  move 0 to al

//MAIN LOGIC//
LP:           ; method to compare and find the largest number
  cmp al,[rsi]   ; compare the content of the effective address pointed by source index with that of al 
  jg skip        ; jump to the skip method if [rsi]>al
  xchg al,[rsi]  ; else exchange the contents of al and rsi
skip:         ; skip method
  inc rsi     ; increment the source index
  dec byte[cnt]  ; decrement the count [note: initially count was 5]
  jnz LP         ; jump to LP method until the count is 0


;display msg1 
mov rax,1     ; 1 for sys_write
mov rdi,1     ; 
mov rsi,msg1  ; mov msg1 to the source index
mov rdx,len1  ; mov length of msg1 to the rdx
syscall       ; call to the system
call display  ; call the display macro

;exit syscall
mov rax,60    ; 60 for sys_exit --> exit from the program
mov rdi,0     ; move 0 to the destination index
syscall       ; call to the system 

%macro dispmsg 2    ; macro dispmsg of length 2
 mov rax,1     ; 1 for sys_write -> display the contents of rax
 mov rdi,1     ; mov 1 to the rdi
 mov rsi,%1    ; call the first parameter(i.e. cnt)
 mov rdx,%2    ; call the second parameter(i.e. result)
 syscall       ; call to the system
%endmacro

display:     ; method to display the final result to the user
  mov rbx,rax
  mov rdi,result
  mov cx,16

up1:   ; method to convert hex to ascii
 rol rbx,04
 mov al,bl
 add al,0fh
 cmp al,09h
 jg add_37
 jmp skip1
add_37:  
  add al,37h

skip1:    ;skip1 method is implemented after hex to ascii conversion
  mov [rdi],al
  inc rdi
  dec cx
  jnz up1
  dispmsg result,16 ; calling the dispmsg macro to display the final output
ret
 

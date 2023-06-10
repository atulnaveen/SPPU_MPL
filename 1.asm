//*** ACCEPT AND DISPLAY THE HEX NUMBERS***//
----------------------------------------------

section.data                                
 msg1 db 10,13,"Enter 5 64 bit numbers"
 len1 equ $-msg1
 msg2 db 10,13,"5 64 bit numbers are: "
 len2 equ $-msg2

section.bss
 array resd 200   ; reserving a 'double' of size 200 for 'array'
 counter resb 1   ; reserving a 'byte' of size 1 for 'counter' variable

section.text
 global _start
 _start:        ; _start indicates the program entry point
  
  ; display msg1
  mov rax,1     ; rax indicates 64-bit system, 1 indicates write operation for 64-bit system call 
  mov rdi,1     ; rdi indicates 64-bit destination index, 1 indicates write operation
  mov rsi,msg1  ; rsi source index pointing to the msg1(defined in .data section)
  mov rdx,len1  ; rdx holds the length of the msg1
  syscall       ; system call 

  ; accept 5 numbers
  mov byte[counter],05   ;  initializing the value of counter as 5
  mov rbx,00             ;  move 0 into rbx
  loop1:                 ; loop1 is a method 
   mov rax,0             ; 0 indicates read data and mov into rax
   mov rdi,0             ; move 0 into destination index
   mov rsi,array         ; points source index to the start of array
   add rsi,rbx           ; add rsi to rbx
   mov rdx,17            ; move 17 to rdx 
   add rbx,17            ; add 17 to the rbx-->(rbx is  )
   dec byte[counter]     ; decrement the counter 
   JNZ loop1             ; jump to method loop1 until counter !=0 

 ;display msg2    //similar as that of msg1
  mov rax,1              
  mov rdi,1
  mov rsi,msg2
  mov rdx,len2
  syscall

 ; display the accepted numbers
 mov byte[counter],05  
 mov rbx,00
 loop2:
  mov rax,1
  mov rdi,1
  mov rsi,array
  add rsi,rbx
  mov rdx,17
  syscall     
  add rbx,17
  dec byte[counter]
  JNZ loop2
 
;exit system call
mov rax,60    ; 60 indicates sys_exit 
mov rdi,0     ; move 0 to destination index
syscall

//***ALP FOR HEX TO BCD AND BCD TO HEX CONVERSION***//
--------------------------------------------------------------

section .data
 msg1 db 10,10,"**MENU**"
 db 10,"1.Hex to BCD"
 db 10,"2.BCD to Hex"
 db 10,"3.Exit"
 db 10,"Enter your choice: "
 msg1_len equ $-msg1
 msg2 db 10,"Enter four digit hex number: "
 msg2_len equ $-msg2
 msg3 db 10,"BCD Equivalent: "
 msg3_len equ $-msg3
 msg4 db 10,"Enter five digit BCD number: "
 msg4_len equ $-msg4
 msg5 db 10,"HEX equivalent: "
 msg5_len equ $-msg5
 wmsg db 10,"Wrong choice entered!!"
 wmsg_len equ $-wmsg
 cnt db 0

section .bss
 arr resb 06            ; reserving 6 byte of memory for array
 dispbuff resb 08       ; reserve 8 byte of memory for dispbuff
 ans resb 01            ; reserve 1 byte of memory for ans
 %macro disp 2          ; macro disp of length 2
  mov rax,0             ; 0 indicates sys_read (i.e. accept input) --> 64 bit operation
  mov rdi,0             ; move 0 to destination index
  mov rsi,%1            ; points source index to first parameter()
  mov rdx,%2            ; sys_open
  syscall               ; call  to the system   
 %endmacro

section .text
  global _start
  _start:
menu:  
  disp msg1,msg1_len    ; display menu to the users
  accept arr,2          ; accept choice from user
  cmp byte[arr],'1'     ; compare choice of user with 1
  jne l1                ; jump to l1 if choice!=1
  call hex2bcd_proc     ; else call hex2bcd_proc
  jmp menu              ; jump to menu method
l1:      ; l1 method for bcd2hex conversion
  cmp byte[arr],'2'     ; compare choice with 2
  jne l2                ; jump to l2 if choice !=2
  call bcd2hex          ; else call the bcd2hex
  jmp menu              ; jump to menu method
l2:      ; l2 method for wrong message display
  cmp byte[arr],'3'     ; compare the choice of user with 3
  je exit               ; jump to exit method if choice==3
  dispmsg wmsg,wmsg_len ; else display wrong message 
  jmp menu              ; jump to menu method 
exit:
  mov rax,60            ; 60 indicates sys_exit -->exit from program
  mov rbx,0             ; mov 0 to rbx
  syscall               ; call to the system

//MAIN LOGIC//
//HEX2BCD- Conversion//
hex2bcd_proc:
  disp msg2,msg2_len    ; display message to enter 4 digit hex number
  accept arr,5          ; accept the hex number
  call conversion       ; call to the conversion method
  mov rcx,0             ; read the hex number
  mov ax,bx             ; move the content of bx to ax
  mov bx,10             ; move 10 to bx
l33: mov dx,0           ; move 0 to dx
     div bx             ; divide accepted number by bx(i.e. 10)
     push rdx           ; push the remainder onto stack
     inc rcx            ; increment the count
disp msg3,msg3_len      ; display the third msg of BCD Equivalent
l44: pop rdx            ; pop the remainder from the stack  
     add dl,30h         ; add 30 to the remainder
     mov [ans],dl       ; move the dl content to the effective address of ans
disp ans,1              ; 1 indicates sys_write--> display the answer
     dec byte[cnt]      ; decrement the count
jnz l44                 ; jump to l44 method until count is 0
ret                    

//BCD2HEX- Conversion//
bcd2hex:
   disp msg4,msg4_len   ; display message to enter 5 digit bcd number
   accept arr,6         ; accept the bcd number
   disp msg5,msg5_len   ; display message for bcd2hex conversion
   mov rsi,arr          ; point source index to the arr
   mov rcx,05           ; initialize count to 5
   mov rax,0            ; move 0 to rax
   mov ebx,0ah          ; initialize bx with 10(0ah is hex equivalent of 10)
l55: mov rdx,0          ; move 0 to dx
     mul ebx            ; multiply accepted number with ebx(i.e. 10)
     mov dl,[rsi]       ; mov content of source index to the dl
     sub dl,30h         ; subtract 30 from the dl 
     add rax,rdx        ; add rax and rdx (i.e. bcd digit accepted + dx content)
     inc rsi            ; increment the source index
     dec rcx            ; decrement the count
     jnz l55            ; jump to l55 method until count !=0
     mov ebx,eax        ; mov eax to ebx
     call disp32_num    ; call disp32_num method

disp32_num:
  mov rdi,dispbuff      ; mov dispbuff to destination index
  mov rcx,08            ; initialize rcx as 8 

conversion:         ; conversion method
  mov bx,0          ; move 0 to bx
  mov ecx,04        ; move 4 to cx
  mov esi,arr       ; mov arr to source index



up1:   ; method for ascii to hex conversion
  rol bx,04         ; rotate left the content of bx by 4 bits          
  mov al,[esi]      ; move the content of esi to al
  cmp al,39h        ; compare al content with 39
  jbe l22           ; jump to l22 method if al<39
  sub al,07h        ; else sub 7 from al (if al>=39)
l22:   ; method to be implemented after ascii to hex conversion
  sub al,30h        ; subtract 30 from al
  add bl,al         ; add bl and al
  inc esi           ; increment the source index
  loop up1          ; loop the method up1 
  ret               ; return from the method

l77:   ; method to convert hex to ascii
  rol ebx,4
  mov dl,bl
  and dl,0fh
  add dl,30h
  jbe l66
  add dl,07h
l66:    ; method to be implemented after hex to ascii conversion
  mov [rdi],dl
  inc rdi
  dec rcx
  jnz l77
  disp dispbuff+3,5
  ret

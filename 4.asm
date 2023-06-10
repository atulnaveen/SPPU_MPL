//***SWITCH CASE DRIVEN ALP TO PERFORM ARITHMETIC OPERATIONS***//
----------------------------------------------------------------------


section .data
 menumsg db 10,"**MENU**"
         db 10,"1.Addition"
         db 10,"2.Subtraction"
         db 10,"3.Multiplication"
         db 10,"4.Division"
         db 10, "Enter your choice: "
 meumsg_len equ $-menumsg
 addmsg db 10,"Addition operation"
 addmsg_len equ $-addmsg
 submsg db 10,"Subtraction operation"
 submsg_len equ $-submsg
 mulmsg db 10,"Mutiplication Operaton"
 mulmsg_len equ $-mulmsg
 divmsg db 10, "Division operation"
 divmsg_len equ $-divmsg
 wrngmsg db 10,"Please enter valid choice"
 wrngmsg_len equ $-wrngmsg

 no1 dq,08h        ; declaring num1 as input
 no2 dq,02h        ; declaring num2 as input
 nummsg db 10      ; define byte for nummsg
 result dq 0       ; define quad for result

 resmsg db 10, "Result is: "
 resmsg_len equ $-resmsg
 qmsg db 10,"Quotient: "
 qmsg_len equ $-qmsg
 rmsg db 10,"Remainder: "
 rmsg_len equ $-rmsg
 nwmsg db 10
 resh dq 0        ; define quad for resh- higher bit
 resl dq 0        ; define quad for resl- lower bit

section .bss 
 choice resb 2    ; reserve byte for choice
 dispbuff resb 16 ; reserve byte for display buffer
 %macro scall 4   ; macro for calling the parameters
  mov rax,%1
  mov rdi,%2
  mov rsi,%3
  mov rdx,%4
  syscall
 %endmacro

section .text
 global _start
 _start:
  up:  scall 1,1,menumsg,menumsg_len   ; show menu msg to user              
       scall 0,0,choice,2              ; accept the choice from the user
       cmp byte[choice],'1'            ; compare choice with 1
       jne case2                       ; jump to case2 if choice != 1
       call add_proc                   ; else call the procedure for addition
       jmp up                          ; jump to 'up' method
  case2: cmp byte[choice],'2'          ; compare choice with 2
         jne case3                     ; if choice!=2 then jump to case3
         call sub_proc                 ; else call subtraction procedure
         jmp up                        ; jump to 'up' method
  case3: cmp byte[choice],'3'          ; compare choice with 3
         jne case4                     ; if choice!=3 then jump to case4
         call mul_proc                 ; else call multiplication procedure
         jmp up                        ; jump to 'up' method
  case4: cmp byte[choice],'4'          ; compare choice with 4
         jne caseinv                   ; if choice!=4 jump to caseinv
         call div_proc                 ; else call division procedure
         jmp up                        ; jump to up method
  caseinv:  scall 1,1,wrngmsg,wrngmsg_len   ; show the wrong msg

  exit: 
   mov eax,01  ; 1 indicates sys_exit
   mov ebx,0   ; mov 0 into ebx 
   int 80h     ; interrupt for system call
    
  add_proc:     ; procedure for addition operation
    mov rax,[no1]     ; move num1 in rax
    add rax,[no2]     ; add num2 with rax(i.e. num1)
    mov [result],rax  ; move rax into result
    scall 1,1,resmsg,resmsg_len   ; display the msg for addition
    mov rbx,[result]              ; move result into rbx
    call disp64num                ; call disp64num method
    scall 1,1,nummsg,1            ; display the result
    ret                           ; return from the addition procedure
  sub_proc:     ; procedure for subtraction
    mov rax,[no1]     ; move num1 to the rax
    sub rax,[no2]     ; subtract num2 with rax(i.e. num1)
    mov [result],rax  ; move rax into result
    scall 1,1,resmsg,resmsg_len    ; display msg for subtraction 
    mov rbx,[result]               ; move the result into rbx
    call disp64num                 ; call disp64num method
    scall 1,1,nummsg,1             ; display the result
    ret                            ; return from the subtraction procedure
  mul_proc:     ; procedure for multiplication
    scall 1,1,mulmsg,mulmsg_len   ; display msg for multiplication
    mov rax,[no1]                 ; move num1 to rax
    mov rbx,[no2]                 ; move num2 to rbx
    mul rbx                       ; multiply rbx
    mov [resh],rdx                ; move rdx onto higher bit of result
    mov [resl],rax                ; move rax onto lower bit of result
    scall 1,1,resmsg,resmsg_len   ; display the result msg
    mov rbx,[resh]                ; move higher bit content of result into rbx
    call disp64num                ; call the disp64num method
    mov rbx,[resl]                ; move lower bit content of result into rbx
    call disp64num                ; call the disp64num method
    scall 1,1,nwmsg,1            
    ret                           ; return from the multiplication procedure

  div_proc:     ; procedure for division
    scall 1,1,divmsg,divmsg_len   ; display msg for division 
    mov rax,[no1]                 ; move num1 into rax
    mov rdx,0                     ; move 0 to rdx
    mov rbx,[no2]                 ; move num2 into rbx
    div rbx                       ; divide rbx
    mov [resh],rdx                ; move rdx on higher bit of result
    mov [resl],rax                ; move rax on lower bit of result
    scall 1,1,rmsg,rmsg_len       ; display the remainder
    mov rbx,[resh]                ; move higher bit content(i.e. remainder) of result onto rbx
    call disp64num                ; call disp64num method
    scall 1,1,qmsg,qmsg_len       ; display the quotient message
    mov rbx,[resl]                ; move lower bit content(i.e. quotient) of result onto rbx
    call disp64num                ; call disp64num method
    scall 1,1,nwmsg,1             
    ret                           ; return from division procedure

  disp64num:      
    mov ecx,16                    ; move 16 to ecx
    mov edi,dispbuff              ; move dispbuff to the destination index
   
  dup1:       ; hex to ascii conversion
       rol rbx,4
       mov al,bl 
       and al,0fh
       cmp al,09h
       jbe dskip
       add al,07h
  dskip: add al,30h
         mov [edi],al
         inc edi
         loop dup1
         scall 1,1,dispbuff,16
    ret

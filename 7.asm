//***ALP TO SWITCH FROM REAL TO PROTECTED MODE AND DISPLAY THE CONTENTS OF GDTR,LDTR,IDTR,TR,MSW***//
---------------------------------------------------------------------------------------------------------

section .data:
  rmodemsg db 10,"Processor in Real Mode"
  rmode_len equ $-rmodemsg
  pmodemsg db 10, "Processor in Protected mode"
  pmode_len equ $-pmodemsg
  gdtmsg db 10, "GDT contents: "
  gdtmsg_len equ $-gdtmsg
  ldtmsg db 10, "LDT contents: "
  ldtmsg_len equ $-ldtmsg
  trmsg db 10,"TR contents: "
  trmsg_len equ $-trmsg
  mswmsg db 10, "MSW contents: "
  mswmsg_len equ $-mswmsg
  colmsg db ":"
  nwline db 10

section .bss
  gdt resd 1           ; reserving 1 double for gdt
      resw 1           ; reserving 1 word for gdt
  ldt resw 1           ; reserving 1 word for ldt
  idt resd 1           ; reserving 1 double for idt
      resw 1           ; reserving 1 word for idt
  tr resw 1            ; reserving 1 word for tr
  cr0_data resd 1      ; reserving 1 double for cr0 register
  dnum_buff resb 04    ; 4 byte for dnum_buff
  %macro disp 2        ; disp macro of length 2
   mov eax,04          ; 4 indicates sys_write-> display
   mov ebx,01          ; mov 1 to bx
   mov ecx,%1          ; call to the first parameter
   mov edx,%2          ; call to second parameter
   int 80h             ; interrupt code for to call the system (similar to syscall)
  %endmacro

section .text
  global _start
_start:

//MAIN LOGIC/// 
  smsw eax                   ; store msw(i.e. machine status word) content to the eax
  mov [cr0_data],eax         ; mov eax content to the effective address of cr0_data
  bt eax,1                   ; bt-byte test, checks if bt=1 (to check whether processor is in protected mode or not)
  jc prmode                  ; jump if carry(i.e. bt=1) to method prmode 
  disp rmodemsg,rmode_len    ; else display message of real mode
  jmp nxt1                   ; jump nxt1 method

prmode: disp pmodemsg,pmodemsg_len   

//METHOD TO STORE AND DISPLAY THE CONTENTS PRESENT IN DIFFERENT REGISTERS//
nxt1: 
  sgdt[gdt]                  ; store the effective address of gdt
  sldt[ldt]                  ; store the effective address of ldt
  sidt[idt]                  ; store the effective address of idt
  str[tr]                    ; store the effective address of tr

  disp gdtmsg,gdtmsg_len     ; display the gdt message
  mov bx,[gdt+4]             ; move the higher part base address of gdt to bx
  call disp_num
  mov bx,[gdt+2]             ; move the lower part limit address of gdt to bx
  call disp_num               
  disp colmsg,1 
  mov bx,[gdt]               ; move the effective address of gdt to bx
  call disp_num 

  disp ldtmsg,ldtmsg_len     ; display the ldt message
  mov bx,[ldt]               ; move the effective address of ldt to bx
  call disp_num              
  
  disp idtmsg,idtmsg_len     ; display the idt message
  mov bx,[idt+4]             ; move the higher part of the base address of idt to bx
  call disp_num              
  mov bx,[idt+2]             ; move the lower part of the limit address of idt to bx
  call disp_num
  disp colmsg,1            
  mov bx,[idt]               ; move the effective address of the idt to bx
  call disp_num

  disp trmsg,trmsg_len       ; display the tr message
  mov bx,[tr]                ; move the effective address of tr to bx
  call disp_num              
          
  disp mswmsg,mswmsg_len     ; display the msw message
  mov bx,[cr0_data+2]        ; move the effective address of higher part of cr0_data
  call disp_num
  mov bx,[cr0_data]          ;move the effective address of cr0_data
  call disp_num
  disp nwline,1         


exit:
   mov eax,01   ; 1 indicates sys_exit
   mov ebx,00   ; move 0 to ebx
   int 80h      ; 80h is interrupt to call the system(similar to syscall)

disp_num:       ; method to display the content of gdt,ldt,idt,tr,msw
  mov esi,dnum_buff   ;  move dnum_buff to source index
  mov ecx,04          ;  4 indicates sys_write--> display


up1:  ; method for hex to ascii conversion
  rol bx,04
  mov dl,bl
  add dl,0fh
  add dl,30h
  cmp dl,39h
  jbe skip1
  add dl,07h
skip1:  
  mov [esi],dl
  inc esi
  look up1
  disp dnum_buff,4
  ret

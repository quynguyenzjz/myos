bits 16
org 0x7C00

start:
    ; Initialize segment registers
    cli                     ; Disable interrupts
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Print welcome message
    mov si, msg_welcome
    call print_string

    ; Check if CPU supports long mode
    call check_long_mode

    ; Enable A20 line
    call enable_a20

    ; Load GDT and switch to protected mode
    lgdt [gdt64.pointer]
    mov eax, cr0
    or eax, 1              ; Set protected mode bit
    mov cr0, eax

    ; Jump to 32-bit protected mode
    jmp gdt64.code32:protected_mode

; Print string routine (16-bit mode)
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

check_long_mode:
    ; Check CPUID support
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    xor eax, ecx
    jz no_long_mode

    ; Check for extended processor info
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb no_long_mode

    ; Check for long mode support
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz no_long_mode
    ret

no_long_mode:
    mov si, msg_no_long_mode
    call print_string
    cli
    hlt

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; GDT for 64-bit mode
align 8
gdt64:
    ; Null descriptor
    dq 0
.code32: equ $ - gdt64
    ; 32-bit code segment
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0           ; Base (bits 0-15)
    db 0           ; Base (bits 16-23)
    db 10011010b   ; Access byte
    db 11001111b   ; Flags + Limit (bits 16-19)
    db 0           ; Base (bits 24-31)
.code64: equ $ - gdt64
    ; 64-bit code segment
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 10101111b
    db 0
.data: equ $ - gdt64
    ; Data segment
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0
.pointer:
    dw $ - gdt64 - 1   ; GDT size
    dq gdt64           ; GDT address

bits 32
protected_mode:
    ; Set up segment registers
    mov ax, gdt64.data
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up page tables
    call setup_paging

    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5     ; PAE bit
    mov cr4, eax

    ; Set long mode bit in EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8     ; Long mode bit
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31    ; Paging bit
    mov cr0, eax

    ; Jump to 64-bit code
    jmp gdt64.code64:long_mode_start

setup_paging:
    ; Clear page table area
    mov edi, 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, cr3

    ; Set up page tables
    mov dword [edi], 0x2003      ; PML4[0] -> PDPT
    add edi, 0x1000
    mov dword [edi], 0x3003      ; PDPT[0] -> PD
    add edi, 0x1000
    mov dword [edi], 0x4003      ; PD[0] -> PT
    add edi, 0x1000

    ; Identity map first 2MB
    mov ebx, 0x00000003
    mov ecx, 512
.set_entry:
    mov dword [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop .set_entry

    ret

bits 64
long_mode_start:
    ; Clear screen
    mov edi, 0xb8000
    mov rax, 0x1f201f201f201f20
    mov ecx, 500
    rep stosq

    ; Print success message
    mov rdi, 0xb8000
    mov rsi, msg_long_mode
    mov ah, 0x1f    ; White on blue
.print:
    lodsb
    or al, al
    jz .done
    mov [rdi], ax
    add rdi, 2
    jmp .print
.done:

    ; Halt
    cli
    hlt

; Messages
msg_welcome: db 'Booting MyOS...', 13, 10, 0
msg_no_long_mode: db 'ERROR: CPU does not support 64-bit mode!', 13, 10, 0
msg_long_mode: db 'Successfully switched to 64-bit Long Mode!', 0

times 510-($-$$) db 0
dw 0xAA55 
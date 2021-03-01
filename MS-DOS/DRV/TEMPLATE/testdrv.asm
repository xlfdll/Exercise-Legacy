; Derived from TEMPLATE.ASM by Ray Duncan, July 1987
; The driver command-code routines are stubs only and have
; no effect but to return a nonerror "Done" status.

[BITS 16]
; ORG is not necessary. -f bin set it to 0x0000 in default.

section .text

Header:             ; device driver header
    dd -1           ; link to next device driver. -1 means the last one
    dw 0c840h       ; device attribute word
    dw Strat        ; "Strategy" routine entry point
    dw Intr         ; "Interrupt" routine entry point
    db 'XDWSDDRV'   ; logical device name

Dispatch:           ; Interrupt routine command code dispatch table
    dw Init         ; 0  = initialize driver
    dw MediaChk     ; 1  = media check on block device
    dw BuildBPB     ; 2  = build BIOS parameter block
    dw IoctlRd      ; 3  = I/O control read
    dw Read         ; 4  = read (input) from device
    dw NdRead       ; 5  = nondestructive read
    dw InpStat      ; 6  = return current input status
    dw InpFlush     ; 7  = flush device input buffers
    dw Write        ; 8  = write (output) to device
    dw WriteVfy     ; 9  = write with verify
    dw OutStat      ; 10 = return current output status
    dw OutFlush     ; 11 = flush output buffers
    dw IoctlWt      ; 12 = I/O control write
    dw DevOpen      ; 13 = device open  (MS-DOS 3.0+)
    dw DevClose     ; 14 = device close (MS-DOS 3.0+)
    dw RemMedia     ; 15 = removable media   (MS-DOS 3.0+)
    dw OutBusy      ; 16 = output until busy (MS-DOS 3.0+)
    dw Error        ; 17 = not used
    dw Error        ; 18 = not used
    dw GenIOCTL     ; 19 = generic IOCTL     (MS-DOS 3.2+)
    dw Error        ; 20 = not used
    dw Error        ; 21 = not used
    dw Error        ; 22 = not used
    dw GetLogDev    ; 23 = get logical device (MS-DOS 3.2+)
    dw SetLogDev    ; 24 = set logical device (MS-DOS 3.2+)

; No need to make far procedure on purpose

Strat:              ; device driver Strategy routine
                    ; called by MS-DOS kernel with
                    ; ES:BX = address of request header

    ; save pointer to request header
    mov word [cs:RHPtr], bx
    mov word [cs:RHPtr+2], es
    
    retf            ; back to MS-DOS kernel

Intr:               ; device driver Interrupt routine
                    ; called by MS-DOS kernel immediately
                    ; after call to Strategy routine
    ; save states
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push di
    push si
    push bp
    
    push cs         ; make local data addressable
    pop ds          ; by setting DS = CS
    
    les di, [RHPtr] ; let ES:DI = request header
    
    mov bl, [es:di+2]
    xor bh, bh
    cmp bx, MaxCmd  ; get BX = command code and make sure it is valid (<24)
    jle IntrDispatch
    call Error
    jmp IntrDone

IntrDispatch:       ; form index to dispatch table and branch to command-code routine
    shl bx, 1
    call word [bx+Dispatch]
    les di, [RHPtr] ; ES:DI = address of request header

IntrDone:
    or ax, 0100h    ; merge Done bit into status and store status into request header
    mov [es:di+3], ax
    pop bp
    pop si
    pop di
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    retf            ; back to MS-DOS kernel

%include "commands.inc"

section .data

RHPtr   dd  0   ; pointer to request header, passed by MS-DOS kernel to Strategy routine
MaxCmd  equ 24  ; Maximum allowed command code
                ; 12 for MS-DOS 2.x
                ; 16 for MS-DOS 3.0-3.1
                ; 24 for MS-DOS 3.2-3.3
cr equ 0dh
lf equ 0ah
eom     equ '$' ; End-of-Message signal
msg     db  cr, lf, lf, 'XDWS Example Device Driver - Xlfdll', cr, lf, eom
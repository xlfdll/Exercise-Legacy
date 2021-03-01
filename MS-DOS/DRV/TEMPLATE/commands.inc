; Command-code routines are called by the Interrupt routine
; via the dispatch table with ES:DI pointing to the request
; header. Each routine should return AX = 00H if function was
; completed successfully or AX = 8000H + error code if
; function failed.

; function 0 = initialize driver
Init:
    push    es              ; save address of request header
    push    di

    mov     ah, 9           ; display driver sign-on message
    mov     dx, msg
    int     21h

    pop     di              ; restore request header address
    pop     es
                            ; set address of free memory 
                            ; above driver (break address)
    mov     word [es:di+14], Init
    mov     word [es:di+16], cs

    xor     ax, ax          ; return status
    ret
    
; function 1 = Media Check
MediaChk:
    xor     ax, ax
    ret

; function 2 = Build BPB
BuildBPB:
    xor     ax, ax
    ret

; function 3 = I/O Control Read
IoctlRd:
    xor     ax, ax
    ret

; function 4 = Read (Input)
Read:
    xor     ax, ax
    ret

; function 5 = Nondestructive Read
NdRead:
    xor     ax, ax
    ret

; function 6 = Input Status
InpStat:
    xor     ax, ax
    ret

; function 7 = Flush Input Buffers
InpFlush: 
    xor     ax, ax
    ret

; function 8 = Write (Output)
Write:
    xor     ax, ax
    ret

; function 9 = Write with Verify
WriteVfy:
    xor     ax, ax
    ret

; function 10 = Output Status
OutStat:
    xor     ax, ax
    ret

; function 11 = Flush Output Buffers
OutFlush:
    xor     ax, ax
    ret

; function 12 = I/O Control Write
IoctlWt:
    xor     ax, ax
    ret

; function 13 = Device Open
DevOpen:
    xor     ax, ax
    ret

; function 14 = Device Close
DevClose:
    xor     ax, ax
    ret

; function 15 = Removable Media
RemMedia:
    xor     ax, ax
    ret

; function 16 = Output Until Busy
OutBusy:
    xor     ax, ax
    ret

; function 19 = Generic IOCTL
GenIOCTL:
    xor     ax, ax
    ret

; function 23 = Get Logical Device
GetLogDev:
    xor     ax, ax
    ret

; function 24 = Set Logical Device
SetLogDev:
    xor     ax, ax
    ret

; bad command code in request header
Error:
    mov     ax, 8003h        ; error bit + "Unknown Command" code
    ret
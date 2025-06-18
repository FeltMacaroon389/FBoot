; FBoot: Extraordinarily simple real mode bootloader in NASM for x86 BIOS
; Loads specified sector amount and jumps to raw loaded segment


BITS 16		; 16-bit code
ORG 0x7C00	; BIOS expects programs to start at 0x7C00


; Amount of sectors to load
; Set this to the amount of sectors required for your kernel
; FBoot supports up to 127 sectors (63.5 KB)
; 1 sector = 512 Bytes
FBOOT_SECTORS db	1

; Newline definition for strings
%define NEWLINE		0x0D, 0x0A


; Program entrypoint
_start:
	; Disable hardware interrupts for stability
	cli
	
	; Null-out segment registers
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	
	; Save BIOS-provided boot drive
	mov [boot_drive], dl

	; Set stack at 0x7E00
	; Provides approximately 31.5 KB of safe stack space
	mov ax, 0x7E00
	mov sp, ax
	mov bp, ax

	; Enable hardware interrupts
	sti

	; Set CLear Direction flag, forcing string operations to move from left to right
	cld
	
	; Set VGA text mode
	; This will usually be provided by the BIOS, but we might as well
	xor ah, ah
	mov al, 0x03
	int 0x10
	
	; Print boot message
	mov si, boot_message
	call print_string
	
	; Load kernel
	call load_kernel

	; Push kernel return label to stack
	push .kernel_return

	; Far jump to kernel
	jmp 0x1000:0000

; When the kernel returns
.kernel_return:
	; Print return message
	mov si, return_message
	call print_string

; Permanently halt code execution
.stop:
	cli		; Disable hardware interrupts
	hlt		; Halt the CPU
	jmp .stop	; Jump back to the start of the loop, just in case

; Boot drive buffer
boot_drive db 0

; Boot message
boot_message db "Welcome to FBoot!", NEWLINE, NEWLINE, "Booting...", NEWLINE, 0

; Kernel return message
return_message db NEWLINE, NEWLINE, "FBoot: Kernel has returned, halting", NEWLINE, 0


; Function to load sector amount starting at 0x1000:0x0000
load_kernel:
	; Save required registers to stack
	push ax
	push bx
	push cx
	push dx
	push es
	push si

	; Set offset at 0x1000:0000
	mov ax, 0x1000
	mov es, ax
	xor bx, bx
	
	; Try reading up to 5 times if needed
	mov si, 5

.read:
	; Prepare BIOS call to provide further sectors
	mov ah, 0x02		; Function number: read sectors
	mov al, [FBOOT_SECTORS]	; Number of sectors to read
	xor ch, ch		; Cylinder number (low 8 bits)
	mov cl, 2		; Index to start at: 2 for right after boot sector
	xor dh, dh		; Head number
	mov dl, [boot_drive]	; Disk to load from
	int 0x13		; Call BIOS
	jc .read_retry		; If an error occurs, retry
	jmp .read_ok		; Otherwise, read OK

; Retry reading
.read_retry:
	dec si			; Decrement SI
	jz .read_retry		; Jump to .disk_error if SI = 0

	; Reset the disk system
	xor ah, ah
	int 0x13

	; Attempt to read again
	jmp .read

	; Continue the loop
	jmp .read_retry

; If the disk read succeeded
.read_ok:
	; Return registers from stack
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	
	; Return from function
	ret

; Upon a disk error
.disk_error:
	; Disable hardware interrupts
	cli

	; Print disk error message
	mov si, disk_error_message
	call print_string

; Loop to permanently halt code execution
.stop:
	cli		; Disable hardware interrupts
	hlt		; Halt the CPU
	jmp .stop	; Continue the loop

; Disk error message
disk_error_message db NEWLINE, "FBoot: Fatal Error: Error Loading From Disk", NEWLINE, 0


; Function to print a string from SI using BIOS
print_string:
	push ax
	
	; BIOS function: write character from AL
	mov ah, 0x0E

.print_loop:
	; Load byte from SI to AL
	lodsb
	
	; Compare AL to 0 (null terminator), jump to .done if found
	cmp al, 0
	je .done
	
	; Call BIOS
	int 0x10
	
	; Continue loop
	jmp .print_loop

.done:
	pop ax

	ret


; Other BIOS boot sector formalities
times 510 - ($ - $$) db 0	; Pad to 510 bytes
dw 0xAA55			; Write boot signature


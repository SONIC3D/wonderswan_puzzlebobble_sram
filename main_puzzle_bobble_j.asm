;--------------------------------------------------------------------
; Author: SONIC3D
; E-mail: sonic3d@gmail.com
; 2020.May.13
;--------------------------------------------------------------------
; all-in-one.asm - Template project for WonderSwan program
; Build command:
;       nasm -f bin -o aio.ws all-in-one.asm
;--------------------------------------------------------------------

;==================
; ROM Size Setting
;==================
; %define ROM_1MBIT
; %define ROM_2MBIT
%define ROM_4MBIT
; %define ROM_8MBIT

%ifdef ROM_8MBIT
        CART_ROM_SIZE   equ     0x03
%elifdef ROM_4MBIT
        CART_ROM_SIZE   equ     0x02
%elifdef ROM_2MBIT
        CART_ROM_SIZE   equ     0x01
%else   ; ROM_1MBIT
        CART_ROM_SIZE   equ     0x00
%endif

;==================
; BIOS Boot Splash
;==================
; %define IGNORE_BOOT_SPLASH
%ifdef IGNORE_BOOT_SPLASH
        ROMHDR_UNDOCUMENTED_SETTING     equ     0x80    ; Bit 7: Set = Ignore custom bootsplash
%else
        ROMHDR_UNDOCUMENTED_SETTING     equ     0x00
%endif

;=======================
; WonderSwan Color Mode
;=======================
%define WS_MONO
; %define WSC_MODE_A      ; Color Mode A
; %define WSC_MODE_B_U    ; Color Mode B(Unpacked Pixel)
; %define WSC_MODE_B_P    ; Color Mode B(Packed Pixel)

%ifdef WSC_MODE_B_P
        COLOR_MODE_VALUE        equ     0x03
        ROMHDR_MIN_SYS          equ     0x01
%elifdef WSC_MODE_B_U
        COLOR_MODE_VALUE        equ     0x02
        ROMHDR_MIN_SYS          equ     0x01
%elifdef WSC_MODE_A
        COLOR_MODE_VALUE        equ     0x01
        ROMHDR_MIN_SYS          equ     0x01
%else   ; WS_MONO
        COLOR_MODE_VALUE        equ     0x00
        ROMHDR_MIN_SYS          equ     0x00
%endif

;==================
; Original entry point of Puzzle Bobble (Japan).ws
;==================
PRG_START_CS equ 0x8000
PRG_START_IP equ 0x000A

;==================
; Original EEPROM function address Puzzle Bobble (Japan).ws
;==================
FUNC_ENTRY_OF_EEPROM_INIT   equ 0x12CC1
FUNC_ENTRY_OF_EEPROM_READ   equ 0x12D1B
FUNC_ENTRY_OF_EEPROM_WRITE  equ 0x12DBD

;==================
; 2 parts of original ROM data that are not modified
;==================
ROM_DATA_OFFSET_PART1       equ 0x0
ROM_DATA_LEN_PART1          equ FUNC_ENTRY_OF_EEPROM_INIT-ROM_DATA_OFFSET_PART1
ROM_DATA_OFFSET_PART2       equ 0x12E80
ROM_DATA_LEN_PART2          equ 0x7FFF0-ROM_DATA_OFFSET_PART2

;==================
; Unmodified original ROM data, part 1
;==================
ROM_Part1:
        incbin "Puzzle Bobble (Japan).ws", ROM_DATA_OFFSET_PART1, ROM_DATA_LEN_PART1

;================================================================
; Original Feature:
;   Cartridge EEPROM Init(Set Write Enable)
;   Params:
;           CX: EEPROM Capacity
;			    00: None
;               01: 1kbit
;               02: 2kbit
;               03: 4kbit
;               05: 16kbit
;               06: 32kbit
;               Other: Invalid
;   Return:
;           AX: Error Code
;               00: Success
;               01: Failed, none or invalid EEPROM capacity.
;================================================================
EEPROM_INIT:
        xor     ax, ax
        retf
; Fill dummy data till next function or data region
        times FUNC_ENTRY_OF_EEPROM_READ - FUNC_ENTRY_OF_EEPROM_INIT - $+EEPROM_INIT db 0

;================================================================
; Original Feature:
;   Cartridge EEPROM Read Word
;       Read data from EEPROM.
;       Please note that each address contains a 16bit data record.
;       addrress    |   data
;       0000h       |   1234h
;       0001h       |   5678h
;   Params:
;           BX: Target Address to read
;           CX: EEPROM Capacity
;			    00: None
;               01: 1kbit
;               02: 2kbit
;               03: 4kbit
;               05: 16kbit
;               06: 32kbit
;               Other: Invalid
;   Return:
;           AX: Error Code
;               00: Success
;               01: Failed. Invalid address. Target address in bx is over the capacity.
;               02: Failed. None or invalid EEPROM capacity.
;           DX: Data read from EEPROM
;================================================================
EEPROM_READ:
        push    bx
        push    es
        shl     bx, 1           ; Each EEPROM address points to a 16bit data record.
                                ; So we need to shift the address left 1 bit to get even address for on-cart RAM.
        and     bx, 0xFFF       ; Max 32kbit = 4kbyte, so mask the address to (4096-1)
        mov     ax, 0x1000      ; WS on-cart RAM is accessed from 0x1000:0000-0x1000:FFFF
                                ; As EEPROM capacity is smaller than on-cart RAM bank size,
                                ; so here we skip setting the on-cart RAM bank register 0xC1.
        mov     es, ax
        mov     dx, es:[bx]     ; Read data from on-cart RAM
        pop     es
        pop     bx
.endOfRd:
        xor     ax, ax
        retf
; Fill dummy data till next function or data region
        times FUNC_ENTRY_OF_EEPROM_WRITE - FUNC_ENTRY_OF_EEPROM_READ - $+EEPROM_READ db 0

;================================================================
; Original Feature:
;   Cartridge EEPROM Write Word
;       Write data to EEPROM.
;       Please note that each address contains a 16bit data record.
;       addrress    |   data
;       0000h       |   1234h
;       0001h       |   5678h
;   Params:
;           BX: Target Address to write
;           CX: EEPROM Capacity
;			    00: None
;               01: 1kbit
;               02: 2kbit
;               03: 4kbit
;               05: 16kbit
;               06: 32kbit
;               Other: Invalid
;           DX: Data to write to EEPROM
;   Return:
;           AX: Error Code
;               00: Success
;               01: Failed. Invalid address. Target address in bx is over the capacity.
;               02: Failed. Write timeout
;               03: Failed. None or invalid EEPROM capacity.
;================================================================
EEPROM_WRITE:
        push    bx
        push    es
        shl     bx, 1           ; Each EEPROM address points to a 16bit data record.
                                ; So we need to shift the address left 1 bit to get even address for on-cart RAM.
        and     bx, 0xFFF       ; Max 32kbit = 4kbyte, so mask the address to (4096-1)
        mov     ax, 0x1000      ; WS on-cart RAM is accessed from 0x1000:0000-0x1000:FFFF
                                ; As EEPROM capacity is smaller than on-cart RAM bank size,
                                ; so here we skip setting the on-cart RAM bank register 0xC1.
        mov     es, ax
        mov     es:[bx], dx     ; Write data to on-cart RAM
        pop     es
        pop     bx
.endOfWr:
        xor     ax, ax
        retf
; Fill dummy data till next function or data region
        times ROM_DATA_OFFSET_PART2 - FUNC_ENTRY_OF_EEPROM_WRITE - $+EEPROM_WRITE db 0

;==================
; Unmodified original ROM data, part 2
;==================
ROM_Part2:
        incbin "Puzzle Bobble (Japan).ws", ROM_DATA_OFFSET_PART2, ROM_DATA_LEN_PART2





;==================
; ROM Header
;==================
ResetVector:
        db      0xEA                            ; jmpf
        dw      PRG_START_IP                    ; IP: Program startup address in segment
        dw      PRG_START_CS                    ; CS: In bank 0x8000
        db      ROMHDR_UNDOCUMENTED_SETTING     ; Reserved Area(Usually all 0, Bit 7: Set = Ignore custom bootsplash)

Header:
        db      0x0C            ; Company ID
        db      ROMHDR_MIN_SYS  ; Minimum support system: 00 - WS Mono, 01 - WS Color
        db      0x03            ; Product ID
        db      0x00            ; Product Version
        db      CART_ROM_SIZE   ; Cart ROM Size (03:8Mbit / 02:4Mbit / 01:2Mbit / 00:1Mbit)
        db      0x02            ; Cart SRAM size (02: 256Kbit / 01: 64Kbit / 00: None)
        db      0x05            ; 16bit ROM Bus & Horizontal video mode
        db      0x00            ; SubSystem LSI(No RTC)
        dw      0x1F27          ; Checksum( Yes, it's hard coded value for this patch, generated by mednafen =] )
